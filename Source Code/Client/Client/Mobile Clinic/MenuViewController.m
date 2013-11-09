//
//  MenuViewController.m
//  Mobile Clinic
//
//  Created by Steven Berlanga on 3/26/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import "MenuViewController.h"
#import "StationNavigationController.h"
#import "LoginViewController.h"

@interface MenuViewController ()

@property (nonatomic) BOOL switchUsersActive;

@end

@implementation MenuViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.switchUsersActive = NO;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return self.switchUsersActive ? 6 : 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [((UIButton *)[cell viewWithTag:1]) removeTarget:self action:@selector(expandCell) forControlEvents:UIControlEventTouchUpInside];
    [((UIButton *)[cell viewWithTag:1]) removeTarget:self action:@selector(logOff) forControlEvents:UIControlEventTouchUpInside];
    [((UIButton *)[cell viewWithTag:1]) removeTarget:self action:@selector(resetClient) forControlEvents:UIControlEventTouchUpInside];
    [((UIButton *)[cell viewWithTag:1]) removeTarget:self action:@selector(switchToTriage) forControlEvents:UIControlEventTouchUpInside];
    [((UIButton *)[cell viewWithTag:1]) removeTarget:self action:@selector(switchToDoctor) forControlEvents:UIControlEventTouchUpInside];
    [((UIButton *)[cell viewWithTag:1]) removeTarget:self action:@selector(switchToPharmacy) forControlEvents:UIControlEventTouchUpInside];
    
    if(indexPath.item == 0){
        ((UIButton *)[cell viewWithTag:1]).titleLabel.text = @"Switch Users";
        [((UIButton *)[cell viewWithTag:1]) addTarget:self action:@selector(expandCell) forControlEvents:UIControlEventTouchUpInside];
    }
    else if(!self.switchUsersActive && indexPath.item == 1){
        ((UIButton *)[cell viewWithTag:1]).titleLabel.text = @"Log Off";
        [((UIButton *)[cell viewWithTag:1]) addTarget:self action:@selector(logOff) forControlEvents:UIControlEventTouchUpInside];
    }
<<<<<<< HEAD
<<<<<<< HEAD
    else if(self.switchUsersActive && indexPath.item == 1){
=======
=======
>>>>>>> f143e12fd9b043b895a8ca0d769f2049528b321b
    else if(!self.switchUsersActive && indexPath.item == 2)
    {
        ((UIButton *)[cell viewWithTag:1]).titleLabel.text = @"Reset Client";
        [((UIButton *)[cell viewWithTag:1]) addTarget:self action:@selector(resetClient) forControlEvents:UIControlEventTouchUpInside];
    }
    else if(self.switchUsersActive && indexPath.item == 1)
    {
>>>>>>> f143e12fd9b043b895a8ca0d769f2049528b321b
        ((UIButton *)[cell viewWithTag:1]).titleLabel.text = @"Triage";
        [((UIButton *)[cell viewWithTag:1]) addTarget:self action:@selector(switchToTriage) forControlEvents:UIControlEventTouchUpInside];
    }
    else if(self.switchUsersActive && indexPath.item == 2){
        ((UIButton *)[cell viewWithTag:1]).titleLabel.text = @"Doctor";
        [((UIButton *)[cell viewWithTag:1]) addTarget:self action:@selector(switchToDoctor) forControlEvents:UIControlEventTouchUpInside];
    }
    else if(self.switchUsersActive && indexPath.item == 3){
        ((UIButton *)[cell viewWithTag:1]).titleLabel.text = @"Pharmacy";
        [((UIButton *)[cell viewWithTag:1]) addTarget:self action:@selector(switchToPharmacy) forControlEvents:UIControlEventTouchUpInside];
    }
    else if(self.switchUsersActive && indexPath.item == 4){
        ((UIButton *)[cell viewWithTag:1]).titleLabel.text = @"Log Off";
        [((UIButton *)[cell viewWithTag:1]) addTarget:self action:@selector(logOff) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

- (void)logOff {
    handler(nil,nil);
//    [self.parentViewController.navigationController popToRootViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter]postNotificationName:LOGOFF object:nil];
}

- (void)expandCell {
    self.switchUsersActive = !self.switchUsersActive;
    
    [self.tableView reloadData];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)switchToTriage {
    StationNavigationController * newView = [self getViewControllerFromiPadStoryboardWithName:@"genericStartViewController"];
    
    [newView setStationChosen:[NSNumber numberWithInt:1]];
    [self presentViewController:newView animated:YES completion:^{
    }];
}

- (void)switchToDoctor {
    StationNavigationController * newView = [self getViewControllerFromiPadStoryboardWithName:@"patientQueueViewController"];
    
    [newView setStationChosen:[NSNumber numberWithInt:2]];
    [self presentViewController:newView animated:YES completion:^{
    }];
}

- (void)switchToPharmacy {
    StationNavigationController * newView = [self getViewControllerFromiPadStoryboardWithName:@"patientQueueViewController"];
    
    [newView setStationChosen:[NSNumber numberWithInt:3]];
    [self presentViewController:newView animated:YES completion:^{
    }];
}

- (void)resetClient
{
    
}

- (void)resetClient
{
    
}

////Override to support conditional editing of the table view.
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    //Return NO if you do not want the specified item to be editable.
//    return YES;
//}

//// Override to support editing the table view.
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//     if (editingStyle == UITableViewCellEditingStyleDelete) {
//         // Delete the row from the data source
//         [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//     } else if (editingStyle == UITableViewCellEditingStyleInsert) {
//         // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//     }
//}

//// Override to support rearranging the table view.
//- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
//
//}

//// Override to support conditional rearranging of the table view.
//- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
//    // Return NO if you do not want the item to be re-orderable.
//    return YES;
//}

#pragma mark - Table view delegate

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    //Navigation logic may go here. Create and push another view controller.
//    DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"Nib name" bundle:nil];
//    
//    // Pass the selected object to the new view controller.
//    [self.navigationController pushViewController:detailViewController animated:YES];
//}

- (void)setScreenHandler:(ScreenHandler)screenDelegate {
    handler = screenDelegate;
}

@end
