// The MIT License (MIT)
//
// Copyright (c) 2013 Florida International University
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//  MobileClinicFacade.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 3/1/13.
//
#import "MobileClinicFacade.h"
#import "PatientObject.h"
#import "VisitationObject.h"
#import "PrescriptionObject.h"
#import "MedicationObject.h"

@implementation MobileClinicFacade

- (id)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

-(NSString *)GetCurrentUsername
{
    return [BaseObject getCurrenUserName];
}

#pragma mark- CREATING NEW OBJECTS
#pragma mark-

// Creates only a local copy of the patient
-(void)createAndCheckInPatient:(NSDictionary *)patientInfo onCompletion:(MobileClinicCommandResponse)Response
{
    PatientObject* patient = [[PatientObject alloc]initAndMakeNewDatabaseObject];
    
    // Object is Create locally Only
    [self CommonCommandObject:patient ForCreating:patientInfo bindedToParentObjectToUpdate:nil withResults:Response];
}

// creates a new prescription for a given visit
-(void)addNewPrescription:(NSDictionary *)Rx ForCurrentVisit:(NSDictionary *)visit AndlockVisit:(BOOL)lock onCompletion:(MobileClinicCommandResponse)Response
{
    [self updateVisitRecord:visit andShouldUnlock:!lock andShouldCloseVisit:NO onCompletion:^(NSDictionary *object, NSError *error)
    {
        if (!object)
        {
            Response(object,error);
        }
        else
        {
            [self CommonCommandObject:[[PrescriptionObject alloc]initAndMakeNewDatabaseObject] ForCreating:Rx bindedToParentObjectToUpdate:visit withResults:Response];
        }
    }];
}

// Creates a new visit for a given patient.
-(void)addNewVisit:(NSDictionary *)visitInfo ForCurrentPatient:(NSDictionary *)patientInfo shouldCheckOut:(BOOL)checkout onCompletion:(MobileClinicCommandResponse)Response
{
    // If Patient being passed is already open do not go further
    if (![[patientInfo objectForKey:ISOPEN]boolValue])
    {
        NSMutableDictionary* openPatient = [[NSMutableDictionary alloc]initWithDictionary:patientInfo];
     
        // Set patient open status
        [openPatient setValue:[NSNumber numberWithBool:!checkout] forKey:ISOPEN];
        [self CommonCommandObject:[[PatientObject alloc]init] ShouldLock:NO CommonUpdate:openPatient withResults:^(NSDictionary *object, NSError *error)
        {
            if (!object || error.code > kErrorDisconnected)
            {
                Response(object,error);
            }
            else
            {
                NSMutableDictionary* openVisit = [[NSMutableDictionary alloc]initWithDictionary:visitInfo];
                [openVisit setValue:[NSNumber numberWithBool:!checkout] forKey:ISOPEN];
                [self CommonCommandObject:[[VisitationObject alloc]initAndMakeNewDatabaseObject] ForCreating:openVisit bindedToParentObjectToUpdate:patientInfo withResults:Response];
            }
        }];
    }
    else
    {
        Response(nil,[self createErrorWithDescription:MULTIPLE_VISIT_ERROR andErrorCodeNumber:kError inDomain:@"MCF"]);
    }
}

#pragma mark- SEARCHING FOR OBJECTS
#pragma mark-

//  Use to find patients.
-(void)findPatientWithFirstName:(NSString *)firstname orLastName:(NSString *)lastname onCompletion:(MobileClinicSearchResponse)Response
{
    // Create a temporary Patient Object to make request
    PatientObject* patients = [[PatientObject alloc]init];
    NSDictionary* search = [NSDictionary dictionaryWithObjectsAndKeys:firstname,FIRSTNAME,lastname,FAMILYNAME, nil];
    [self CommonCommandObject:patients ForSearch:search withResults:Response];
}

// Use to find visits for a given patient.
-(void)findAllVisitsForCurrentPatient:(NSDictionary *)patientInfo AndOnCompletion:(MobileClinicSearchResponse)Response
{
    // Create a temporary Visitation Object to make request
    VisitationObject* vObject = [[VisitationObject alloc]init];
    [self CommonCommandObject:vObject ForSearch:patientInfo withResults:Response];
}

//TODO: Needs to be optimized
// Use to find open visits that needs servicing
-(void)findAllOpenVisitsAndOnCompletion:(MobileClinicSearchResponse)Response
{
    // Create a temporary Visit Object to make request
    VisitationObject* vObject = [[VisitationObject alloc]init];
    
    // Fetch and Save query results from server
    [vObject SyncAllOpenVisitsOnServer:^(id<BaseObjectProtocol> vData, NSError *error)
    {
        if ((error.code != kSuccess && error.code != kErrorDisconnected) && !vData)
        {
            Response(nil,error);
        }
        else
        {
            PatientObject* pObject = [[PatientObject alloc]init];
            [pObject SyncAllOpenPatietnsOnServer:^(id<BaseObjectProtocol> pData, NSError *error)
            {
                if (error.code == kError && !pData)
                {
                    Response(nil,error);
                }
                else
                {
                    // Array of Visit Dictionaries
                    NSArray* allVisits = [NSArray arrayWithArray:[vObject FindAllOpenVisitsLocally]];
                    NSString* patientID;
                    
                    // For every Dictionary in the array...
                    for (NSMutableDictionary* dic in allVisits)
                    {
                        // Get the patient ID
                        patientID = [dic objectForKey:PATIENTID];
                    
                        // Find the patient for that ID
                        PatientObject* patients = [[PatientObject alloc]initWithCachedObjectWithUpdatedObject:[NSDictionary dictionaryWithObjectsAndKeys:patientID,PATIENTID, nil]];
                        
                        // Save the Dictionary value of that patient inside the current dictionary
                        [dic setValue:patients.getDictionaryValuesFromManagedObject forKey:OPEN_VISITS_PATIENT];
                    }
                    
                    // Send array Results to caller
                    Response(allVisits,error);
                }
            }];
        }
    }];
}

// Use to find all Prescriptions
-(void)findAllPrescriptionForCurrentVisit:(NSDictionary *)visit AndOnCompletion:(MobileClinicSearchResponse)Response
{
    // Create a temporary Patient Object to make request
    PrescriptionObject* prObject = [[PrescriptionObject alloc]init];
    [self CommonCommandObject:prObject ForSearch:visit withResults:Response];
}

// Finds all the medication
-(void)findAllMedication:(NSDictionary *)visit AndOnCompletion:(MobileClinicSearchResponse)Response
{
    MedicationObject* base = [[MedicationObject alloc]init];
    [self CommonCommandObject:base ForSearch:nil withResults:Response];
}

#pragma mark- UPDATING OBJECTS
#pragma mark-

// Updates a visitation record and locks it depend the Bool variable
-(void)updateVisitRecord:(NSDictionary *)visitRecord andShouldUnlock:(BOOL)unlock andShouldCloseVisit:(BOOL)closeVisit onCompletion:(MobileClinicCommandResponse)Response
{
    NSMutableDictionary* temp = [NSMutableDictionary dictionaryWithDictionary:visitRecord];
    [temp setValue:[NSNumber numberWithBool:!closeVisit] forKey:ISOPEN];
    
    // Just in case people become silly
    [temp removeObjectForKey:OPEN_VISITS_PATIENT];
    
    VisitationObject* base = [[VisitationObject alloc]initWithCachedObjectWithUpdatedObject:temp];
    [self CommonCommandObject:base ShouldLock:!unlock CommonUpdate:[NSMutableDictionary dictionaryWithDictionary:temp] withResults:Response];
}

// Updates the patient and locks based on Bool variable
-(void)updateCurrentPatient:(NSDictionary *)patientInfo AndShouldLock:(BOOL)lock onCompletion:(MobileClinicCommandResponse)Response
{
    PatientObject* base = [[PatientObject alloc]initWithCachedObjectWithUpdatedObject:patientInfo];
    [self CommonCommandObject:base ShouldLock:lock CommonUpdate:[NSMutableDictionary dictionaryWithDictionary:patientInfo] withResults:Response];
}

// Updates the prescription and locks based on Bool variable
-(void) updatePrescription:(NSDictionary*)Rx AndShouldLock:(BOOL)lock onCompletion:(MobileClinicCommandResponse)Response
{
    PrescriptionObject* base = [[PrescriptionObject alloc]initWithCachedObjectWithUpdatedObject:Rx];
    [self CommonCommandObject:base ShouldLock:lock CommonUpdate:[NSMutableDictionary dictionaryWithDictionary:Rx] withResults:Response];
}

// Updates the medication and locks it if necessary
-(void)updateMedication:(NSDictionary *)Rx AndShouldLock:(BOOL)lock onCompletion:(MobileClinicCommandResponse)Response
{
    MedicationObject* base = [[MedicationObject alloc]initWithCachedObjectWithUpdatedObject:Rx];
    [self CommonCommandObject:base ShouldLock:lock CommonUpdate:[NSMutableDictionary dictionaryWithDictionary:Rx] withResults:Response];
}

// Makes sure that the Patient and the associated Visit is closed
-(void)checkoutVisit:(NSDictionary*)visit forPatient:(NSDictionary*)patient AndWillUlockOnCompletion:(MobileClinicCommandResponse)Response
{
    NSMutableDictionary* patientDictionary = [NSMutableDictionary dictionaryWithDictionary:patient];
    [patientDictionary setValue:[NSNumber numberWithBool:NO] forKey:ISOPEN];
    NSMutableDictionary* visitDictionary = [NSMutableDictionary dictionaryWithDictionary:visit];
    [visitDictionary setValue:[NSNumber numberWithBool:NO] forKey:ISOPEN];
    
    // Just in case people become silly
    [visitDictionary removeObjectForKey:OPEN_VISITS_PATIENT];
    
    VisitationObject* myVisit = [[VisitationObject alloc]init];
    
    [self CommonCommandObject:myVisit ShouldLock:NO CommonUpdate:visitDictionary withResults:^(NSDictionary *object, NSError *error)
    {
        if (object)
        {
            PatientObject* myPatient = [[PatientObject alloc]init];
            [self CommonCommandObject:myPatient ShouldLock:NO CommonUpdate:patientDictionary withResults:Response];
        }
        else
        {
            Response(object,error);
        }
    }];
}

#pragma mark- PRIVATE GENERIC METHODS
#pragma mark-

-(void)CommonCommandObject:(id<CommonObjectProtocol>)base ShouldLock:(BOOL)lock CommonUpdate:(NSMutableDictionary*)object withResults:(MobileClinicCommandResponse)results
{
    // Call the server to make a request for Visits
    [base UpdateObjectAndShouldLock:lock witData:object AndInstructions:kUpdateObject onCompletion:^(id<BaseObjectProtocol> data, NSError *error)
    {
        results([data getDictionaryValuesFromManagedObject],error);
    }];
}

-(void)CommonCommandObject:(id<CommonObjectProtocol>)commandObject ForSearch:(NSDictionary*)object withResults:(MobileClinicSearchResponse)searchResults
{
    // Call the server to make a request for Visits
    [commandObject FindAllObjectsOnServerFromParentObject:object OnCompletion:^(id<BaseObjectProtocol> data, NSError *error)
    {
        // get all visits that are stored on the device
        NSArray* allVisits = [NSArray arrayWithArray:[commandObject FindAllObjectsLocallyFromParentObject:object]];
        searchResults(allVisits,error);
    }];
}

-(void)CommonCommandObject:(id<CommonObjectProtocol,BaseObjectProtocol>)commandObject ForCreating:(NSDictionary*)object bindedToParentObjectToUpdate:(NSDictionary*)parent withResults:(MobileClinicCommandResponse)results
{
    // If a parent object exists
    if (parent)
    {
        // Tie the objects to each other
        [commandObject associateObjectToItsSuperParent:parent];
    }
    
    [commandObject createNewObject:object onCompletion:^(id<BaseObjectProtocol> data, NSError *error)
    {
        results([data getDictionaryValuesFromManagedObject],error);
    }];
}
@end