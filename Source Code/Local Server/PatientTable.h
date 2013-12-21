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
//  PatientTable.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 2/27/13.
//
#import <Cocoa/Cocoa.h>
#import "PatientObject.h"
#import "VisitationObject.h"
#import "PrescriptionObject.h"
@interface PatientTable : NSViewController<NSTableViewDataSource,NSTableViewDelegate,NSTextFieldDelegate>
{
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