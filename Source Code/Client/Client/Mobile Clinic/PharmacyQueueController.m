//
//  PharmacyQueueController.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 5/7/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import "PharmacyQueueController.h"
#import "PharmacyPatientViewController.h"
#import "MobileClinicFacade.h"
#import "StationSwitcher.h"
#import "QueueCell.h"
#import "ODRefreshControl.h"
#import "VisitationObject.h"

@interface PharmacyQueueController ()<PharmacyPatientViewDelegate,UIPopoverControllerDelegate>{
    NSMutableArray* queueArray;
    MobileClinicFacade* mcf;
    ODRefreshControl* refreshControl;
}
@property (strong, nonatomic) UIPopoverController * pop;
@end

/** OVERVIEW OF PHARMACYQUEUECONTROLLER
 * PharmacyQueueController shows all the patients that has been treated. This means that they have either seen the triage nurse and has been given some sort of treatment and medication or they have seen the doctor and has been prescribed medication.
 * The patients that populate this queue will only be visible for 12 hours then they will vanish. They will stay in their state and will have to be closed by the server application. This is to avoid confusion for when the application is used the next day and previous patients are not blocking the system.
 * It is good practice that at the end of the day, make sure that all the patients are dealt with and that they are no longer in queue.
 */

@implementation PharmacyQueueController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    mcf = [[MobileClinicFacade alloc]init];
    
    // Pull Down to Refresh
    refreshControl = [[ODRefreshControl alloc]initInScrollView:_queueTableView];
    [refreshControl addTarget:self action:@selector(reloadTable) forControlEvents:UIControlEventValueChanged];
    
    // Set the color and title of the UI
    [_queueTableView setBackgroundColor:[ColorMe colorFor:DARKGREEN]];
	UINavigationBar *navbar = [self.navigationController navigationBar];
    [navbar setTintColor:[ColorMe colorFor:DARKGREEN]];
    [self.navigationItem setTitle: @"Pharmacy"];
    
    // Should remove this code and alter on the storyboard since it has been separated
    [_prioritySelector setUserInteractionEnabled:NO];
    [_prioritySelector removeSegmentAtIndex:1 animated:NO];
    
    [self reloadTable];
}

-(void)reloadTable{
    /** This will should HUD in tableview to show alert the user that the system is working */
    [self showIndeterminateHUDInView:_queueTableView withText:@"Working..." shouldHide:NO afterDelay:0 andShouldDim:YES];
    
    // Do not let the user interact with the table while its working
    [self.queueTableView setScrollEnabled:NO];
    
    // Request patient's that are currently checked-in
    [mcf findAllOpenVisitsAndOnCompletion:^(NSArray *allObjectsFromSearch, NSError *error) {
        if (!allObjectsFromSearch && error ) {
            [FIUAppDelegate getNotificationWithColor:AJNotificationTypeOrange Animation:AJLinedBackgroundTypeAnimated WithMessage:error.localizedDescription inView:self.view];
            
        }else{
            queueArray = [NSArray arrayWithArray:allObjectsFromSearch];
            // Filter results (Seen doctor & need to see pharmacy)
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"%K != %@", DOCTOROUT, nil];
            queueArray = [NSMutableArray arrayWithArray:[queueArray filteredArrayUsingPredicate:predicate]];
            
            [self sortBy:DOCTOROUT inAscendingOrder:YES];
            [_queueTableView reloadData];
        }
        /** This will remove the HUD since the search is complete */
        [self HideALLHUDDisplayInView:_queueTableView];
        [refreshControl endRefreshing];
        [self.queueTableView setScrollEnabled:YES];
    }];
}

- (IBAction)sortBySelected:(id)sender {
    
    if(_prioritySelector.selectedSegmentIndex == 0) {
        // Sort queue by priority
        [self sortBy:PRIORITY inAscendingOrder:NO];
    }else if(_prioritySelector.selectedSegmentIndex == 1) {
        // Sort queue by wait time
        [self sortBy:TRIAGEOUT inAscendingOrder:YES];
    }
    
    [_queueTableView reloadData];
}

- (void)sortBy:(NSString *)sortCategory inAscendingOrder:(BOOL)order {
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:sortCategory ascending:order];
    
    NSArray *sortDescriptorArray = [NSArray arrayWithObject:sortDescriptor];
    
    queueArray = [NSMutableArray arrayWithArray:[queueArray sortedArrayUsingDescriptors:sortDescriptorArray]];
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    [self.navigationItem.leftBarButtonItem setEnabled:YES];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    // Instead of using delegation, Pass the Popover object to the StationSwitcher
    if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
        UIPopoverController* pop = [(UIStoryboardPopoverSegue*)segue popoverController];
        StationSwitcher* station =  segue.destinationViewController;
        [pop setDelegate:self];
        [station setPopoverController:pop];
        [self.navigationItem.leftBarButtonItem setEnabled:NO];
    }
}

// Defines number of sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Defines number of cells in table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Update the number of patients in the label
    [_numberOfPatientsLabel setText:[NSString stringWithFormat:@"%i Patients",queueArray.count]];
    return queueArray.count;
}

// Populate cells with respective content
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"queueCell";
    
    QueueCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(!cell)
        cell = [[QueueCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    NSDictionary *visitDic = [[NSDictionary alloc]initWithDictionary:[queueArray objectAtIndex:indexPath.row]];
   
    NSDictionary *patientDic = [visitDic objectForKey:OPEN_VISITS_PATIENT];
    
    // Set Priority Indicator color
    cell.priorityIndicator.backgroundColor = [UIColor darkGrayColor];

    // Fills out common information like name and chief Complaint
    [cell updateCellWithPatientInformation:patientDic andVisitInformation:visitDic];
    // Display Nurse or Doctor's name depending on the station
    cell.employeeName.text = [visitDic objectForKey:DOCTORID];
    
    // Calculate wait time since patient left doctor
    NSDate *now = [NSDate date];
    NSDate *docOut = [NSDate convertSecondsToNSDate:[visitDic objectForKey:DOCTOROUT]];
    NSTimeInterval secsSinceTriageOut = [now timeIntervalSinceDate:docOut];
    NSInteger waitInSeconds = floor(secsSinceTriageOut);
    NSInteger waitInMinutes = waitInSeconds / 60;
    
    cell.patientWaitTime.text = [NSString stringWithFormat:@"%i min(s)", waitInMinutes];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setBackgroundColor:[UIColor whiteColor]];
}

// Action upon selecting cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Push to doctor & pharmacy view controllers
    // This is Visit and Patient Data Bundle
    NSMutableDictionary * patientDic = [[NSMutableDictionary alloc]initWithDictionary:[queueArray objectAtIndex:indexPath.row]];
    
    /** This will should HUD in tableview to show alert the user that the system is working */
    [self showIndeterminateHUDInView:_queueTableView withText:@"Loading..." shouldHide:NO afterDelay:0 andShouldDim:NO];
    [self.queueTableView setScrollEnabled:NO];
    // Lock patients / visit
    [[[MobileClinicFacade alloc] init] updateVisitRecord:patientDic andShouldUnlock:NO andShouldCloseVisit:NO onCompletion:^(NSDictionary *object, NSError *error) {
        
        if(!object){
            [FIUAppDelegate getNotificationWithColor:AJNotificationTypeRed Animation:AJLinedBackgroundTypeDisabled WithMessage:error.localizedDescription inView:self.view];
        }else{
            // Manually push to the pharmacy screen. Need  to set delegate and pass patient data
            PharmacyPatientViewController * newView = [self getViewControllerFromiPadStoryboardWithName:@"pharmacyPatientViewController"];
            [newView view];
            [newView setDelegate:self];
            [newView setPatientData:patientDic];
            [self.navigationController pushViewController:newView animated:YES];
    
        }
        /** This will remove the HUD since the search is complete */
        [self HideALLHUDDisplayInView:_queueTableView];
        [self.queueTableView setScrollEnabled:YES];
    }];
}

-(void)PharmacyPatientViewUpdatedAndClose{
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self reloadTable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setQueueTableView:nil];
    [self setPrioritySelector:nil];
    queueArray = nil;
    mcf = nil;
   [refreshControl removeTarget:self action:@selector(reloadTable) forControlEvents:UIControlEventValueChanged];
    refreshControl = nil;
    [self setPop:nil];
    [super viewDidUnload];
}

-(void)dealloc{
    [_queueTableView setDelegate:nil];
    [_queueTableView setDataSource:nil];
}
@end
