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
//  DoctorPatientViewController.h
//  Mobile Clinic
//
//  Created by sebastian a zanlongo on 2/22/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "CurrentDiagnosisTableCell.h"
#import "PreviousVisitsTableCell.h"
#import "DoctorPrescriptionCell.h"
#import "MedicineSearchCell.h"
#import "DoctorPrescriptionViewController.h"
#import "MedicineSearchViewController.h"
#import "MobileClinicFacade.h"

@interface DoctorPatientViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    ScreenHandler handler;
}

@property (strong, nonatomic) NSMutableDictionary * patientData;
@property (strong, nonatomic) NSMutableDictionary * visitationData;
@property (strong, nonatomic) NSMutableDictionary * prescriptionData;
@property (strong, nonatomic) CurrentDiagnosisViewController * diagnosisViewController;
@property (strong, nonatomic) PreviousVisitsViewController * previousVisitViewController;
@property (nonatomic, strong) DoctorPrescriptionViewController * precriptionViewController;
@property (nonatomic, strong) MedicineSearchViewController * medicineViewController;
@property (weak, nonatomic) IBOutlet UITextField *patientNameField;
@property (weak, nonatomic) IBOutlet UITextField *familyNameField;
@property (weak, nonatomic) IBOutlet UITextField *villageNameField;
@property (weak, nonatomic) IBOutlet UITextField *patientAgeField;
@property (weak, nonatomic) IBOutlet UITextField *patientSexField;
@property (weak, nonatomic) IBOutlet UIImageView *patientPhoto;
@property (weak, nonatomic) IBOutlet UILabel *patientWeightLabel;
@property (weak, nonatomic) IBOutlet UILabel *patientBPLabel;
@property (weak, nonatomic) IBOutlet UILabel *patientHRLabel;
@property (weak, nonatomic) IBOutlet UILabel *patientRespirationLabel;
@property (weak, nonatomic) IBOutlet UILabel *patientTempLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;
- (IBAction)segmentClicked:(id)sender;
@end