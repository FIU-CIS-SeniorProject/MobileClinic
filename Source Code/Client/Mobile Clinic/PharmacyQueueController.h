//
//  PharmacyQueueController.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 5/7/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PharmacyQueueController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *queueTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *prioritySelector;
@property (weak, nonatomic) IBOutlet UILabel *numberOfPatientsLabel;

- (IBAction)sortBySelected:(id)sender;

@end
