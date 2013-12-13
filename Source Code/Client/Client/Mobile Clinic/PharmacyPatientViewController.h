//
//  PharmacyPatientViewController.h
//  Mobile Clinic
//
//  Created by sebastian a zanlongo on 2/24/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PatientObject.h"
#import "DoctorPrescriptionViewController.h"
#import "MedicineSearchViewController.h"
#import "StationViewHandlerProtocol.h"
#import "CameraFacade.h"
#import "PrescriptionObject.h"
#import "MedicineSearchCell.h"

@protocol PharmacyPatientViewDelegate <NSObject>

-(void) PharmacyPatientViewUpdatedAndClose;

@end

@interface PharmacyPatientViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    CameraFacade *facade;
}

@property (strong, nonatomic) NSMutableDictionary * patientData;
- (IBAction)verify:(id)sender;

@property (strong, nonatomic) NSMutableArray * prescriptions;

@property (weak, nonatomic) id<PharmacyPatientViewDelegate>delegate;
@property (weak, nonatomic) IBOutlet UITextField *patientNameField;
@property (weak, nonatomic) IBOutlet UITextField *familyNameField;
@property (weak, nonatomic) IBOutlet UITextField *villageNameField;
@property (weak, nonatomic) IBOutlet UITextField *patientAgeField;
@property (weak, nonatomic) IBOutlet UITextField *patientSexField;
@property (weak, nonatomic) IBOutlet UIImageView *patientPhoto;
@property (weak, nonatomic) IBOutlet UITextView *medicalNotes;
@property (weak, nonatomic) IBOutlet UIView *patientView;
@property (weak, nonatomic) IBOutlet UIButton *checkoutButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)checkoutPatient:(id)sender;
@end

