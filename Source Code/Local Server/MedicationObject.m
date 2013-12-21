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
//  MedicationObject.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 3/15/13.
//  Modified by James Mendez on 12/2013
//
#define DATABASE    @"Medication"

#import "BaseObject+Protected.h"
#import "MedicationObject.h"

NSString* medicationID;

@implementation MedicationObject

+(NSString *)DatabaseName
{
    return DATABASE;
}

- (id)init
{
    [self setupObject];
    return [super init];
}

-(id)initAndMakeNewDatabaseObject
{
    [self setupObject];
    return [super initAndMakeNewDatabaseObject];
}

- (id)initAndFillWithNewObject:(NSDictionary *)info
{
    [self setupObject];
    return [super initAndFillWithNewObject:info];
}

-(id)initWithCachedObjectWithUpdatedObject:(NSDictionary *)dic
{
    [self setupObject];
    return [super initWithCachedObjectWithUpdatedObject:dic];
}

-(void)setupObject
{
    self->COMMONID =  MEDICATIONID;
    self->CLASSTYPE = kMedicationType;
    self->COMMONDATABASE = DATABASE;
}

-(void)ServerCommand:(NSDictionary *)dataToBeRecieved withOnComplete:(ServerCommand)response
{
    [super ServerCommand:nil withOnComplete:response];
    [self unpackageFileForUser:dataToBeRecieved];
    [self CommonExecution];
}

-(void)unpackageFileForUser:(NSDictionary *)data
{
    [super unpackageFileForUser:data];
    medicationID = [self->databaseObject valueForKey:MEDICATIONID];
}

-(void)CommonExecution
{
    switch (self->commands)
    {
        case kUpdateObject:
            [super UpdateObjectAndSendToClient];
            break;
        case kFindObject:
            [self sendSearchResults:[self FindAllObjects]];
            break;
        default:
            break;
    }
}

#pragma mark - COMMON OBJECT Methods
#pragma mark -

/* OLD - No error checking, crashes without cloud connection
 -(void)pullFromCloud:(CloudCallback)onComplete{
 
 [self makeCloudCallWithCommand:DATABASE withObject:nil onComplete:^(id cloudResults, NSError *error) {
 
 /*if (!error) {
 
 NSArray* allMeds = [cloudResults objectForKey:@"data"];
 
 NSArray* allError = [self SaveListOfObjectsFromDictionary:allMeds];
 
 if (allError.count > 0) {
 error = [[NSError alloc]initWithDomain:COMMONDATABASE code:kErrorObjectMisconfiguration userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Object was misconfigured",NSLocalizedFailureReasonErrorKey, nil]];
 onComplete(self,error);
 return;
 }
 }//*/

-(void)pullFromCloud:(CloudCallback)onComplete
{
    //TODO: Remove Hard Dependencies
    [self makeCloudCallWithCommand:DATABASE withObject:nil onComplete:^(id cloudResults, NSError *error)
     {
         if (cloudResults == nil) // NO CLOUD CONNECTION
         {
             NSString* errorValue = @"No connection to the Cloud";
             NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
             [errorDetail setValue:errorValue forKey:NSLocalizedDescriptionKey];
             error = [NSError errorWithDomain:@"MedicationObject:pullFromCloud" code:100 userInfo:errorDetail];
             onComplete((!error)?self:nil,error);
         }
         else if ([[cloudResults objectForKey:@"result"] isEqualToString:@"true"]) // SUCCESS
         {
             NSArray* medicationsFromCloud = [cloudResults objectForKey:@"data"];
             
			 // Destructive Sync, delete whatever is currently in the DB and replace with whatever is in the cloud
             [self deleteAllMedications];
			 
             NSArray* allError = [self SaveListOfObjectsFromDictionary:medicationsFromCloud];
             if (allError.count > 0)
             {
                 error = [[NSError alloc]initWithDomain:COMMONDATABASE code:kErrorObjectMisconfiguration userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Object was misconfigured",NSLocalizedFailureReasonErrorKey, nil]];
                 onComplete(self,error);
                 return;
             }
             onComplete((!error)?self:nil,error);
         }
         else // SOME ERROR FROM CLOUD
         {
             NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
             NSString* errorValue = @"Error from Cloud: ";
             errorValue = [errorValue stringByAppendingString:[cloudResults objectForKey:@"data"]];
             
             [errorDetail setValue:errorValue forKey:NSLocalizedDescriptionKey];
             error = [NSError errorWithDomain:@"MedicationObject:pullFromCloud" code:100 userInfo:errorDetail];
             onComplete((!error)?self:nil,error);
         }
     }];
}

-(void)deleteAllMedications
{
    NSArray* allMedications = [self FindAllObjects];
    
    for (NSDictionary* medications in allMedications)
    {
        [self deleteDatabaseDictionaryObject:medications];
    }
}

-(void)pushToCloud:(CloudCallback)onComplete
{
    
}

-(NSArray *)FindAllObjects
{
    return [self convertListOfManagedObjectsToListOfDictionaries:[self FindObjectInTable:DATABASE withCustomPredicate:nil andSortByAttribute:MEDNAME]];
}

-(NSArray *)FindAllObjectsUnderParentID:(NSString *)parentID
{
    return [self FindAllObjects];
}

-(NSArray *)covertAllSavedObjectsToJSON{
    
    NSArray* allPatients= [self FindObjectInTable:COMMONDATABASE withCustomPredicate:[NSPredicate predicateWithFormat:@"%K == YES",ISDIRTY] andSortByAttribute:MEDICATIONID];
    NSMutableArray* allObject = [[NSMutableArray alloc]initWithCapacity:allPatients.count];
    
    for (NSManagedObject* obj in allPatients)
    {
        [allObject addObject:[obj dictionaryWithValuesForKeys:[obj attributeKeys]]];
    }
    return  allObject;
}
@end