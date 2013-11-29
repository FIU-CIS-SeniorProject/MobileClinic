//
//  PatientQueueViewController.h
//  Mobile Clinic
//
//  Created by Rigo Hernandez on 3/10/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MobileClinicFacade.h"


@interface PatientQueueViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *queueTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *prioritySelector;
@property (weak, nonatomic) IBOutlet UILabel *numberOfPatientsLabel;

- (IBAction)sortBySelected:(id)sender;

@end


