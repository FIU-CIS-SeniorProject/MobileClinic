//
//  Mobile_ClinicTests.m
//  Mobile ClinicTests
//
//  Created by Michael Montaque on 1/23/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import "Mobile_ClinicTests.h"
#import "BaseObject.h"

@implementation Mobile_ClinicTests

- (void)setUp
{
    [super setUp];

    obj = [[BaseObject alloc]init];
    semaphore = dispatch_semaphore_create(0);
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
    obj = nil;
    semaphore = nil;
}

- (void)testUsers
{
    NSLog(@"\n\nStarting testUsers\n\n");
    [obj query:@"users" parameters:nil completion:^(NSError *error, NSDictionary *result) {
         NSLog(@"\nReached Block code\n");
        if(!error){
            STAssertTrue([[result objectForKey:@"result"] isEqualToString:@"true"], @"result has returned true");
            dispatch_semaphore_signal(semaphore);
        }
    }];
    NSLog(@"\nWaiting for block code\n");
    dispatch_semaphore_wait(semaphore, 50000);
}

- (void)testCreatUsers
{
    NSLog(@"\n\nStarting testCreatUsers\n\n");
        NSMutableDictionary * mDic = [[NSMutableDictionary alloc]init];
    
        [mDic setObject:@"thisisarandomuser" forKey:@"userName"];
        [mDic setObject:@"trudat" forKey:@"password"];
        [mDic setObject:@"Bob" forKey:@"firstName"];
        [mDic setObject:@"Johnson" forKey:@"lastName"];
        [mDic setObject:@"thisisarandomuser@yahoo.com" forKey:@"email"];
        [mDic setObject:@"2" forKey:@"userType"];
       [mDic setObject:@"1" forKey:@"status"];
    [obj query:@"create_user" parameters:mDic completion:^(NSError *error, NSDictionary *result) {
        NSLog(@"\nReached Block code\n");
        if(!error){
            STAssertTrue([[result objectForKey:@"result"] isEqualToString:@"true"], (NSString *)[result objectForKey:@"message"]);
            dispatch_semaphore_signal(semaphore);
        }
    }];
    NSLog(@"\nWaiting for block code\n");
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

- (void)testCreatDuplicateUser
{
    NSLog(@"\n\nStarting testCreatDuplicateUser\n\n");
    NSMutableDictionary * mDic = [[NSMutableDictionary alloc]init];
    
    [mDic setObject:@"thisisarandomuser" forKey:@"userName"];
    [mDic setObject:@"trudat" forKey:@"password"];
    [mDic setObject:@"Bob" forKey:@"firstName"];
    [mDic setObject:@"Johnson" forKey:@"lastName"];
    [mDic setObject:@"thisisarandomuser@yahoo.com" forKey:@"email"];
    [mDic setObject:@"2" forKey:@"userType"];
    [mDic setObject:@"1" forKey:@"status"];
    [obj query:@"create_user" parameters:mDic completion:^(NSError *error, NSDictionary *result) {
        NSLog(@"\nReached Block code\n");
        if(!error){
            STAssertFalse([[result objectForKey:@"result"] isEqualToString:@"true"], (NSString *)[result objectForKey:@"message"]);
            dispatch_semaphore_signal(semaphore);
        }
    }];
    NSLog(@"\nWaiting for block code\n");
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

- (void)testUserForId
{
    NSLog(@"\n\nStarting testUserForId\n\n");
    NSMutableDictionary * mDic = [[NSMutableDictionary alloc]init];
    
    [mDic setObject:@"bobJohnsonn" forKey:@"userName"];

    [obj query:@"user_by_id" parameters:mDic completion:^(NSError *error, NSDictionary *result) {
        NSLog(@"\nReached Block code\n");
        if(!error){
            STAssertTrue([[result objectForKey:@"result"] isEqualToString:@"true"], (NSString *)[result objectForKey:@"message"]);
            dispatch_semaphore_signal(semaphore);
        }
    }];
    NSLog(@"\nWaiting for block code\n");
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

- (void)testDeactivateUser
{
    NSLog(@"\n\nStarting testDeactivateUser\n\n");
    NSMutableDictionary * mDic = [[NSMutableDictionary alloc]init];
    
    [mDic setObject:@"thisisarandomuser" forKey:@"userName"];
    
    [obj query:@"deactivate_user" parameters:mDic completion:^(NSError *error, NSDictionary *result) {
        NSLog(@"\nReached Block code\n");
        if(!error){
            NSDictionary *data = [result objectForKey:@"data"];
            STAssertTrue([[data objectForKey:@"status"] isEqualToNumber:[NSNumber numberWithInt:0]], (NSString *)[result objectForKey:@"message"]);
            dispatch_semaphore_signal(semaphore);
        }
    }];
    NSLog(@"\nWaiting for block code\n");
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

@end
