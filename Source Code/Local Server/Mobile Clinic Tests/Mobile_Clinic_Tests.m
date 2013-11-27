//
//  Mobile_Clinic_Tests.m
//  Mobile Clinic Tests
//
//  Created by James Mendez on 10/15/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//
#import <XCTest/XCTest.h>
#import "BaseObject.h"

@interface Mobile_Clinic_Tests : XCTestCase

@end

@implementation Mobile_Clinic_Tests
{
    NSDictionary *_patientJSON;
    id<BaseObjectProtocol> underTest;
    NSMutableDictionary* testObject;
}

- (void)setUp
{
    NSURL *dataServiceURL = [[NSBundle bundleForClass:self.class] URLForResource:@"PatientFile" withExtension:@"json"];
    
    NSData *sampleData = [NSData dataWithContentsOfURL:dataServiceURL];
    NSError *error;
    
    id json = [NSJSONSerialization JSONObjectWithData:sampleData options:kNilOptions error:&error];
    XCTAssertNotNil(json, @"invalid test data");
    
    _patientJSON = json;
}

- (void)tearDown
{
    _patientJSON = nil;
}

- (void)testLoadingPatientJSON
{
    [underTest initAndFillWithNewObject:_patientJSON];
}
@end