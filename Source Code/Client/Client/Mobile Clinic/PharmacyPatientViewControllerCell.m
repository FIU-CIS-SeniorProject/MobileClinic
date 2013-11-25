//
//  PharmacyPatientViewControllerCell.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 5/1/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import "PharmacyPatientViewControllerCell.h"
#import "PrescriptionObject.h"
@implementation PharmacyPatientViewControllerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)populateFieldsWithData:(NSDictionary *)data{
    [_dosage setText:[NSString stringWithFormat:@"%i Days", [[data objectForKey:TABLEPERDAY] integerValue]]];
    
    [_drugName setText: [NSString stringWithFormat:@"%@ %@",[data objectForKey:MEDNAME], [data objectForKey:INSTRUCTIONS]]];
    
    [_timeOfDay setText:[NSString stringWithFormat:@"%@ ", [data objectForKey:TIMEOFDAY]]];
    
}
@end
