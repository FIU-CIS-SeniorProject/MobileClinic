//
//  CurrentDiagnosisTableCell.h
//  Mobile Clinic
//
//  Created by sebastian a zanlongo on 2/24/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CurrentDiagnosisViewController.h"
#import "GenericTableViewCellProtocol.h"
@interface CurrentDiagnosisTableCell : UITableViewCell

@property (nonatomic, strong) id<GenericCellProtocol> viewController;

@end