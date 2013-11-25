//
//  GenericStartViewController.h
//  Mobile Clinic
//
//  Created by sebastian a zanlongo on 3/6/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuViewController.h"
#import "RegisterPatientTableCell.h"
#import "SearchPatientTableCell.h"
#import "PatientQueueTableCell.h"
#import "StationViewHandlerProtocol.h"
#import "StationNavigationController.h"
//need to import patient queue table cell when its complete

@interface GenericStartViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    ScreenHandler handler;
}

//patient data
@property (strong, nonatomic) NSMutableDictionary * patientData;

//station chosen
@property (strong, nonatomic) NSNumber * stationChosen;

//different cell view controllers
@property (strong, nonatomic) RegisterPatientViewController * registerControl;
@property (strong, nonatomic) SearchPatientViewController * searchControl;
@property (strong, nonatomic) PatientQueueViewController * queueControl;

//gui elements
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;

- (IBAction)segmentClicked:(id)sender;

@end
