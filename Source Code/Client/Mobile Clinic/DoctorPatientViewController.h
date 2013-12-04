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

@protocol DoctorPatientViewDelegate <NSObject>

-(void)DoctorPatientViewUpdateAndClose;

@end


@interface DoctorPatientViewController : UIViewController {

}

@property (strong, nonatomic) NSMutableDictionary * patientData;

@property (weak, nonatomic) IBOutlet UITextField *patientNameField;
@property (weak, nonatomic) IBOutlet UITextField *familyNameField;
@property (weak, nonatomic) IBOutlet UITextField *villageNameField;
@property (weak, nonatomic) IBOutlet UITextField *patientAgeField;
@property (weak, nonatomic) IBOutlet UITextField *patientSexField;
@property (weak, nonatomic) IBOutlet UIImageView *patientPhoto;

@property (weak, nonatomic) IBOutlet UILabel *patientWeightLabel;
@property(weak, nonatomic) id<DoctorPatientViewDelegate>delegate;
@property (weak, nonatomic) IBOutlet UILabel *patientBPLabel;
@property (weak, nonatomic) IBOutlet UILabel *patientHRLabel;
@property (weak, nonatomic) IBOutlet UILabel *patientRespirationLabel;
@property (weak, nonatomic) IBOutlet UILabel *patientTempLabel;


@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;

- (IBAction)segmentClicked:(id)sender;

@end