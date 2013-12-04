//
//  PreviousVisitsViewController.h
//  Mobile Clinic
//
//  Created by sebastian a zanlongo on 2/18/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PatientHistoryTableCell.h"
#import "GenericCellProtocol.h"
@interface PreviousVisitsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,GenericCellProtocol>{

}

@property (nonatomic, strong) NSMutableDictionary * patientData;
@property (nonatomic, strong) NSArray * patientHistoryArray;
@property(nonatomic, weak) id<GenericCellManager> delegate;
@property (weak, nonatomic) IBOutlet UITableView * patientHistoryTableView;

@end
