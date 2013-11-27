//
//  QueueCell.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 5/7/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import "QueueCell.h"
#import "MobileClinicFacade.h"
@implementation QueueCell

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

-(void)updateCellWithPatientInformation:(NSDictionary*)patientDictionary andVisitInformation:(NSDictionary*)visitDictionary{
    
    NSDictionary *visitDic = visitDictionary;
    
    NSDictionary *patientDic = patientDictionary;
    
    // Set Priority Indicator color
    _priorityIndicator.backgroundColor = [UIColor darkGrayColor];
    
    // Set the picture for the cell
    if ([[patientDic objectForKey:PICTURE]isKindOfClass:[NSData class]]) {
        UIImage *image = [UIImage imageWithData: [patientDic objectForKey:PICTURE]];
        [_patientPhoto setImage:image];
    }else{
        [_patientPhoto setImage:[UIImage imageNamed:@"userImage.jpeg"]];
    }
    
    NSString *firstName = [patientDic objectForKey:FIRSTNAME];
    NSString *familyName = [patientDic objectForKey:FAMILYNAME];
    
    _patientName.text = [NSString stringWithFormat:@"%@ %@", firstName, familyName];
    _patientConditionTitle.text = [visitDic objectForKey:CONDITIONTITLE];

}
@end
