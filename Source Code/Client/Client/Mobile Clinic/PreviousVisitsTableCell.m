//
//  PreviousVisitsTableCell.m
//  Mobile Clinic
//
//  Created by sebastian a zanlongo on 2/23/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import "PreviousVisitsTableCell.h"

@interface PreviousVisitsTableCell ()

@end

@implementation PreviousVisitsTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        UIStoryboard* story = [UIStoryboard storyboardWithName:@"NewStoryboard" bundle:nil];
        
        _viewController = [story instantiateViewControllerWithIdentifier:@"previousVisitsViewController"];
    

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
