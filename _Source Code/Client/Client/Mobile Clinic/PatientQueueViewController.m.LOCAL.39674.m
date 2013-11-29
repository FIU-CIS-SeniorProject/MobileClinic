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

@interface PatientQueueViewController () {
    NSArray * queueArray;
}

@property (strong, nonatomic) UIPopoverController * pop;
@end

@implementation QueueTableCell
@end

@implementation PatientQueueViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.stationChosen = ((StationNavigationController *)self.navigationController).stationChosen;
    [self.navigationItem setTitle:[self.stationChosen intValue] == 2 ? @"Doctor" : @"Pharmacy"];
    UIBarButtonItem * menu = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(popOverMenu)];
    [self.navigationItem setLeftBarButtonItem:menu];
}

-(void)popOverMenu{
    
    if(self.pop != nil){
        [self.pop dismissPopoverAnimated:YES];
        self.pop = nil;
        return;
    }
    // get datepicker view
    MenuViewController *datepicker = [self getViewControllerFromiPadStoryboardWithName:@"menuPopover"];
    
    // Instatiate popover if not available
    //    if (!pop) {
    //        pop = [[UIPopoverController alloc]initWithContentViewController:datepicker];
    //    }
    self.pop = [[UIPopoverController alloc]initWithContentViewController:datepicker];
    
    // set how the screen should return
    // set the age to the date the screen returns
    [datepicker setScreenHandler:^(id object, NSError *error) {
        [self.pop dismissPopoverAnimated:YES];
    }];
    
    // show the screen beside the button
    CGRect leftBarFrame = CGRectMake(0, 5, 10, 15);
    [self.pop presentPopoverFromRect:leftBarFrame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}


- (void)viewWillAppear:(BOOL)animated {

    MobileClinicFacade *mobileFacade = [[MobileClinicFacade alloc] init];
    UINavigationBar *navbar = [self.navigationController navigationBar];
    
    // Request patient's that are currently checked-in
    [mobileFacade findAllOpenVisitsAndOnCompletion:^(NSArray *allObjectsFromSearch, NSError *error) {
      
        queueArray = [NSArray arrayWithArray:allObjectsFromSearch];
        
        // Settings with respect to station chosen
        switch ([[self stationChosen] intValue]) {
            case 2: {
                [navbar setTintColor:[UIColor blueColor]];
                
                // Filter results to patient's that haven't seen the doctor
                NSPredicate * predicate = [NSPredicate predicateWithFormat:@"%K == %@", DOCTOROUT, nil];
                queueArray = [NSMutableArray arrayWithArray:[queueArray filteredArrayUsingPredicate:predicate]];
                
                // Sort queue by priority
                [self sortBy:PRIORITY inAscendingOrder:YES];
            }
                break;
            case 3: {
                [navbar setTintColor:[UIColor greenColor]];
                
                // Filter results (Seen doctor & need to see pharmacy)
                NSPredicate * predicate = [NSPredicate predicateWithFormat:@"%K != %@", DOCTOROUT, nil];
                queueArray = [NSMutableArray arrayWithArray:[queueArray filteredArrayUsingPredicate:predicate]];
                
                // Sort queue by time patient left doctor's station
                [self sortBy:DOCTOROUT inAscendingOrder:NO];
            }
                break;
            default:
                break;
        }
        
        [_queueTableView reloadData];
    }];
}

// Sorts queue for category specified in ascending or decending order
- (void)sortBy:(NSString *)sortCategory inAscendingOrder:(BOOL)order {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:sortCategory ascending:order];

    NSArray *sortDescriptorArray = [NSArray arrayWithObject:sortDescriptor];
    
    queueArray = [NSMutableArray arrayWithArray:[queueArray sortedArrayUsingDescriptors:sortDescriptorArray]];
}

- (void)viewDidUnload {
    [self setQueueTableView:nil];
    [super viewDidUnload];
}

// Defines number of sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Defines number of cells in table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //NSLog(@"COUNT OF QUEUE RESULTS: %d", queueArray.count);
    return queueArray.count;
}

// Populate cells with respective content
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"queueCell";
    
    QueueTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(!cell)
        cell = [[QueueTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    NSDictionary *visitDic = [[NSDictionary alloc]initWithDictionary:[queueArray objectAtIndex:indexPath.row]];
    
    NSDictionary *patientDic = [visitDic objectForKey:OPEN_VISITS_PATIENT];
    
    // Set Priority Indicator color
    // Hide it for Pharmacy
    if([[self stationChosen]intValue] == 3)
        cell.priorityIndicator.backgroundColor = [UIColor whiteColor];
    
    // Show for Doctor
    else if([[visitDic objectForKey:PRIORITY]intValue] == 0)
        cell.priorityIndicator.backgroundColor = [UIColor greenColor];
    else if([[visitDic objectForKey:PRIORITY]intValue] == 1)
        cell.priorityIndicator.backgroundColor = [UIColor yellowColor];
    else if([[visitDic objectForKey:PRIORITY]intValue] == 2)
        cell.priorityIndicator.backgroundColor = [UIColor redColor];
    
    // Display contents of cells
    if ([[patientDic objectForKey:PICTURE]isKindOfClass:[NSData class]]) {
        UIImage *image = [UIImage imageWithData: [patientDic objectForKey:PICTURE]];
        [cell.patientPhoto setImage:image];
    }
    
    NSDate *date = [patientDic objectForKey:DOB];
    BOOL doesDOBExist = ([date isKindOfClass:[NSDate class]] && date);
    NSString *firstName = [patientDic objectForKey:FIRSTNAME];
    NSString *familyName = [patientDic objectForKey:FAMILYNAME];
    
    cell.patientName.text = [NSString stringWithFormat:@"%@ %@", firstName, familyName];
    cell.patientAge.text = [NSString stringWithFormat:@"%i Years Old",[[NSDate convertSecondsToNSDate:[patientDic objectForKey:DOB]]getNumberOfYearsElapseFromDate]];
    cell.patientDOB.text = (doesDOBExist)?[[patientDic objectForKey:DOB]convertNSDateFullBirthdayString]:@"Not Available";
    
    return cell;
}

// Action upon selecting cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Sets color of cell when selected
    [ColorMe ColorTint:[[tableView cellForRowAtIndexPath:indexPath]layer] forCustomColor:[UIColor lightGrayColor]];
    
    [UIView animateWithDuration:.3 animations:^{
        [ColorMe ColorTint:[[tableView cellForRowAtIndexPath:indexPath]layer] forCustomColor:[UIColor clearColor]];
    }];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Push to doctor & pharmacy view controllers
    // This is Visit and Patient Data Bundle
    NSMutableDictionary * patientDic = [[NSMutableDictionary alloc]initWithDictionary:[queueArray objectAtIndex:indexPath.row]];
    
    // Lock patients / visit
    MobileClinicFacade*  mobileFacade = [[MobileClinicFacade alloc] init];
    [mobileFacade updateVisitRecord:patientDic andShouldUnlock:NO andShouldCloseVisit:NO onCompletion:^(NSDictionary *object, NSError *error) {
        if(!object){
            [FIUAppDelegate getNotificationWithColor:AJNotificationTypeRed Animation:AJLinedBackgroundTypeDisabled WithMessage:error.localizedDescription inView:self.view];
        }else{
            if([[self stationChosen]intValue] == 2) {
                DoctorPatientViewController * newView = [self getViewControllerFromiPadStoryboardWithName:@"doctorPatientViewController"];
                [newView setPatientData:patientDic];
                [self.navigationController pushViewController:newView animated:YES];
            }
            else if ([[self stationChosen]intValue] == 3) {
                PharmacyPatientViewController * newView = [self getViewControllerFromiPadStoryboardWithName:@"pharmacyPatientViewController"];
                [newView setPatientData:patientDic];
                [self.navigationController pushViewController:newView animated:YES];
            }
        }
    }];
}

//// Coloring cell depending on priority
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    if([[self stationChosen] intValue] == 2) {
//        NSDictionary * visitDic = [[NSDictionary alloc]initWithDictionary:[queueArray objectAtIndex:indexPath.row]];
//    
//        // Set priority color
//        if([[visitDic objectForKey:PRIORITY]intValue] == 0)
//            cell.backgroundColor = [UIColor yellowColor];
//        else if([[visitDic objectForKey:PRIORITY]intValue] == 1)
//            cell.backgroundColor = [UIColor purpleColor];
//        else if([[visitDic objectForKey:PRIORITY]intValue] == 2)
//            cell.backgroundColor = [UIColor redColor];
//    }
//}

//- (void)reloadTableView{
//}

@end
