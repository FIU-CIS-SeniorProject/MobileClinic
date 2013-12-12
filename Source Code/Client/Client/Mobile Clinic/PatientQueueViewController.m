//
//  PatientQueueViewController.m
//  Mobile Clinic
//
//  Created by Rigo Hernandez on 3/10/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import "PatientQueueViewController.h"
#import "DoctorPatientViewController.h"
#import "PharmacyPatientViewController.h" 
#import "QueueCell.h"
#import "StationSwitcher.h"
#import "ODRefreshControl.h"
@interface PatientQueueViewController ()<DoctorPatientViewDelegate,UIPopoverControllerDelegate> {
    NSArray *queueArray;
    MobileClinicFacade *mobileFacade;
    ODRefreshControl* refreshControl;
    
}

@property (strong, nonatomic) UIPopoverController * pop;
@end

@implementation PatientQueueViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    mobileFacade = [[MobileClinicFacade alloc] init];
    
    refreshControl = [[ODRefreshControl alloc]initInScrollView:_queueTableView];
    
    [refreshControl addTarget:self action:@selector(reloadTable) forControlEvents:UIControlEventValueChanged];
  
    UINavigationBar *navbar = [self.navigationController navigationBar];
    
    [navbar setTintColor:[ColorMe colorFor:PALEPURPLE]];

    [_queueTableView setBackgroundColor:[ColorMe colorFor:PALEPURPLE]];

    
    [self.navigationItem setTitle: @"Doctor Queue"];
    
    [self reloadTable];
   
}
-(void)reloadTable{
    
    /** This will should HUD in tableview to show alert the user that the system is working */
    [self showIndeterminateHUDInView:_queueTableView withText:@"Loading" shouldHide:NO afterDelay:0 andShouldDim:NO];
    [self.queueTableView setScrollEnabled:NO];
    // Request patient's that are currently checked-in
    [mobileFacade findAllOpenVisitsAndOnCompletion:^(NSArray *allObjectsFromSearch, NSError *error) {
        if (!allObjectsFromSearch && error ) {
            [FIUAppDelegate getNotificationWithColor:AJNotificationTypeOrange Animation:AJLinedBackgroundTypeAnimated WithMessage:error.localizedDescription inView:self.view];
            
        }else{
            
            queueArray = [NSArray arrayWithArray:allObjectsFromSearch];
            
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"%K == %@", DOCTOROUT, nil];
            
            queueArray = [NSMutableArray arrayWithArray:[queueArray filteredArrayUsingPredicate:predicate]];
            
            [self sortBy:PRIORITY inAscendingOrder:NO];
            
            [_queueTableView reloadData];
        }
        /** This will remove the HUD since the search is complete */
        [self HideALLHUDDisplayInView:_queueTableView];
        
        [refreshControl endRefreshing];
        [self.queueTableView setScrollEnabled:YES];
    }];

}

// Sorts queue for category specified in ascending or decending order
- (void)sortBy:(NSString *)sortCategory inAscendingOrder:(BOOL)order {
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:sortCategory ascending:order];
    
    NSArray *sortDescriptorArray = [NSArray arrayWithObject:sortDescriptor];
    
    queueArray = [NSMutableArray arrayWithArray:[queueArray sortedArrayUsingDescriptors:sortDescriptorArray]];
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    [self.navigationItem.leftBarButtonItem setEnabled:YES];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
        UIPopoverController* pop = [(UIStoryboardPopoverSegue*)segue popoverController];
        StationSwitcher* station =  segue.destinationViewController;
        [pop setDelegate:self];
        [station setPopoverController:pop];
        [self.navigationItem.leftBarButtonItem setEnabled:NO];
    }
}

- (void)viewDidUnload {
    [self setQueueTableView:nil];
    [self setPrioritySelector:nil];
    queueArray = nil;
    mobileFacade = nil;
    [self setPop:nil];
    
    [refreshControl removeTarget:self action:@selector(reloadTable) forControlEvents:UIControlEventValueChanged];
    refreshControl = nil;
    [super viewDidUnload];
}

// Defines number of sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Defines number of cells in table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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
    
    
    // Show for Doctor
    if([[visitDic objectForKey:PRIORITY]intValue] == 0)
        cell.priorityIndicator.backgroundColor = [UIColor greenColor];
    else if([[visitDic objectForKey:PRIORITY]intValue] == 1)
        cell.priorityIndicator.backgroundColor = [UIColor yellowColor];
    else if([[visitDic objectForKey:PRIORITY]intValue] == 2)
        cell.priorityIndicator.backgroundColor = [UIColor redColor];
    
    // Display contents of cells
    if ([[patientDic objectForKey:PICTURE]isKindOfClass:[NSData class]]) {
        UIImage *image = [UIImage imageWithData: [patientDic objectForKey:PICTURE]];
        [cell.patientPhoto setImage:image];
    }else{
        [cell.patientPhoto setImage:[UIImage imageNamed:@"userImage.jpeg"]];
    }
    
    NSString *firstName = [patientDic objectForKey:FIRSTNAME];
    NSString *familyName = [patientDic objectForKey:FAMILYNAME];
    
    cell.patientName.text = [NSString stringWithFormat:@"%@ %@", firstName, familyName];
    cell.patientConditionTitle.text = [visitDic objectForKey:CONDITIONTITLE];
    
    // Display Nurse or Doctor's name depending on the station
    cell.employeeName.text = [visitDic objectForKey:NURSEID];

    
    // Calculate wait time since patient left triage
    NSDate *now = [NSDate date];
    
    NSDate *triageOut = [NSDate convertSecondsToNSDate:[visitDic objectForKey:TRIAGEOUT]];
    
    NSTimeInterval secsSinceTriageOut = [now timeIntervalSinceDate:triageOut];
    
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
        /** This will remove the HUD since the search is complete */
        [self HideALLHUDDisplayInView:_queueTableView];
        if(!object){
            [FIUAppDelegate getNotificationWithColor:AJNotificationTypeRed Animation:AJLinedBackgroundTypeDisabled WithMessage:error.localizedDescription inView:self.view];
        }else{
        
            DoctorPatientViewController * newView = [self getViewControllerFromiPadStoryboardWithName:@"doctorPatientViewController"];
            [newView view];
            [newView setDelegate:self];
            [newView setPatientData:patientDic];
            [newView.navigationItem setHidesBackButton:YES];
            [self.navigationController pushViewController:newView animated:YES];
            
        }
        [self.queueTableView setScrollEnabled:YES];
    }];
}


-(void)DoctorPatientViewUpdateAndClose{
    [self reloadTable];
    [self.navigationController popToRootViewControllerAnimated:YES];
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

-(void)dealloc{
    [_queueTableView setDelegate:nil];
    [_queueTableView setDataSource:nil];
}
@end
