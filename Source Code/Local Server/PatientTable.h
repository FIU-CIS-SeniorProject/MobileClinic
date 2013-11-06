//
//  PatientTable.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 2/27/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PatientObject.h"
#import "VisitationObject.h"
#import "PrescriptionObject.h"
@interface PatientTable : NSViewController<NSTableViewDataSource,NSTableViewDelegate,NSTextFieldDelegate>{
    
    NSArray* patientList;
    NSMutableArray* visitList;
    NSMutableArray* allItems;
    NSInteger selectedRow;
}
@property (weak) IBOutlet NSButton *printButton;
@property (unsafe_unretained) IBOutlet NSTextView *visitDocumentation;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) IBOutlet NSTableView *patientTableView;
@property (weak) IBOutlet NSTableView *visitTableView;
@property (weak) IBOutlet NSImageView *patientPhoto;
@property (weak) IBOutlet NSButton *details;
- (IBAction)importFile:(id)sender;
- (IBAction)CloseSelectedPatient:(id)sender;

- (IBAction)printPatient:(id)sender;
- (IBAction)showDetails:(id)sender;

- (IBAction)refreshPatients:(id)sender;
- (IBAction)unblockPatients:(id)sender;
- (IBAction)getPatientsFromCloud:(id)sender;
- (IBAction)exportPatientData:(id)sender;

@end
