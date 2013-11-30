//
//  SmokeTest.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 3/31/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//
#import <GHUnit/GHUnit.h>

@interface SmokeTest : GHTestCase { }
@end

@implementation SmokeTest

- (void)testStrings {
    NSString *string1 = @"a string";
    GHTestLog(@"I can log to the GHUnit test console: %@", string1);
    
    // Assert string1 is not NULL, with no custom error description

    GHAssertNotNULL((__bridge void*)string1, nil);
    
    // Assert equal objects, add custom error description
    NSString *string2 = @"a string";
    GHAssertEqualObjects(string1, string2, @"A custom error message. string1 should be equal to: %@.", string2);
}

@end
