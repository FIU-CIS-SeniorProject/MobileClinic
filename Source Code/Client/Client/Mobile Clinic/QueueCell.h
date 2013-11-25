//
//  QueueCell.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 5/7/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QueueCell : UITableViewCell

//Cell Fields
@property (weak, nonatomic) IBOutlet UILabel *patientName;
@property (weak, nonatomic) IBOutlet UILabel *patientConditionTitle;
@property (weak, nonatomic) IBOutlet UILabel *employeeName;
@property (weak, nonatomic) IBOutlet UILabel *patientWaitTime;
@property (weak, nonatomic) IBOutlet UIImageView *patientPhoto;
@property (weak, nonatomic) IBOutlet UITextView *priorityIndicator;

-(void)updateCellWithPatientInformation:(NSDictionary*)patientDictionary andVisitInformation:(NSDictionary*)visitDictionary;
@end
