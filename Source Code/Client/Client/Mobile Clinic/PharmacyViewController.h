//
//  PharmacyViewController.h
//  Mobile Clinic
//
//  Created by sebastian a zanlongo on 2/22/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchPatientTableCell.h"
#import "StationViewHandlerProtocol.h"
#import "PrescriptionObject.h"
#import "PatientObject.h"

@interface PharmacyViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>{
    ScreenHandler handler;
}

@property (strong, nonatomic) SearchPatientViewController * viewController;
@property (strong, nonatomic) NSMutableDictionary * patientData;
@property (strong, nonatomic) SearchPatientViewController * control;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void)setScreenHandler:(ScreenHandler)myHandler;

@end