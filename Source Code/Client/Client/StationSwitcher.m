//
//  StationSwitcher.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 4/24/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//
#import "StationSwitcher.h"

@implementation StationSwitcherCell

@end


@interface StationSwitcher (){
    UIPopoverController* popover;
}
@end

@implementation StationSwitcher

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"menu";
    
    StationSwitcherCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 0:
            [cell.stationTitle setText:@"Triage Station"];
            break;
        case 1:
            [cell.stationTitle setText:@"Doctor Station"];
            break;
        case 2:
            [cell.stationTitle setText:@"Pharmacy Station"];
            break;
        case 3:
            [cell.stationTitle setText:@"Purge System"];
            break;
        default:
            [cell.stationTitle setText:@"Log Off"];
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [popover dismissPopoverAnimated:YES];
    if (indexPath.row < 3)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:SWITCH_STATIONS object:[NSNumber numberWithInteger:indexPath.row]];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:LOGOFF object:nil];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    StationSwitcherCell* station = (StationSwitcherCell*)cell;
    [station.stationTitle setTextColor:[UIColor whiteColor]];
    [ColorMe addBorder:cell.layer withWidth:1 withColor:[UIColor blackColor]];
    
    switch (indexPath.row)
    {
        case 0:
            [cell setBackgroundColor:[ColorMe colorFor:PALEORANGE]];
            break;
        case 1:
           [cell setBackgroundColor:[ColorMe colorFor:PALEPURPLE]];
            break;
        case 2:
            [cell setBackgroundColor:[ColorMe colorFor:DARKGREEN]];
            break;
        case 3:
            [cell setBackgroundColor:[ColorMe colorFor:PALERED]];
            break;
        case 4:
            [cell setBackgroundColor:[ColorMe colorFor:PALEORANGE]];
            break;
        default:
            break;
    }
}

-(void)setPopoverController:(UIPopoverController *)pop
{
    popover = pop;
}
@end
