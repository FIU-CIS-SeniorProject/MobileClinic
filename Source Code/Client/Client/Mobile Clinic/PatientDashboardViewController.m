//
//  PatientDashboardViewController.m
//  Mobile Clinic
//
//  Created by Rigo Hernandez on 3/31/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import "PatientDashboardViewController.h"

#import "QueueManager.h"
#import "BaseObject.h"
@interface PatientDashboardViewController () {
    NSMutableArray * doctorWaitArray;
    NSMutableArray * pharmacyWaitArray;
    NSMutableArray* pendingPatients;
    MobileClinicFacade *mobileFacade;
    QueueManager* qm;
}
@end

@implementation DashboardTableCell
@end

@implementation PatientDashboardViewController

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
    
    qm = [[QueueManager alloc]init];
	// Do any additional setup after loading the view.
    
    _prioritySelector.selectedSegmentIndex = 0;
    
    // This will should HUD in tableview to show alert the user that the system is working
    [self showIndeterminateHUDInView:_doctorQueueTableView withText:@"Searching" shouldHide:NO afterDelay:0 andShouldDim:NO];
    
    // This will should HUD in tableview to show alert the user that the system is working
    [self showIndeterminateHUDInView:_pharmacyQueueTableView withText:@"Searching" shouldHide:NO afterDelay:0 andShouldDim:NO];
    
    mobileFacade = [[MobileClinicFacade alloc] init];
    
    // Request patient's that are currently checked-in
    [mobileFacade findAllOpenVisitsAndOnCompletion:^(NSArray *allObjectsFromSearch, NSError *error) {
        doctorWaitArray = [NSArray arrayWithArray:allObjectsFromSearch];
        pharmacyWaitArray = [NSArray arrayWithArray:allObjectsFromSearch];
        
        // Filter results to patient's that haven't seen the doctor
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"%K == %@", DOCTOROUT, nil];
        doctorWaitArray = [NSMutableArray arrayWithArray:[doctorWaitArray filteredArrayUsingPredicate:predicate]];
        
        // Sort queue by priority
        [self sortArray:1 by:PRIORITY inAscendingOrder:NO];
        
        // Filter results (Seen doctor & need to see pharmacy)
        NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"%K != %@", DOCTOROUT, nil];
        pharmacyWaitArray = [NSMutableArray arrayWithArray:[pharmacyWaitArray filteredArrayUsingPredicate:predicate2]];
        
        // Sort queue by time patient left doctor's station
        [self sortArray:2 by:DOCTOROUT inAscendingOrder:YES];
        
        [_doctorQueueTableView reloadData];
        [_pharmacyQueueTableView reloadData];
        
        // This will remove the HUD since the search is complete
        [self HideALLHUDDisplayInView:_pharmacyQueueTableView];
        
        // This will remove the HUD since the search is complete
        [self HideALLHUDDisplayInView:_doctorQueueTableView];
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self displayPendingButtonIfNecessary];
}

-(void)displayPendingButtonIfNecessary{
    pendingPatients = [NSMutableArray arrayWithArray:[qm getAllQueuedObjects]];
    
    [_PendingSyncButton setTitle:[NSString stringWithFormat:@"Tap to send %i pending objects",pendingPatients.count] forState:UIControlStateNormal];
    
    [_PendingSyncButton setHidden:(pendingPatients.count == 0)];
}
// Sorts queue for category specified in ascending or decending order
- (void)sortArray:(int)array by:(NSString *)sortCategory inAscendingOrder:(BOOL)order {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:sortCategory ascending:order];
    NSArray *sortDescriptorArray = [NSArray arrayWithObject:sortDescriptor];
    
    if(array == 1){
        doctorWaitArray = [NSMutableArray arrayWithArray:[doctorWaitArray sortedArrayUsingDescriptors:sortDescriptorArray]];
    }else if(array == 2){
        pharmacyWaitArray = [NSMutableArray arrayWithArray:[pharmacyWaitArray sortedArrayUsingDescriptors:sortDescriptorArray]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Defines number of sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Defines number of cells in table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == _doctorQueueTableView)
        return [doctorWaitArray count];
    else if (tableView == _pharmacyQueueTableView)
        return [pharmacyWaitArray count];
    else
        return 0;
}

// Populate cells with respective content
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *visitDic;
    NSDictionary *patientDic;
    
    static NSString *CellIdentifier = @"dashboardCell";
    DashboardTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(!cell)
    {
        cell = [[DashboardTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSArray *queueArray;
    
    if(tableView == _doctorQueueTableView)
    {
        queueArray = [NSArray arrayWithArray:doctorWaitArray];
    }
    else if(tableView == _pharmacyQueueTableView)
    {
        queueArray = [NSArray arrayWithArray:pharmacyWaitArray];
    }
    else
    {
        NSLog(@"PatientDashboardViewController: tableView - CRASHED!!!!!!!!");
        return cell;
    }
    
    visitDic = [[NSDictionary alloc]initWithDictionary:[queueArray objectAtIndex:indexPath.row]];
    patientDic = [visitDic objectForKey:OPEN_VISITS_PATIENT];
    
    //    cell.priorityIndicator.backgroundColor = [UIColor darkGrayColor];
    
    // Set Priority Indicator color
    if(tableView == _pharmacyQueueTableView) {
        cell.priorityIndicator.backgroundColor = [UIColor darkGrayColor];
    }else{
        if([[visitDic objectForKey:PRIORITY]intValue] == 0)
            cell.priorityIndicator.backgroundColor = [UIColor greenColor];
        else if([[visitDic objectForKey:PRIORITY]intValue] == 1)
            cell.priorityIndicator.backgroundColor = [UIColor yellowColor];
        else if([[visitDic objectForKey:PRIORITY]intValue] == 2)
            cell.priorityIndicator.backgroundColor = [UIColor redColor];
    }
    
    // Display contents of cells
    if([[patientDic objectForKey:PICTURE]isKindOfClass:[NSData class]]) {
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
    if(tableView == _doctorQueueTableView)
        cell.employeeName.text = [visitDic objectForKey:NURSEID];
    else if(tableView == _pharmacyQueueTableView)
        cell.employeeName.text = [visitDic objectForKey:DOCTORID];
    
    // Calculate wait time since patient left triage
    NSDate *now = [NSDate date];
    NSDate *triageOut = [NSDate convertSecondsToNSDate:[visitDic objectForKey:TRIAGEOUT]];
    
    NSTimeInterval secsSinceTriageOut = [now timeIntervalSinceDate:triageOut];
    NSInteger waitInSeconds = floor(secsSinceTriageOut);
    NSInteger waitInMinutes = waitInSeconds / 60;
    
    cell.patientWaitTime.text = [NSString stringWithFormat:@"%i min(s)", waitInMinutes];
    
    return cell;
}

//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//
//    NSDictionary* patient;
//
//    if (_doctorQueueTableView && doctorWaitArray.count >0) {
//        patient = [[doctorWaitArray objectAtIndex:indexPath.row] objectForKey:OPEN_VISITS_PATIENT];
//    }else if(_pharmacyQueueTableView && pharmacyWaitArray.count >0){
//        patient = [[pharmacyWaitArray objectAtIndex:indexPath.row]objectForKey:OPEN_VISITS_PATIENT];
//    }
//
//    if ([pendingPatients.allKeys containsObject:[patient objectForKey:PATIENTID]]) {
//        [ColorMe addBorder:cell.layer withWidth:1 withColor:[UIColor yellowColor]];
//    }
//}

- (IBAction)sortBySelected:(id)sender {
    
    // Request patient's that are currently checked-in
    [mobileFacade findAllOpenVisitsAndOnCompletion:^(NSArray *allObjectsFromSearch, NSError *error) {
        doctorWaitArray = [NSArray arrayWithArray:allObjectsFromSearch];
        
        // Filter results to patient's that haven't seen the doctor
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"%K == %@", DOCTOROUT, nil];
        doctorWaitArray = [NSMutableArray arrayWithArray:[doctorWaitArray filteredArrayUsingPredicate:predicate]];
        
        if(_prioritySelector.selectedSegmentIndex == 0) {
            // Sort queue by priority
            [self sortArray:1 by:PRIORITY inAscendingOrder:NO];
        }else if(_prioritySelector.selectedSegmentIndex == 1) {
            // Sort queue by wait time
            [self sortArray:1 by:TRIAGEOUT inAscendingOrder:YES];
        }
        
        [_doctorQueueTableView reloadData];
    }];
}

- (IBAction)tryAndSyncAllPendingObjects:(id)sender {
    // This will show HUD in tableview to show alert the user that the system is working
    [self showIndeterminateHUDInView:self.view withText:@"Searching" shouldHide:NO afterDelay:0 andShouldDim:YES];
    [qm sendArrayOfQueuedObjectsToServer:pendingPatients onCompletion:^(id<BaseObjectProtocol> data, NSError *error)
    {
        if (!data && error)
        {
            [FIUAppDelegate getNotificationWithColor:AJNotificationTypeRed Animation:AJLinedBackgroundTypeAnimated WithMessage:@"Could not sync all pending objects. Try again later." inView:self.view];
        }
        [self displayPendingButtonIfNecessary];
        /** This will remove the HUD since the search is complete */
        [self HideALLHUDDisplayInView:self.view];
    }];
}

@end