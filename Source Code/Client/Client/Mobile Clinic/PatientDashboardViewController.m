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
#import "UserObject.h"
#import "VisitationObject.h"
#import "PatientObject.h"


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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINavigationBar *bar =[self.navigationController navigationBar];
    
    [bar setTintColor:[ColorMe colorFor:PALEORANGE]];
    
    qm = [[QueueManager alloc]init];
	// Do any additional setup after loading the view.
    
    _prioritySelector.selectedSegmentIndex = 0;
    
    mobileFacade = [[MobileClinicFacade alloc] init];
    
    [self reloadPharmacyAndDoctor];
}

-(void)reloadPharmacyAndDoctor{
    /** This will should HUD in tableview to show alert the user that the system is working */
    [self showIndeterminateHUDInView:_doctorQueueTableView withText:@"Searching" shouldHide:NO afterDelay:0 andShouldDim:YES];
    [self.pharmacyQueueTableView setScrollEnabled:NO];
    /** This will should HUD in tableview to show alert the user that the system is working */
    [self showIndeterminateHUDInView:_pharmacyQueueTableView withText:@"Searching" shouldHide:NO afterDelay:0 andShouldDim:YES];
    [self.doctorQueueTableView setScrollEnabled:NO];
    
    // Request patient's that are currently checked-in
    [mobileFacade findAllOpenVisitsAndOnCompletion:^(NSArray *allObjectsFromSearch, NSError *error) {
        doctorWaitArray = [NSArray arrayWithArray:allObjectsFromSearch];
        pharmacyWaitArray = [NSArray arrayWithArray:allObjectsFromSearch];
        
        // Filter results to patient's that haven't seen the doctor
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"%K == %@", DOCTOROUT, nil];
        doctorWaitArray = [NSMutableArray arrayWithArray:[doctorWaitArray filteredArrayUsingPredicate:predicate]];
        
        // Sort queue by priority
        [self sortArray:1 by:PRIORITY inAscendingOrder:NO];
        [self FilterPharmacy];
        
        [_doctorQueueTableView reloadData];
        [_pharmacyQueueTableView reloadData];
        
        /** This will remove the HUD since the search is complete */
        [self HideALLHUDDisplayInView:_pharmacyQueueTableView];
        
        /** This will remove the HUD since the search is complete */
        [self HideALLHUDDisplayInView:_doctorQueueTableView];
        [self.pharmacyQueueTableView setScrollEnabled:YES];
        [self.doctorQueueTableView setScrollEnabled:YES];
    }];
}
-(void)FilterPharmacy{
    // Filter results (Seen doctor & need to see pharmacy)
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"%K != %@", DOCTOROUT, nil];
    pharmacyWaitArray = [NSMutableArray arrayWithArray:[pharmacyWaitArray filteredArrayUsingPredicate:predicate2]];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self displayPendingButtonIfNecessary];
    [_doctorQueueTableView setBackgroundColor:[ColorMe colorFor:PALEPURPLE]];
    [_pharmacyQueueTableView setBackgroundColor:[ColorMe colorFor:DARKGREEN]];
    
    [_refreshDoctor setBackgroundColor:[ColorMe colorFor:PALEPURPLE]];
    [ColorMe addBorder:_refreshDoctor.layer withWidth:2 withColor:[UIColor blackColor]];
    
    [_refreshPharmacy setBackgroundColor:[ColorMe colorFor:DARKGREEN]];
    [ColorMe addBorder:_refreshPharmacy.layer withWidth:2 withColor:[UIColor blackColor]];

    
}

-(void)displayPendingButtonIfNecessary{
    pendingPatients = [NSMutableArray arrayWithArray:[qm getAllQueuedObjects]];
    
    [_PendingSyncButton setTitle:[NSString stringWithFormat:@"Tap to send %i pending patients",pendingPatients.count] forState:UIControlStateNormal];
    
    [_PendingSyncButton setHidden:(pendingPatients.count == 0)];
}
// Sorts queue for category specified in ascending or decending order
- (void)sortArray:(int)array by:(NSString *)sortCategory inAscendingOrder:(BOOL)order {
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:sortCategory ascending:order];
    
    NSArray *sortDescriptorArray = [NSArray arrayWithObject:sortDescriptor];

    doctorWaitArray = [NSMutableArray arrayWithArray:[doctorWaitArray sortedArrayUsingDescriptors:sortDescriptorArray]];

}

-(void)viewDidUnload{
    
    [self setPendingSyncButton:nil];
    [self setDoctorQueueTableView:nil];
    [self setPharmacyQueueTableView:nil];
    [self setPrioritySelector:nil];
    doctorWaitArray = nil;
    pharmacyWaitArray = nil;
    pendingPatients = nil;
    mobileFacade = nil;
    qm = nil;
}
-(void)dealloc{
    [self.pharmacyQueueTableView setDelegate:nil];
    [self.doctorQueueTableView setDelegate:nil];
    [self.pharmacyQueueTableView setDataSource:nil];
    [self.doctorQueueTableView setDataSource:nil];
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
    int doc = doctorWaitArray.count;
    int pharm = pharmacyWaitArray.count;
    
    [_doctorWaitLabel setText:[NSString stringWithFormat:@"%i Patients waiting to see the doctor",doc]];
    if (_pharmacyFilter.selectedSegmentIndex == 0) {
        [_pharmacyWaitLabel setText:[NSString stringWithFormat:@"%i Patients waiting to see the pharmacist",pharm]];
    }else{
        [_pharmacyWaitLabel setText:[NSString stringWithFormat:@"%i Patients were seen in the past 24 hours",pharm]];
    }
    
    
    if(tableView == _doctorQueueTableView)
        return doc;
    
    return pharm;
    
}

// Populate cells with respective content
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *visitDic;
    NSDictionary *patientDic;
    
    static NSString *CellIdentifier = @"dashboardCell";
    DashboardTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(!cell){
        cell = [[DashboardTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSArray *queueArray;
    
    if(tableView == _doctorQueueTableView) {
        queueArray = [NSArray arrayWithArray:doctorWaitArray];
    }else if(tableView == _pharmacyQueueTableView){
        queueArray = [NSArray arrayWithArray:pharmacyWaitArray];
    }else{
        NSLog(@"CRASHED!!!!!!!!");
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
    
    if (tableView == _doctorQueueTableView) {
        cell.patientWaitTime.text = [NSString stringWithFormat:@"%i min(s)", waitInMinutes];
    }else{
        [cell.patientWaitTime setText:[triageOut convertNSDateToString]];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setBackgroundColor:[UIColor whiteColor]];
}
#pragma mark - Administrator Deletion
#pragma mark -
-(NSDictionary*)getObjectForTable:(UITableView*)table atIndex:(NSIndexPath*)index{
    NSDictionary* queue;
    if (table == _doctorQueueTableView) {
        queue = [doctorWaitArray objectAtIndex:index.row];
    }else{
        queue = [pharmacyWaitArray objectAtIndex:index.row];
    }
    
    return queue;
}

-(BOOL)isLegalObjectForTable:(UITableView*)table forIndex:(NSIndexPath*)index{
    
    NSDictionary* patient = [[self getObjectForTable:table atIndex:index]objectForKey:OPEN_VISITS_PATIENT];
    
    if ([[patient objectForKey:PATIENTID]length] == 0) {
        return NO;
    }
    return YES;
    
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (![self isLegalObjectForTable:tableView forIndex:indexPath]) {
        return @"Purge Patient From System";
    }
    return @"Close Patient Visit";
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    UserObject* user = [[UserObject alloc]init];
    
    if (_pharmacyFilter.selectedSegmentIndex == 1) {
        return NO;
    }
    
    switch ([user getUsertypeForCurrentUser]) {
        case kAdministrator:
            return YES;
            break;
        default:
            return NO;
            break;
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSMutableDictionary* visit = [NSMutableDictionary dictionaryWithDictionary:[self getObjectForTable:tableView atIndex:indexPath]];
    
    if ([self isLegalObjectForTable:tableView forIndex:indexPath]) {
        /** This will should HUD in tableview to show alert the user that the system is working */
        [self showIndeterminateHUDInView:self.view withText:@"Syncronizing..." shouldHide:NO afterDelay:0 andShouldDim:YES];
        MobileClinicFacade* mcf = [[MobileClinicFacade alloc]init];
        [mcf checkoutVisit:visit forPatient:[visit objectForKey:OPEN_VISITS_PATIENT] AndWillUlockOnCompletion:^(NSDictionary *object, NSError *error) {
            if (!object) {
                [FIUAppDelegate getNotificationWithColor:AJNotificationTypeOrange Animation:AJLinedBackgroundTypeAnimated WithMessage:error.localizedDescription inView:self.view];
            }else{
                [self reloadPharmacyAndDoctor];
            }
            [self HideALLHUDDisplayInView:self.view];
        }];
    }else{
        [[[PatientObject alloc]init]deleteDatabaseDictionaryObject:[visit objectForKey:OPEN_VISITS_PATIENT]];
        [visit removeObjectForKey:OPEN_VISITS_PATIENT];
        [[[VisitationObject alloc]init]deleteDatabaseDictionaryObject:visit];
        [self reloadPharmacyAndDoctor];
    }
    
}
#pragma mark - Sort Methods
#pragma mark -
- (IBAction)refresh:(id)sender {
    [self reloadPharmacyAndDoctor];
}

- (IBAction)sortBySelected:(id)sender {
    
    /** Extracted sorting code and removed the other code that made expensive server call */
    if(_prioritySelector.selectedSegmentIndex == 0) {
        // Sort queue by priority
        [self sortArray:1 by:PRIORITY inAscendingOrder:NO];
    }else if(_prioritySelector.selectedSegmentIndex == 1) {
        // Sort queue by wait time
        [self sortArray:1 by:TRIAGEOUT inAscendingOrder:YES];
    }
    
    [_doctorQueueTableView reloadData];
}

- (IBAction)tryAndSyncAllPendingObjects:(id)sender {
    /** This will should HUD in tableview to show alert the user that the system is working */
    [self showIndeterminateHUDInView:self.view withText:@"Searching" shouldHide:NO afterDelay:0 andShouldDim:YES];
    [qm sendArrayOfQueuedObjectsToServer:pendingPatients onCompletion:^(id<BaseObjectProtocol> data, NSError *error) {
        if (!data && error) {
            [FIUAppDelegate getNotificationWithColor:AJNotificationTypeRed Animation:AJLinedBackgroundTypeAnimated WithMessage:@"Could not sync all pending patients. Try again later." inView:self.view];
        }
        [self displayPendingButtonIfNecessary];
        /** This will remove the HUD since the search is complete */
        [self HideALLHUDDisplayInView:self.view];
    }];
}

- (IBAction)filterBy:(id)sender {
    UISegmentedControl* seg = sender;

    if (_pharmacyQueueTableView.scrollEnabled && _doctorQueueTableView.scrollEnabled) {
        [self ShowTextHUDInView:self.pharmacyQueueTableView WithText:@"Fetching..." shouldHide:NO afterDelay:0 andShouldDim:YES];
        [self.pharmacyQueueTableView setScrollEnabled:NO];
        if (seg.selectedSegmentIndex == 0) {
            pharmacyWaitArray = [NSArray arrayWithArray:[mobileFacade GetVisitsForOpenPatients:YES]];
            [_refreshPharmacy setHidden:NO];
            [_refreshDoctor setHidden:NO];
            [self FilterPharmacy];
        }else{
            pharmacyWaitArray = [NSArray arrayWithArray:[mobileFacade GetVisitsForOpenPatients:NO]];
            [_refreshPharmacy setHidden:YES];
            [_refreshDoctor setHidden:YES];
        }
        [_pharmacyQueueTableView reloadData];
        [self HideALLHUDDisplayInView:self.pharmacyQueueTableView];
        [self.pharmacyQueueTableView setScrollEnabled:YES];
    }
    
}

@end
