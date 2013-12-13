//
//  CurrentVisitViewController.h
//  Mobile Clinic
//
//  Created by sebastian a zanlongo on 2/18/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//
#define SET_DELEGATE @"set delegate"
#import <UIKit/UIKit.h>
#import "CancelDelegate.h"
#import "StationViewHandlerProtocol.h"


@interface CurrentVisitViewController : UIViewController <UITextViewDelegate,CancelDelegate> {
    ScreenHandler handler;
    NSMutableDictionary *currentVisit;
}
- (IBAction)addPicture2:(id)sender;
- (IBAction)addPicture3:(id)sender;
- (IBAction)addPicture1:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *picture1;
@property (weak, nonatomic) IBOutlet UIImageView *picture2;
@property (weak, nonatomic) IBOutlet UIImageView *picture3;

@property (strong, nonatomic) NSMutableDictionary *patientData;
//- (IBAction)addPicture2:(id)sender;
//- (IBAction)addPicture3:(id)sender;

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
@property (weak, nonatomic) IBOutlet UIButton *checkOutBtn;
@property (weak, nonatomic) IBOutlet UIButton *SendToDoctor;
@property (weak, nonatomic) IBOutlet UIButton *sendToPharmacy;

- (IBAction)checkInButton:(id)sender;
- (IBAction)quickCheckOutButton:(id)sender;
- (IBAction)cancelNewVisit:(id)sender;
- (IBAction)sendToPharmacy:(id)sender;
- (BOOL)validateCheckin;
- (void)showPreviousVisit;
- (void)closePreviousVisit;

@property(weak,nonatomic)id<CancelDelegate> delegate;
@end
