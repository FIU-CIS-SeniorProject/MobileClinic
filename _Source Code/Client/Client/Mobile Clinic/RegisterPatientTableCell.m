//
//  RegisterPatientTableCell.m
//  Mobile Clinic
//
//  Created by Rigo Hernandez on 2/19/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import "RegisterPatientTableCell.h"

@implementation RegisterPatientTableCell

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
