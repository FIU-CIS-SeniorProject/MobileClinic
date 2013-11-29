//
//  RegisterPatientViewControllerTest.m
//  Mobile Clinic
//
//  Created by sebastian a zanlongo on 3/28/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "MobileClinicFacade.h"
#import "RegisterPatientViewController.h"

@interface RegisterPatientViewControllerTest: GHAsyncTestCase

@end

NSMutableDictionary * patientData;
RegisterPatientViewController *newView;

@implementation RegisterPatientViewControllerTest

- (void)setUpClass {
    // Run at beginning of all tests in the class
    newView = [RegisterPatientViewController getViewControllerFromiPadStoryboardWithName:@"registerPatientViewController"];
    
    newView.patientNameField.text = @"Rigo";
    newView.familyNameField.text = @"Hernandez";
    newView.villageNameField.text = @"Kendall";
    newView.patientSexSegment.selectedSegmentIndex = 1;
}

- (void)tearDownClass {
    // Run at end of all tests in the class
    patientData = nil;
    newView = nil;
}

- (void)setUp {
    // Run before each test method
    if ([newView validateRegistration]) {
        [newView createPatient:nil];
        patientData = newView.patient;
    }
}

- (void)tearDown {
    // Run after each test method
    patientData = nil;
}

- (void) testCreateNewPatient {
    GHAssertEqualStrings([patientData objectForKey:FIRSTNAME], @"Rigo", @"Patient's Name should be Rigo");
    GHAssertEqualStrings([patientData objectForKey:FAMILYNAME], @"Hernandez", @"Patient's Family Name should be Hernandez");
    GHAssertEqualStrings([patientData objectForKey:VILLAGE], @"Kendall", @"Patient's Village should be Kendall");
    GHAssertEqualStrings([patientData objectForKey:SEX], [NSNumber numberWithInt:1], @"Patient's Sex should be Male (1)");
}

@end
