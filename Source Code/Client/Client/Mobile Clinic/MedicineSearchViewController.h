//
//  MedicineSearchViewController.h
//  Mobile Clinic
//
//  Created by Steven Berlanga on 2/24/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MedicineSearchResultCell.h"
//#import "PrescriptionObjectProtocol.h"

@interface MedicineSearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *medicineField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableDictionary *prescriptionData;

- (IBAction)moveBackToPrescription:(id)sender;
- (IBAction)searchMedicine:(id)sender;

@end
