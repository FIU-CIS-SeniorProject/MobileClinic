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

- (void)setUpClass
{
    // Run at beginning of all tests in the class
    newView = [RegisterPatientViewController getViewControllerFromiPadStoryboardWithName:@"registerPatientViewController"];
    
    newView.patientNameField.text = @"Rigo";
    newView.familyNameField.text = @"Hernandez";
    newView.villageNameField.text = @"Kendall";
    newView.patientSexSegment.selectedSegmentIndex = 1;
}

- (void)tearDownClass
{
    // Run at end of all tests in the class
    patientData = nil;
    newView = nil;
}

- (void)setUp
{
    // Run before each test method
    if ([newView validateRegistration])
    {
        [newView createPatient:nil];
        patientData = newView.patient;
    }
}

- (void)tearDown
{
    // Run after each test method
    patientData = nil;
}

- (void) testCreateNewPatient
{
    GHAssertEqualStrings([patientData objectForKey:FIRSTNAME], @"Rigo", @"Patient's Name should be Rigo");
    GHAssertEqualStrings([patientData objectForKey:FAMILYNAME], @"Hernandez", @"Patient's Family Name should be Hernandez");
    GHAssertEqualStrings([patientData objectForKey:VILLAGE], @"Kendall", @"Patient's Village should be Kendall");
    GHAssertEqualStrings([patientData objectForKey:SEX], [NSNumber numberWithInt:1], @"Patient's Sex should be Male (1)");
}
@end