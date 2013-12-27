//
//  PrescriptionObject.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 3/11/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import "PrescriptionObject.h"
#import "BaseObject+Protected.h"
#import "CloudManagementObject.h"

#define DATABASE    @"Prescriptions"

NSString* visitID;
NSString* isLockedBy;
@implementation PrescriptionObject

#pragma mark - BaseObjectProtocol Methods
#pragma mark -

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

-(void)setupObject{
    
    self->COMMONID =  PRESCRIPTIONID;
    self->CLASSTYPE = kPrescriptionType;
    self->COMMONDATABASE = DATABASE;
}

-(void)ServerCommand:(NSDictionary *)dataToBeRecieved withOnComplete:(ServerCommand)response{
    [super ServerCommand:nil withOnComplete:response];
    [self unpackageFileForUser:dataToBeRecieved];
    [self CommonExecution];
}

-(void)unpackageFileForUser:(NSDictionary *)data{
    [super unpackageFileForUser:data];
    visitID = [self->databaseObject valueForKey:VISITID];
}


-(void)CommonExecution
{
    switch (self->commands) {
        case kAbort:
            break;
        case kUpdateObject:
            [super UpdateObjectAndSendToClient];
            break;
        case kFindObject:
            [self sendSearchResults:[self FindAllObjectsLocallyFromParentObject]];            break;
        default:
            break;
    }
}

#pragma mark - COMMON OBJECT Methods
#pragma mark -
-(NSArray *)FindAllObjects{
    return [self convertListOfManagedObjectsToListOfDictionaries:[self FindObjectInTable:DATABASE withCustomPredicate:nil andSortByAttribute:PRESCRIBETIME]];
}
-(NSArray *)FindAllObjectsLocallyFromParentObject{
    
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"%K == %@",VISITID,visitID];
    
    return [self convertListOfManagedObjectsToListOfDictionaries:[self FindObjectInTable:DATABASE withCustomPredicate:pred andSortByAttribute:PRESCRIBETIME]];
}

-(NSArray *)FindAllObjectsUnderParentID:(NSString *)parentID{
    visitID = parentID;
    return [self FindAllObjectsLocallyFromParentObject];
}
-(NSAttributedString *)printFormattedObject:(NSDictionary *)object{

    
    NSMutableAttributedString* container = [[NSMutableAttributedString alloc]init];
    /*
    for (NSString* key in object.allKeys) {
        
        NSString* main = [NSString stringWithFormat:@"%@:\n",key];
        
        NSMutableAttributedString* line1 = [[NSMutableAttributedString alloc]initWithString:main];
        
        [line1 addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"HelveticaNeue-Bold" size:16.0] range:[main rangeOfString:main]];
    

        NSString* secondary = [NSString stringWithFormat:@"%@:\n",[[object objectForKey:key] description]];
        
        NSMutableAttributedString* line2 = [[NSMutableAttributedString alloc]initWithString:secondary];
        
        [line2 addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"HelveticaNeue" size:14.0] range:[secondary rangeOfString:secondary]];
        
        [line1 appendAttributedString:line2];
        
        [container appendAttributedString:line1];
    }
    
    return container;
    */
NSString* main = [NSString stringWithFormat:@" Medication Name:\t%@ \n Dose:\t%@ \n Notes:\t%@ \n ",[object objectForKey:MEDNAME],[object objectForKey:TABLEPERDAY],[object objectForKey:INSTRUCTIONS]];
    
    NSMutableAttributedString* line1 = [[NSMutableAttributedString alloc]initWithString:main];
    
    [line1 addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"HelveticaNeue" size:16.0] range:[main rangeOfString:main]];
    
    [container appendAttributedString:line1];
    
    return container;
}
-(NSArray *)covertAllSavedObjectsToJSON{
    
    NSArray* allPatients= [self FindObjectInTable:COMMONDATABASE withCustomPredicate:[NSPredicate predicateWithFormat:@"%K == YES",ISDIRTY] andSortByAttribute:PRESCRIPTIONID];
    NSMutableArray* allObject = [[NSMutableArray alloc]initWithCapacity:allPatients.count];
    
    for (NSManagedObject* obj in allPatients) {
        [allObject addObject:[obj dictionaryWithValuesForKeys:[obj attributeKeys]]];
    }
    return  allObject;
}

-(void)pushToCloud:(CloudCallback)onComplete
{
    NSArray* allPrescriptions = [self convertListOfManagedObjectsToListOfDictionaries:[self FindObjectInTable:COMMONDATABASE withCustomPredicate:[NSPredicate predicateWithFormat:@"%K == YES",ISDIRTY] andSortByAttribute:PRESCRIPTIONID]];
    
    [self makeCloudCallWithCommand:UPDATEPRESCRIPTION withObject:[NSDictionary dictionaryWithObject:allPrescriptions forKey:DATABASE] onComplete:^(id cloudResults, NSError *error)
     {
         [self handleCloudCallback:onComplete UsingData:allPrescriptions WithPotentialError:error];
     }];
}
-(void)pullFromCloud:(CloudCallback)onComplete
{
    // allocate and init a CloudManagementObject for timestamp
    CloudManagementObject* TSCloudMO = [[CloudManagementObject alloc] init];
    NSNumber* timestamp = [TSCloudMO GetActiveTimestamp];
    NSMutableDictionary* timeDic = [[NSMutableDictionary alloc] init];
    [timeDic setObject:timestamp forKey:@"Timestamp"];
    
    //TODO: replace "withObject:nil" with timestamp dictionary
    [self makeCloudCallWithCommand:DATABASE withObject:timeDic onComplete:^(id cloudResults, NSError *error)
     {
         /*NSArray* allPrescriptions = [cloudResults objectForKey:@"data"];
          if ([allPrescriptions count] > 0)
          {
          [self handleCloudCallback:onComplete UsingData:allPrescriptions WithPotentialError:error];
          }*/
         
         if (cloudResults == nil) // NO CLOUD CONNECTION
         {
             NSString* errorValue = @"No connection to the Cloud";
             NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
             [errorDetail setValue:errorValue forKey:NSLocalizedDescriptionKey];
             error = [NSError errorWithDomain:@"PrescriptionObject:pullFromCloud" code:100 userInfo:errorDetail];
             onComplete((!error)?self:nil,error);
         }
         else if ([[cloudResults objectForKey:@"result"] isEqualToString:@"true"]) // SUCCESS
         {
             NSArray* prescriptionsFromCloud = [cloudResults objectForKey:@"data"];
             [self handleCloudCallback:onComplete UsingData:prescriptionsFromCloud WithPotentialError:error];
             /*NSArray* allError = [self SaveListOfObjectsFromDictionary:prescriptionsFromCloud];
              
              if (allError.count > 0)
              {
              error = [[NSError alloc]initWithDomain:COMMONDATABASE code:kErrorObjectMisconfiguration userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Object was misconfigured",NSLocalizedFailureReasonErrorKey, nil]];
              onComplete(self,error);
              return;
              }//*/
         }
         else // SOME ERROR FROM CLOUD
         {
             NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
             NSString* errorValue = @"Error from Cloud: ";
             errorValue = [errorValue stringByAppendingString:[cloudResults objectForKey:@"data"]];
             
             [errorDetail setValue:errorValue forKey:NSLocalizedDescriptionKey];
             error = [NSError errorWithDomain:@"PrescriptionObject:pullFromCloud" code:100 userInfo:errorDetail];
             onComplete((!error)?self:nil,error);
         }
         
         /*if (!error)
          {
          NSArray* allPrescriptions = [cloudResults objectForKey:@"data"];
          
          NSArray* allError = [self SaveListOfObjectsFromDictionary:allMeds];
          
          if (allError.count > 0)
          {
          error = [[NSError alloc]initWithDomain:COMMONDATABASE code:kErrorObjectMisconfiguration userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Object was misconfigured",NSLocalizedFailureReasonErrorKey, nil]];
          onComplete(self,error);
          return;
          }
          }
          onComplete((!error)?self:nil,error);//*/
     }];
}
/*-(void)pullFromCloud:(CloudCallback)onComplete
{
    // allocate and init a CloudManagementObject for timestamp
    CloudManagementObject* TSCloudMO = [[CloudManagementObject alloc] init];
    NSNumber* timestamp = [TSCloudMO GetActiveTimestamp];
    NSMutableDictionary* timeDic = [[NSMutableDictionary alloc] init];
    [timeDic setObject:timestamp forKey:@"Timestamp"];
    
    //TODO: replace "withObject:nil" with timestamp dictionary
    [self makeCloudCallWithCommand:DATABASE withObject:timeDic onComplete:^(id cloudResults, NSError *error)
     {
         NSArray* allPrescriptions = [cloudResults objectForKey:@"data"];
         [self handleCloudCallback:onComplete UsingData:allPrescriptions WithPotentialError:error];
         
     }];
}*/
@end