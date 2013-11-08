//
//  PatientQueueViewController.h
//  Mobile Clinic
//
//  Created by Rigo Hernandez on 3/10/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MobileClinicFacade.h"
#import "StationNavigationController.h"
#import "MenuViewController.h"

@interface PatientQueueViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *queueTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *prioritySelector;

- (IBAction)sortBySelected:(id)sender;

// Station Chosen
@property (strong, nonatomic) NSNumber * stationChosen;

@end

@interface QueueTableCell : UITableViewCell

//Cell Fields
@property (weak, nonatomic) IBOutlet UILabel *patientName;
@property (weak, nonatomic) IBOutlet UILabel *patientConditionTitle;
@property (weak, nonatomic) IBOutlet UILabel *employeeName;
@property (weak, nonatomic) IBOutlet UILabel *patientWaitTime;
@property (weak, nonatomic) IBOutlet UIImageView *patientPhoto;
@property (weak, nonatomic) IBOutlet UITextView *priorityIndicator;

@end
