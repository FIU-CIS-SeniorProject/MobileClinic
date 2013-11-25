//
//  TriageViewController.h
//  Mobile Clinic
//
//  Created by sebastian a zanlongo on 2/18/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RegisterPatientTableCell.h"
#import "SearchPatientTableCell.h"
#import "StationViewHandlerProtocol.h"

@interface TriageViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>{
    ScreenHandler handler;
}

//@property (strong, nonatomic) SearchPatientViewController * viewController;
@property (strong, nonatomic) NSMutableDictionary * patientData;
@property (strong, nonatomic) RegisterPatientViewController * registerControl;
@property (strong, nonatomic) SearchPatientViewController * searchControl;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;

- (void)setScreenHandler:(ScreenHandler)myHandler;

@end