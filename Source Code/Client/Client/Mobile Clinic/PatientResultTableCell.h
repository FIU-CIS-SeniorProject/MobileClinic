//
//  PatientResultTableCell.h
//  Mobile Clinic
//
//  Created by Rigo Hernandez on 2/22/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PatientResultTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *patientImage;
@property (weak, nonatomic) IBOutlet UILabel *patientName;
@property (weak, nonatomic) IBOutlet UILabel *patientDOB;
@property (weak, nonatomic) IBOutlet UILabel *patientAge;

@end
