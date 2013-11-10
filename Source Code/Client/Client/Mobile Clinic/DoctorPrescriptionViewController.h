//
//  PharamcyPrescriptionViewController.h
//  Mobile Clinic
//
//  Created by Steven Berlanga on 2/24/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//
#define SYNC_OBJECT @"syncronizing object"
#define DISABLE_EDIT @"disable edit button"
#import <UIKit/UIKit.h>
#import "StationViewHandlerProtocol.h"
#import "PatientObject.h"
#import "PrescriptionObject.h"
#import "GenericCellProtocol.h"
#import "CancelDelegate.h"
@interface DoctorPrescriptionViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
}

@property (strong, nonatomic) NSMutableDictionary *patientData;

@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkOutBtn;
@property(nonatomic, weak) id<CancelDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextView *medicationNotes;
@property (weak, nonatomic) IBOutlet UITextField *drugTextField;
@property (weak, nonatomic) IBOutlet UITextField *tabletsTextField;
@property (weak, nonatomic) IBOutlet UITextField *timeOfDayTextFields;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *timeOfDayButtons;
@property (weak, nonatomic) IBOutlet UITableView *drugTableView;

- (IBAction)newTimeOfDay:(id)sender;
- (IBAction)findDrugs:(id)sender;
- (IBAction)savePrescription:(id)sender;
- (IBAction)CheckOutPatient:(id)sender;
- (void)deactivateControllerFields;


@end
