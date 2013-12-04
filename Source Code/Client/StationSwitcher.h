//
//  StationSwitcher.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 4/24/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StationSwitcher : UITableViewController
-(void)setPopoverController:(UIPopoverController*)pop;
@end


@interface StationSwitcherCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *stationTitle;
@end