//
//  PatientQueueTableCell.m
//  Mobile Clinic
//
//  Created by sebastian a zanlongo on 3/7/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import "PatientQueueTableCell.h"

@implementation PatientQueueTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
