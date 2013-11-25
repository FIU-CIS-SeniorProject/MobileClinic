//
//  PharmacyPatientViewControllerCell.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 5/1/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCSwipeTableViewCell.h"
@interface PharmacyPatientViewControllerCell : MCSwipeTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *timeOfDay;
@property (weak, nonatomic) IBOutlet UILabel *dosage;
@property (weak, nonatomic) IBOutlet UILabel *drugName;
-(void)populateFieldsWithData:(NSDictionary*)data;
@end
