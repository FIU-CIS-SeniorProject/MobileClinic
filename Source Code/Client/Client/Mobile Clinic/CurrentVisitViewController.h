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
//  CurrentVisitViewController.h
//  Mobile Clinic
//
//  Created by sebastian a zanlongo on 2/18/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "StationViewHandlerProtocol.h"

@interface CurrentVisitViewController : UIViewController <UITextViewDelegate>
{
    ScreenHandler handler;
    NSMutableDictionary *currentVisit;
}

@property (strong, nonatomic) NSMutableDictionary *patientData;
@property (weak, nonatomic) IBOutlet UILabel *patientWeightLabel;
@property (weak, nonatomic) IBOutlet UILabel *patientWeightMeasurementLabel;
@property (strong, nonatomic) IBOutlet UITextField *patientWeightField;
@property (weak, nonatomic) IBOutlet UILabel *bloodPressureLabel;
@property (weak, nonatomic) IBOutlet UILabel *bloodPressureDivider;
@property (weak, nonatomic) IBOutlet UILabel *bloodPressureMeasurementLabel;
@property (weak, nonatomic) IBOutlet UITextField *systolicField;
@property (weak, nonatomic) IBOutlet UITextField *diastolicField;
@property (weak, nonatomic) IBOutlet UILabel *heartFieldLabel;
@property (weak, nonatomic) IBOutlet UILabel *heartMeasurementLabel;
@property (weak, nonatomic) IBOutlet UITextField *heartField;
@property (weak, nonatomic) IBOutlet UILabel *respirationLabel;
@property (weak, nonatomic) IBOutlet UILabel *respirationMeasurementLabel;
@property (weak, nonatomic) IBOutlet UITextField *respirationField;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet UILabel *tempMeasurementLabel;
@property (weak, nonatomic) IBOutlet UITextField *tempField;
@property (weak, nonatomic) IBOutlet UITextField *conditionTitleField;
@property (strong, nonatomic) IBOutlet UITextView *conditionsTextbox;
@property (weak, nonatomic) IBOutlet UISegmentedControl *visitPriority;
- (IBAction)checkInButton:(id)sender;
- (IBAction)quickCheckOutButton:(id)sender;
- (BOOL)validateCheckin;
- (void)setScreenHandler:(ScreenHandler)myHandler;
@end