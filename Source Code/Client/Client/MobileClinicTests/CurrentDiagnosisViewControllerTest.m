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
//  CurrentDiagnosisViewControllerTest.m
//  Mobile Clinic
//
//  Created by Rigo Hernandez on 3/19/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//
#import <GHUnitIOS/GHUnit.h>
#import "MobileClinicFacade.h"
#import "DoctorPatientViewController.h"
#import "DoctorPrescriptionViewController.h"
#import "MedicineSearchViewController.h"

@interface CurrentDiagnosisViewControllerTest: GHAsyncTestCase
@end

NSMutableDictionary * patientData;
NSMutableDictionary * visitData;
DoctorPatientViewController * doctorView;
CurrentDiagnosisViewController * currentDiagView;
MobileClinicFacade * mobileFacade;

@implementation CurrentDiagnosisViewControllerTest

- (void)setUpClass
{
    // Run at beginning of all tests in the class
    patientData = [[NSMutableDictionary alloc]init];
    visitData = [[NSMutableDictionary alloc]init];
    
    [patientData setObject:[NSDate date] forKey:DOB];
    [patientData setObject:@"Hernandez" forKey:FAMILYNAME];
    [patientData setObject:@"Rigo" forKey:FIRSTNAME];
    [patientData setObject:@"admin" forKey:ISLOCKEDBY];
    [patientData setObject:[NSNumber numberWithInt:1] forKey:ISOPEN];
    [patientData setObject:@"rigo.hernandez.1" forKey:PATIENTID];
    [patientData setObject:[NSNumber numberWithInt:1] forKey:SEX];
    [patientData setObject:@"Kendall" forKey:VILLAGE];
    [visitData setObject:@"120/80" forKey:BLOODPRESSURE];
    [visitData setObject:@"This is a condition for the patient" forKey:CONDITION];
    [visitData setObject:@"admin" forKey:DOCTORID];
    [visitData setObject:[NSDate date] forKey:DOCTORIN];
    [visitData setObject:@"70" forKey:HEARTRATE];
    [visitData setObject:@"admin" forKey:ISLOCKEDBY];
    [visitData setObject:[NSNumber numberWithInt:1] forKey:ISOPEN];
    [visitData setObject:@"admin" forKey:NURSEID];
    [visitData setObject:[NSNumber numberWithInt:1] forKey:PRIORITY];
    [visitData setObject:@"30" forKey:RESPIRATION];
    [visitData setObject:@"rigo.hernandez.010113" forKey:VISITID];
    [visitData setObject:[NSNumber numberWithDouble:180.0] forKey:WEIGHT];
    [visitData setObject:patientData forKey:@"open visits"];
    doctorView = [DoctorPatientViewController getViewControllerFromiPadStoryboardWithName:@"doctorPatientViewController"];
    [doctorView setPatientData:visitData];
    [doctorView view];
}

- (void)tearDownClass
{
    // Run at end of all tests in the class
    patientData = nil;
    visitData = nil;
    doctorView = nil;
}

- (void)setUp
{
    // Run before each test method
    mobileFacade = [[MobileClinicFacade alloc]init];
    currentDiagView = [[CurrentDiagnosisViewController alloc]init];
}

- (void)tearDown
{
    // Run after each test method
    mobileFacade = nil;
    currentDiagView = nil;
}

//- (void)testNoPatientDataPassed
//{
//    
//}

- (void)testDiagnosisLeftBlank
{
    
}
@end