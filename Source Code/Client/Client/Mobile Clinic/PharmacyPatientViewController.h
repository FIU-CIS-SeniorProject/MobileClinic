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
#import "PharmacyPrescriptionCell.h"
#import "PrescriptionObject.h"
#import "MedicineSearchCell.h"

@interface PharmacyPatientViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>{
    ScreenHandler handler;
}

@property (strong, nonatomic) NSMutableDictionary * patientData;
@property (strong, nonatomic) NSMutableDictionary * prescriptionData;
@property (strong, nonatomic) NSMutableDictionary * visitationData;

@property (strong, nonatomic) NSMutableArray * prescriptions;
@property (strong, nonatomic) NSString * medName;

@property (weak, nonatomic) IBOutlet UITextField *patientNameField;
@property (weak, nonatomic) IBOutlet UITextField *familyNameField;
@property (weak, nonatomic) IBOutlet UITextField *villageNameField;
@property (weak, nonatomic) IBOutlet UITextField *patientAgeField;
@property (weak, nonatomic) IBOutlet UITextField *patientSexField;
@property (weak, nonatomic) IBOutlet UIImageView *patientPhoto;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)checkoutPatient:(id)sender;

- (void)setScreenHandler:(ScreenHandler)myHandler;
@end