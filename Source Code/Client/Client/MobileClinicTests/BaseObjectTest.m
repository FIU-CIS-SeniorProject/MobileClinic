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
//  BaseObjectTest.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 3/12/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//
#import <GHUnitIOS/GHUnit.h> 
#import "BaseObject.h"
#import "PatientObject.h"

@interface BaseObjectTest : GHTestCase
{
    PatientObject* base;
    NSMutableDictionary* testData;
}
@end

NSString* PATIENTID;
@implementation BaseObjectTest

- (void)setUpClass
{
    PATIENTID  = @"patientId";
    // [server startClient];
}

- (void)tearDownClass
{
    // Run at end of all tests in the class
}

- (void)setUp
{
    base = [[PatientObject alloc]init];
    
    testData = [[NSMutableDictionary alloc]initWithCapacity:5];
  
    [testData setValue:@"Michael" forKey:FIRSTNAME];
    [testData setValue:@"Montaque" forKey:FAMILYNAME];
    [testData setValue:@"Village" forKey:VILLAGE];
    [testData setValue:@"Michael.9084" forKey:PATIENTID];
    [testData setValue:[NSNumber numberWithInt:1] forKey:SEX];
}

- (void)tearDown
{
    // Run after each test method
}

- (void) testUnpackagingFileForUser
{
    [base unpackageFileForUser:[NSDictionary dictionaryWithObjectsAndKeys:testData,DATABASEOBJECT, nil]];
    //GHAssertEqualStrings([base->databaseObject valueForKey:PATIENTID], @"Michael.908", @"Patient's ID should be Michael.9084");
}
@end