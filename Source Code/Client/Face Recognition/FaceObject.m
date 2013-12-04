    //
//  FaceObject.m
//  Mobile Clinic
//
//  Created by Humberto Suarez on 11/1/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#define PATIENTID   @"patientId"
#define ALLPATIENTS @"all patients"
#define DATABASE    @"Faces"

#import "BaseObject+Protected.h"
#import "FaceObjectProtocol.h"
#import "FaceObject.h"
#import "Face.h"
#import "CommonObjectProtocol.h"
//#import "UIImage+ImageVerification.h"
//#import "NSDataAdditions.h"
Face *face;
//StatusObject* tempStatusObject;

@implementation FaceObject

+(NSString*)DatabaseName{
    return DATABASE;
}
#pragma mark- Base Protocol Methods Overide
#pragma mark-
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
    
    self->COMMONID =  PATIENTID;
    self->CLASSTYPE = kFaceType;
    self->COMMONDATABASE = DATABASE;
}


-(void)UpdateObjectAndShouldLock:(BOOL)shouldLock witData:(NSMutableDictionary *)dataToSend AndInstructions:(NSInteger)instruction onCompletion:(ObjectResponse)response{
     [self UpdateObject:response shouldLock:shouldLock andSendObjects:dataToSend withInstruction:instruction];
}
#pragma mark- Public Methods
#pragma mark-

-(void)createNewObject:(NSDictionary*) object onCompletion:(ObjectResponse)onSuccessHandler
{
    
    if (![self setValueToDictionaryValues:object] || !object) {
        onSuccessHandler(nil,[self createErrorWithDescription:@"Developer Error: Misconfigured Object" andErrorCodeNumber:kErrorObjectMisconfiguration inDomain:@"Visistation Object"]);
        return;
    }
    
    // Check for patientID
    if (![databaseObject valueForKey:PATIENTID]) {
        
        // Adds an ID if it is not present
        NSString* username = [BaseObject getCurrenUserName];
        
        NSString* usernameID = [NSString stringWithFormat:@"TestUser_%f",[[NSDate date]timeIntervalSince1970]];
        
        if (username) {
            usernameID = [NSString stringWithFormat:@"%@_%f",username,[[NSDate date]timeIntervalSince1970]];
        }
        
        usernameID = [usernameID stringByReplacingOccurrencesOfString:@"." withString:@""];
        
        [databaseObject setValue:usernameID forKey:PATIENTID];
    }
    
    [self saveObject:^(id<BaseObjectProtocol> data, NSError *error) {
        onSuccessHandler(data,error);
    }];
}

-(NSArray *)FindAllObjectsLocallyFromParentObject:(NSDictionary*)parentObject{
    
    NSString* firstname = [parentObject objectForKey: FIRSTNAME];
    NSString* lastname = [parentObject objectForKey: FAMILYNAME];
    
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"%K beginswith[cd] %@ || %K beginswith[cd] %@",FIRSTNAME,firstname,FAMILYNAME,lastname];
    
    if ((!firstname && !lastname) || (firstname.length == 0 && lastname.length == 0)) {
        pred = nil;
    }
    
    return [self convertListOfManagedObjectsToListOfDictionaries:[self FindObjectInTable:DATABASE withCustomPredicate:pred andSortByAttribute:FIRSTNAME]];
}

-(void)FindAllObjectsOnServerFromParentObject:(NSDictionary*)parentObject OnCompletion:(ObjectResponse)eventResponse{
    
    [self startSearchWithData:parentObject withsearchType:kRecognize andOnComplete:eventResponse];
    
}
- (void)deleteAllFromDatabase
{

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Faces" inManagedObjectContext:[self.database managedObjectContext]];
    [fetchRequest setEntity:entity];
    //fetchRequest.predicate = [NSPredicate predicateWithFormat:@"firstName ==nil AND familyName == nil"];
    
    //fetchRequest.predicate = [NSPredicate predicateWithFormat:@"firstName == %@ AND familyName == %@",fName,lName];
    
    NSError *error;
    NSArray *listToBeDeleted = [[self.database managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    for(Face *c in listToBeDeleted)
    {
        [[self.database managedObjectContext] deleteObject:c];
    }
    error = nil;
    [[self.database managedObjectContext] save:&error];
}

-(void)syncAllPatientsAndVisits{
    
}

-(void) SyncAllOpenPatietnsOnServer:(ObjectResponse)Response{
    
    [self startSearchWithData:[[NSDictionary alloc]init] withsearchType:kFindOpenObjects andOnComplete:Response];
    
}

-(NSArray*)FindAllOpenPatientsLocally{
    //Predicate to return list of Open Objects
  /* NSPredicate* pred = [NSPredicate predicateWithFormat:@"%K == TRUE",ISOPEN];
    
    return [self convertListOfManagedObjectsToListOfDictionaries:[self FindObjectInTable:DATABASE withCustomPredicate:pred andSortByAttribute:FAMILYNAME]];*/
    }
#pragma mark- Internal Private Methods
#pragma mark-


-(void)linkPatient{
    face = (Face*)self->databaseObject;
}
-(NSArray *)covertAllSavedObjectsToJSON{
    
   /*NSMutableArray* allObject = [NSMutableArray arrayWithArray:[self ConvertAllEntriesToJSON]];
    
    for (NSMutableDictionary* obj in allObject) {
        
        NSData* picture = [obj objectForKey:PICTURE];
        
        if ([picture isKindOfClass:[NSData class]]) {
            // Convert the picture to string
            NSString* picString = [picture base64Encoding];
            
            [obj setValue:picString forKey:PICTURE];
        }
        
        //id fingerData = [obj objectForKey:FINGERDATA];
        
        //if ([fingerData isKindOfClass:[NSData class]] ) {
            //convert finger data to string
          //  [obj setValue:[fingerData base64Encoding] forKey:FINGERDATA];
        }
    }
    return allObject;*/
}
//TODO: Need a method to push all patients to the server
@end

