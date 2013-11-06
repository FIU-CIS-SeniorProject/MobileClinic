//
//  MedicineSearchViewController.h
//  Mobile Clinic
//
//  Created by Steven Berlanga on 2/24/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MedicineSearchResultCell.h"
#import "GenericCellProtocol.h"
#import "CancelDelegate.h"
//#import "PrescriptionObjectProtocol.h"
@protocol MedicineSearchViewProtocol <NSObject>
-(void)addPrescription:(NSMutableDictionary*)prescription;
@end

@interface MedicineSearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *medicineField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, weak) id<MedicineSearchViewProtocol> delegate;
@property (nonatomic, strong) NSMutableDictionary *prescriptionData;
@property (weak, nonatomic) IBOutlet UITextField *drugName;
@property (weak, nonatomic) IBOutlet UITextField *duration;
@property (weak, nonatomic) IBOutlet UITextField *timeOfDay;
@property (weak, nonatomic) IBOutlet UIStepper *durationIncrementer;
@property (weak, nonatomic) IBOutlet UITextField *dosage;

- (IBAction)AddTimeOfDay:(id)sender;
-(void)resetView;
- (IBAction)alterAmountOfTablets:(id)sender;
- (IBAction)moveBackToPrescription:(id)sender;
- (IBAction)searchMedicine:(id)sender;

@end
