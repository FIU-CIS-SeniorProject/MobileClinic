//
//  UserObjectTest.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 3/31/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import "UserObject.h"

@interface UserObjectTest : GHTestCase {
    id<CommonObjectProtocol, UserObjectProtocol> objectUnderTest;
    NSMutableDictionary* testUser;
}
@end

@implementation UserObjectTest

- (void)setUpClass {
    // Run at start of all tests in the class
}

- (void)tearDownClass {
    // Run at end of all tests in the class
}

- (void)setUp {
    objectUnderTest = [[UserObject alloc]init];
    
    /* Setup test user */
    testUser = [[NSMutableDictionary alloc]initWithCapacity:8];
    [testUser setValue:@"Kelly01" forKey:USERNAME];
    [testUser setValue:@"Kelly01@me.com" forKey:EMAIL];
    [testUser setValue:@"Kelly" forKey:FIRSTNAME];
    [testUser setValue:@"Jackson" forKey:LASTNAME];
    [testUser setValue:[NSNumber numberWithInt:kDoctor] forKey:USERTYPE];
    [testUser setValue:@"12345" forKey:PASSWORD];
    [testUser setValue:[NSNumber numberWithInt:111] forKey:SECONDARYTYPE];
    [testUser setValue:[NSNumber numberWithBool:YES] forKey:STATUS];
}

- (void)tearDown {
    [objectUnderTest deleteDatabaseDictionaryObject:testUser];
    testUser = nil;
    objectUnderTest = nil;
    
}
/**
 * Case: setting a user object with valid user
 * Given that the dictionary object valid information
 * [testUser setValue:@"Kelly01" forKey:USERNAME];
 * [testUser setValue:@"Kelly01@me.com" forKey:EMAIL];
 * [testUser setValue:@"Kelly" forKey:FIRSTNAME];
 * [testUser setValue:@"Jackson" forKey:LASTNAME];
 * [testUser setValue:[NSNumber numberWithInt:kDoctor] forKey:USERTYPE];
 * [testUser setValue:@"12345" forKey:PASSWORD];
 * [testUser setValue:[NSNumber numberWithInt:111] forKey:SECONDARYTYPE];
 * [testUser setValue:[NSNumber numberWithBool:YES] forKey:STATUS];
 * When the setValueToDictionaryValues is called
 * Then success should be true
 */
- (void)testSetAndGetDictionaryValuesFromManagedObjectSunny {
    
   NSError* success = [objectUnderTest setValueToDictionaryValues:testUser];
    
    NSDictionary* actual = [objectUnderTest getDictionaryValuesFromManagedObject];
    
    GHAssertEqualObjects(testUser, actual, @"Getting values from userObject should be the same as testUser Dictionary");
    
    GHTestLog(@"EXPECTED DICTIONARY: %@ \n\n ACTUAL: %@",testUser,actual);
    
    //GHAssertTrue(success, @"Should be true");
    
    GHTestLog(@"EXPECTED: TRUE\n\n ACTUAL: %@",(success)?@"TRUE":@"FALSE");
}
/**
 * Case: setting a user object with a bad user
 * Given that the dictionary object has a bad value
 * When the setValueToDictionaryValues is called
 * Then success should be false
 */
- (void)testSetAndGetDictionaryValuesFromManagedObjectRainy {
    
    [testUser setValue:@"Supposed to be a number" forKey:SECONDARYTYPE];
    
    NSError* success = [objectUnderTest setValueToDictionaryValues:testUser];
    
    NSDictionary* actual = [objectUnderTest getDictionaryValuesFromManagedObject];
    
    [testUser setValue:[NSNumber numberWithInt:0] forKey:SECONDARYTYPE];
    
    GHAssertEqualObjects(testUser, actual, @"Actual should be empty");
     
    GHTestLog(@"EXPECTED DICTIONARY:\n %@ \n\n UNEXPECTED ACTUAL:\n %@",testUser,actual);
    
   // GHAssertNil(success, @"There should be no problems");

}
/**
 * Case: saving and finding a user
 * Given that a dictionary object have a valid user
 * [testUser setValue:@"Kelly01" forKey:USERNAME];
 * [testUser setValue:@"Kelly01@me.com" forKey:EMAIL];
 * [testUser setValue:@"Kelly" forKey:FIRSTNAME];
 * [testUser setValue:@"Jackson" forKey:LASTNAME];
 * [testUser setValue:[NSNumber numberWithInt:kDoctor] forKey:USERTYPE];
 * [testUser setValue:@"12345" forKey:PASSWORD];
 * [testUser setValue:[NSNumber numberWithInt:111] forKey:SECONDARYTYPE];
 * [testUser setValue:[NSNumber numberWithBool:YES] forKey:STATUS];
 * And the information is added to the userObject
 * When the SaveObject is called
 * Then after searching the same user should be found
 */
- (void)testSavingAndFindingObjects {
    
   NSError* err = [objectUnderTest setValueToDictionaryValues:testUser];
    
    [objectUnderTest saveObject:nil];
    
    NSArray* allObjects = [[objectUnderTest FindAllObjects]filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"userName == %@",[testUser objectForKey:USERNAME]]];
    
    id actual = [allObjects lastObject];

    GHAssertEqualObjects(testUser, actual, @"Getting values from userObject should be the same as testUser Dictionary");
    
    GHTestLog(@"EXPECTED DICTIONARY: %@ \n\n ACTUAL: %@",testUser,actual);
    
    GHAssertNil(err, @"There should have been no problems");
}

/**
 * Case: When a bad object is recieved through the Client Server command interface
 * Given that a nil dictionary object
 * When the SeverCommand is called
 * Then the completion handler should return an error dictionary object 
 */
- (void)testClientServerCommandInterfaceForBadCommandSent {
    
    [objectUnderTest ServerCommand:nil withOnComplete:^(NSDictionary *dataToBeSent) {

        StatusObject* status = [[StatusObject alloc]init];
        [status setErrorMessage:@"Server Error: The object sent was not configured properly"];
        [status setObjectType:kUserType];
        [status setStatus:kErrorObjectMisconfiguration];
       
        NSDictionary* expected = [status consolidateForTransmitting];
       
        GHAssertEqualObjects(expected, dataToBeSent, @"Getting values from userObject should be the same as testUser Dictionary");
        
        GHTestLog(@"EXPECTED DICTIONARY: %@ \n\n ACTUAL: %@",expected,dataToBeSent);
    }];
}


@end
