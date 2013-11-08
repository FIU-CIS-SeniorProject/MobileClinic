//
//  CurrentDiagnosisViewController.h
//  Mobile Clinic
//
//  Created by sebastian a zanlongo on 2/22/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//
#define SET_DELEGATE @"set delegate"

#import <UIKit/UIKit.h>
#import "StationViewHandlerProtocol.h"
#import "PatientObject.h"
#import "VisitationObject.h"
#import "GenericCellProtocol.h"
#import "CancelDelegate.h"
@interface CurrentDiagnosisViewController : UIViewController<CancelDelegate> {

}

@property (strong, nonatomic) NSMutableDictionary *patientData;
@property (strong, nonatomic) VisitationObject *visitationData;
@property(nonatomic, weak) id<CancelDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *subjectiveLabel;
@property (weak, nonatomic) IBOutlet UITextView *subjectiveTextbox;

@property (weak, nonatomic) IBOutlet UILabel *objectiveLabel;
@property (weak, nonatomic) IBOutlet UITextView *objectiveTextbox;

@property (weak, nonatomic) IBOutlet UILabel *assessmentLabel;
@property (weak, nonatomic) IBOutlet UITextView *assessmentTextbox;

@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) IBOutlet UIView *view;

- (IBAction)submitButton:(id)sender;
- (IBAction)cancelDiagnosis:(id)sender;
-(void)populateView;

@end
