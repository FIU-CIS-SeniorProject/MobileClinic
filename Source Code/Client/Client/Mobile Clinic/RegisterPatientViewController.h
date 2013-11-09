//
//  RegisterPatientViewController.h
//  Mobile Clinic
//
//  Created by sebastian a zanlongo on 2/18/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MobileClinicFacade.h"
#import "CameraFacade.h"
#import "StationViewHandlerProtocol.h"

@interface RegisterPatientViewController : UIViewController{
    ScreenHandler handler;
    CameraFacade *facade;
    BOOL shouldDismiss;
}

@property (weak, nonatomic) IBOutlet UITextField *patientNameField;
@property (weak, nonatomic) IBOutlet UITextField *familyNameField;
@property (weak, nonatomic) IBOutlet UITextField *villageNameField;
@property (weak, nonatomic) IBOutlet UIButton *patientAgeField;
@property (weak, nonatomic) IBOutlet UIImageView *patientPhoto;
@property (weak, nonatomic) IBOutlet UISegmentedControl *patientSexSegment;
@property (weak, nonatomic) IBOutlet UIButton *createPatientButton;
@property (weak, nonatomic) IBOutlet UIButton *registerFingerprintsButton;
- (IBAction)registerFingerprintsButton:(id)sender;

@property (strong, nonatomic) NSMutableDictionary *patient;

- (IBAction)patientPhotoButton:(id)sender;
- (IBAction)createPatient:(id)sender;

- (BOOL)validateRegistration;
- (IBAction)getAgeOfPatient:(id)sender;

- (void)setScreenHandler:(ScreenHandler)myHandler;
- (void)resetData;
@end
