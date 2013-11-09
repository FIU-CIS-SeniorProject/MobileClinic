//
//  TriagePatientViewController.h
//  Mobile Clinic
//
//  Created by sebastian a zanlongo on 2/18/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CurrentVisitTableCell.h"
#import "PreviousVisitsTableCell.h"

@interface TriagePatientViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    ScreenHandler handler;
}
    
@property (strong, nonatomic) NSMutableDictionary * patientData;
@property (strong, nonatomic) CurrentVisitViewController * control1;
@property (strong, nonatomic) PreviousVisitsViewController * control2;

@property (weak, nonatomic) IBOutlet UITextField *patientNameField;
@property (weak, nonatomic) IBOutlet UITextField *familyNameField;
@property (weak, nonatomic) IBOutlet UITextField *villageNameField;
@property (weak, nonatomic) IBOutlet UITextField *patientAgeField;
@property (weak, nonatomic) IBOutlet UITextField *patientSexField;
@property (weak, nonatomic) IBOutlet UIImageView *patientPhoto;

//@property (weak, nonatomic) IBOutlet UIButton *patientAgeField;

// Objects on View
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;

- (void)setScreenHandler:(ScreenHandler)myHandler;

@end

