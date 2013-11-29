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
@property (weak, nonatomic) IBOutlet UILabel *doctorWaitLabel;
@property (weak, nonatomic) IBOutlet UILabel *pharmacyWaitLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *pharmacyFilter;
@property (weak, nonatomic) IBOutlet UIButton *refreshPharmacy;
@property (weak, nonatomic) IBOutlet UIButton *refreshDoctor;

- (IBAction)refresh:(id)sender;
- (IBAction)sortBySelected:(id)sender;
- (IBAction)tryAndSyncAllPendingObjects:(id)sender;
- (IBAction)filterBy:(id)sender;

@end

@interface DashboardTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *patientName;
@property (weak, nonatomic) IBOutlet UILabel *patientConditionTitle;
@property (weak, nonatomic) IBOutlet UILabel *employeeName;
@property (weak, nonatomic) IBOutlet UILabel *patientWaitTime;
@property (weak, nonatomic) IBOutlet UIImageView *patientPhoto;
@property (weak, nonatomic) IBOutlet UITextView *priorityIndicator;

@end
