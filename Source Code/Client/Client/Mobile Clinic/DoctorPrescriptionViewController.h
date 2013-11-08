//
//  PharamcyPrescriptionViewController.h
//  Mobile Clinic
//
//  Created by Steven Berlanga on 2/24/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StationViewHandlerProtocol.h"
#import "PatientObject.h"
#import "PrescriptionObject.h"

@interface DoctorPrescriptionViewController : UIViewController{
    ScreenHandler handler;
}

@property (strong, nonatomic) NSMutableDictionary *patientData;
@property (strong, nonatomic) NSMutableDictionary *prescriptionData;

@property (weak, nonatomic) IBOutlet UITextView *medicationNotes;
@property (weak, nonatomic) IBOutlet UITextField *drugTextField;
@property (weak, nonatomic) IBOutlet UITextField *tabletsTextField;
@property (weak, nonatomic) IBOutlet UITextField *timeOfDayTextFields;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *timeOfDayButtons;

- (IBAction)newTimeOfDay:(id)sender;
- (IBAction)findDrugs:(id)sender;
- (IBAction)savePrescription:(id)sender;

- (void)deactivateControllerFields;
- (void)setScreenHandler:(ScreenHandler)myHandler;

@end
