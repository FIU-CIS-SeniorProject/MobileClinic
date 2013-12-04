//
//  PatientObjectTest.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 4/7/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

//
//  BaseObject+Protected.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 4/5/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//
#import "PatientObject.h"

#import <GHUnit/GHUnit.h>

@interface PatientObjectTest : GHTestCase {
    id<PatientObjectProtocol,BaseObjectProtocol> underTest;
    NSMutableDictionary* testObject;
}
@end

@implementation PatientObjectTest

- (void)setUpClass {
    // Run at start of all tests in the class
}

- (void)tearDownClass {
    // Run at end of all tests in the class
}

- (void)setUp {
    underTest = [[PatientObject alloc]init];
    
    /* Setup test user */
    testObject = [[NSMutableDictionary alloc]initWithCapacity:9];
    [testObject setValue:@"Daniel" forKey:FIRSTNAME];
    [testObject setValue:@"Dover" forKey:FAMILYNAME];
    [testObject setValue:[NSNumber numberWithInt:1032853245] forKey:DOB];
    [testObject setValue:[NSNumber numberWithInt:1] forKey:SEX];
    [testObject setValue:@"JamesFortune_1834257321" forKey:PATIENTID];
    [testObject setValue:[NSNumber numberWithBool:YES] forKey:ISOPEN];
    [testObject setValue:@"Wispy Meadow" forKey:VILLAGE];
    [testObject setValue:@"Rachel01" forKey:ISLOCKEDBY];
    [testObject setValue:[NSNumber numberWithBool:YES] forKey:STATUS];
}

- (void)tearDown {
    [underTest deleteDatabaseDictionaryObject:testObject];
    testObject = nil;
    underTest = nil;
    
}
-(void) testUnlockingPatients{
    [underTest setValueToDictionaryValues:testObject];
    [underTest UnlockPatient:^(id<BaseObjectProtocol> data, NSError *error) {
        NSDictionary* modifiedPatient = [data getDictionaryValuesFromManagedObject];
        [testObject setValue:@"" forKey:ISLOCKEDBY];
        GHAssertEqualObjects(testObject, modifiedPatient, @"The value for ISLOCKEDBY should be empty");
    }];
}

-(void) testSavingAndFindingPatients{
    
    [underTest setValueToDictionaryValues:testObject];
    
    [underTest saveObject:^(id<BaseObjectProtocol> data, NSError *error) {
        
        NSArray* allPatients = [[underTest FindAllOpenPatients]filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"patientId == %@",[testObject objectForKey:PATIENTID]]];
        
        
        id patient = allPatients.lastObject;

        GHAssertEqualObjects(testObject, patient, @"Should return the same object");

    }];

}

-(void) testSendingBadCommands{
    
   [underTest ServerCommand:nil withOnComplete:^(NSDictionary *dataToBeSent) {
       StatusObject* status = [[StatusObject alloc]init];
       [status setErrorMessage:@"Server Error: The object sent was not configured properly"];
       [status setObjectType:kPatientType];
       [status setStatus:kErrorObjectMisconfiguration];
       
       NSDictionary* expected = [status consolidateForTransmitting];
       
       GHAssertEqualObjects(expected, dataToBeSent, @"Getting values from PatientObject should be the same as testObject Dictionary");
       
       GHTestLog(@"EXPECTED DICTIONARY: %@ \n\n ACTUAL: %@",expected,dataToBeSent);
   }];
    
}

-(void) testCreatingPatientsWithoutCreatingDuplicates{
    
    [underTest setValueToDictionaryValues:testObject];
    
    [underTest saveObject:^(id<BaseObjectProtocol> data, NSError *error) {
       
        NSArray* allPatients = [[underTest FindAllOpenPatients]filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"patientId == %@",[testObject objectForKey:PATIENTID]]];
        
        id patient = allPatients.lastObject;
        
        GHAssertEqualObjects(testObject, patient, @"Should return the same object");
        
        GHAssertTrue((allPatients.count == 1), @"There should be only one patient");
    }];
    
    [testObject setValue:@"Lady" forKey:FIRSTNAME];
    [testObject setValue:@"Howard" forKey:FAMILYNAME];
    [testObject setValue:[NSNumber numberWithInt:1032845] forKey:DOB];
    [testObject setValue:[NSNumber numberWithInt:0] forKey:SEX];
    [testObject setValue:[NSNumber numberWithBool:YES] forKey:ISOPEN];
    [testObject setValue:@"Wispy" forKey:VILLAGE];
    [testObject setValue:@"Rac01" forKey:ISLOCKEDBY];
    [testObject setValue:[NSNumber numberWithBool:NO] forKey:STATUS];
    
    PatientObject* duplicate = [[PatientObject alloc]init];
    
    [duplicate setValueToDictionaryValues:testObject];
    
    [duplicate saveObject:^(id<BaseObjectProtocol> data, NSError *error) {
        
        NSArray* allPatients = [[underTest FindAllOpenPatients]filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"patientId == %@",[testObject objectForKey:PATIENTID]]];
        
        
        id patient = allPatients.lastObject;
        
        GHAssertEqualObjects(testObject, patient, @"Should return the same object");
        
        GHAssertTrue((allPatients.count == 1), @"There should be only one patient");
    }];
}

@end
