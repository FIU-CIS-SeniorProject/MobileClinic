//
//  PatientObjectTest.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 3/6/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "PatientObject.h"
#import "ServerCore.h"
#import "StatusObject.h"
@interface PatientObjectTest: GHAsyncTestCase {
    NSString* systemUser;
    ServerCore* server;
    PatientObject* testObject;
   __block NSMutableDictionary* testPatient;
    NSDate* date;
}

@end

@implementation PatientObjectTest

- (BOOL)shouldRunOnMainThread {
    // By default NO, but if you have a UI test or test dependent on running on the main thread return YES.
    // Also an async test that calls back on the main thread, you'll probably want to return YES.
    return YES;
}

- (void)setUpClass {
   // server = [[ServerCore alloc]init];
   // [server startClient];
    // - DO NOT COMMENT: IF YOUR RESTART YOUR SERVER IT WILL PLACE DEMO PATIENTS INSIDE TO HELP ACCELERATE YOUR TESTING
    // - YOU CAN SEE WHAT PATIENTS ARE ADDED BY CHECKING THE PatientFile.json file
/*
    NSError* err = nil;
    
    NSString* dataPath = [[NSBundle mainBundle] pathForResource:@"PatientFile" ofType:@"json"];
    
    NSArray* patients = [NSArray arrayWithArray:[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath]options:0 error:&err]];
    
    NSLog(@"Imported Patients For Testing: %@", patients);
    
    [patients enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        PatientObject *base = [[PatientObject alloc]init];
                
        if([base setValueToDictionaryValues:obj])
            [base saveObject:^(id<BaseObjectProtocol> data, NSError *error) {
            
            }];
    }];
 */
    systemUser = @"montaque22";
    [[NSUserDefaults standardUserDefaults]setObject:systemUser forKey:CURRENT_USER];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)tearDownClass {
    // - YOU CAN SEE WHAT PATIENTS ARE ADDED BY CHECKING THE PatientFile.json file
   /*
    NSError* err = nil;
   
    NSString* dataPath = [[NSBundle mainBundle] pathForResource:@"PatientFile" ofType:@"json"];
    
    NSArray* patients = [NSArray arrayWithArray:[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath]options:0 error:&err]];
    
    NSLog(@"Imported Patients For Testing: %@", patients);
    
    [patients enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
       
        PatientObject *base = [[PatientObject alloc]init];
        
        [base deleteDatabaseDictionaryObject:obj];
    }];
   */
    [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:CURRENT_USER];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)setUp {
    date = [NSDate date];
    testObject = [[PatientObject alloc]init];
    testPatient = [[NSMutableDictionary alloc]initWithCapacity:5];
    [testPatient setValue:@"Tiffy" forKey:FIRSTNAME];
    [testPatient setValue:@"Cinder" forKey:FAMILYNAME];
    [testPatient setValue:@"Alaska" forKey:VILLAGE];
    [testPatient setValue:[date convertNSDateToSeconds] forKey:DOB];
    [testPatient setValue:[NSNumber numberWithInteger:0] forKey:SEX];
}

- (void)tearDown {
    [testObject deleteDatabaseDictionaryObject:testPatient];
    testObject = nil;
    testPatient = nil;
    
}
/**
 * Given a PatientObject
 * And the dictionary contains an illegal value
 [testPatient setValue:@"Tiffy" forKey:FIRSTNAME];
 [testPatient setValue:@"Cinder" forKey:FAMILYNAME];
 [testPatient setValue:@"Alaska" forKey:VILLAGE];
 [testPatient setValue:[date convertNSDateToSeconds] forKey:DOB];
 [testPatient setValue:[NSNumber numberWithInteger:0] forKey:SEX];
 * When i call CreateNewObject
 * Then i should be able to find Tiffy
 */
- (void)testCreateAndFindNewObjectLocallySunny{

    [testObject createNewObject:testPatient onCompletion:^(id<BaseObjectProtocol> data, NSError *error) {
       NSArray* allPatients = [testObject FindAllObjectsLocallyFromParentObject:testPatient];
        id patient = allPatients.lastObject;
        id pID = [patient objectForKey:@"patientId"];
        [patient removeObjectForKey:@"patientId"];
        GHAssertEqualObjects(testPatient, patient, @"Should return the same object");\
        GHAssertNotNil(pID, @"A patient Id must exist");
    }];
}
/**
 * Given a PatientObject
 * And the dictionary contains an illegal value
 [testPatient setValue:@"Supposed to be an integer" forKey:DOB];
 * When i call CreateNewObject
 * then i should recieve an error code = kErrorObjectMisconfiguration
 */
- (void)testCreateAndFindNewObjectLocallyRainy{
    [testPatient setValue:@"Supposed to be an integer" forKey:DOB];
    
    [testObject createNewObject:testPatient onCompletion:^(id<BaseObjectProtocol> data, NSError *error) {
        NSInteger ec = error.code;

        GHAssertEqualObjects([NSNumber numberWithInteger:kErrorObjectMisconfiguration],[NSNumber numberWithInteger:ec], @"Should be misconfigured object error");
    }];
}
/**
 * Given a PatientObject
 * And the dictionary contains an illegal value
 * [testPatient setValue:@"Supposed to be an integer" forKey:DOB];
 * When i call CreateNewObject
 * then i should recieve an error code = kErrorObjectMisconfiguration
 */
- (void)testLocalLockingPatients{

    [testObject createNewObject:testPatient onCompletion:^(id<BaseObjectProtocol> data, NSError *error) {
        
        [testObject UpdateObjectAndShouldLock:YES witData:testPatient AndInstructions:kUpdateObject onCompletion:^(id<BaseObjectProtocol> data, NSError *error) {
            
            NSArray* allPatients = [testObject FindAllObjectsLocallyFromParentObject:testPatient];
            
            id patient = allPatients.lastObject;
            NSString* lockedBy = [patient objectForKey:ISLOCKEDBY];
            NSInteger ec = error.code;
            
            GHAssertEqualStrings(lockedBy, systemUser, @"Should be the same user");
            GHAssertTrue((ec == kErrorDisconnected), @"Should give Disconnected error");   
            
        }];

    }];
}
/**
 * Given a PatientObject
 * And the dictionary contains no primary key id
 * When i call CreateNewObject
 * then i should recieve an error code = kErrorObjectMisconfiguration
 */
- (void)testSaveWithOutPrimaryKeyID{
    [testObject setValueToDictionaryValues:testPatient];
    
    [testObject saveObject:^(id<BaseObjectProtocol> data, NSError *error) {

        NSInteger ec = error.code;
            
        GHAssertEqualObjects([NSNumber numberWithInteger:kErrorObjectMisconfiguration],[NSNumber numberWithInteger:ec], @"Should be misconfigured object error");
        GHAssertEqualStrings(@"Object was not assigned a primary key ID", error.localizedDescription, @"Error message should be about the primary key not being assigned");

    }];
}
/**
 * Given a PatientObject
 * And the dictionary contains a unexpected type for a attribute
 * When i call CreateNewObject
 * then it should return false
 */
- (void)testSettingIllegalValuesIntoPatientObject{
    
    [testPatient setValue:[NSData data] forKey:DOB];
    
   BOOL success = [testObject setValueToDictionaryValues:testPatient];
    
    GHAssertFalse(success, @"Shoud not be a success");
}

@end