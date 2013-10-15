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
//  PatientDashboardViewController.h
//  Mobile Clinic
//
//  Created by Rigo Hernandez on 3/31/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "MobileClinicFacade.h"

@interface PatientDashboardViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *prioritySelector;
@property (weak, nonatomic) IBOutlet UITableView *doctorQueueTableView;
@property (weak, nonatomic) IBOutlet UITableView *pharmacyQueueTableView;
@property (weak, nonatomic) IBOutlet UIButton *PendingSyncButton;
- (IBAction)sortBySelected:(id)sender;
- (IBAction)tryAndSyncAllPendingObjects:(id)sender;
@end

@interface DashboardTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *patientName;
@property (weak, nonatomic) IBOutlet UILabel *patientConditionTitle;
@property (weak, nonatomic) IBOutlet UILabel *employeeName;
@property (weak, nonatomic) IBOutlet UILabel *patientWaitTime;
@property (weak, nonatomic) IBOutlet UIImageView *patientPhoto;
@property (weak, nonatomic) IBOutlet UITextView *priorityIndicator;
@end