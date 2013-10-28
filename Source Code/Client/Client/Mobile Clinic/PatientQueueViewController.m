// The MIT License (MIT)
//
// Copyright (c) 2013 Florida International University
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//  PatientQueueViewController.m
//  Mobile Clinic
//
//  Created by Rigo Hernandez on 3/10/13.
//
#import "PatientQueueViewController.h"
#import "DoctorPatientViewController.h"
#import "PharmacyPatientViewController.h" 

@interface PatientQueueViewController ()
{
    NSArray *queueArray;
    MobileClinicFacade *mobileFacade;
}

@property (strong, nonatomic) UIPopoverController * pop;
@end

@implementation QueueTableCell
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
    
    self.stationChosen = ((StationNavigationController *)self.navigationController).stationChosen;
    [self.navigationItem setTitle:[self.stationChosen intValue] == 2 ? @"Doctor" : @"Pharmacy"];
    
    UIBarButtonItem * menu = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(popOverMenu)];
    [self.navigationItem setLeftBarButtonItem:menu];
    
    if([[self stationChosen] intValue] == 3)
    {
        [_prioritySelector setUserInteractionEnabled:NO];
        [_prioritySelector removeSegmentAtIndex:1 animated:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    // This will show HUD in tableview to show alert the user that the system is working
    [self showIndeterminateHUDInView:_queueTableView withText:@"Searching" shouldHide:NO afterDelay:0 andShouldDim:NO];
    
    mobileFacade = [[MobileClinicFacade alloc] init];
    UINavigationBar *navbar = [self.navigationController navigationBar];
    
    // Request patient's that are currently checked-in
    [mobileFacade findAllOpenVisitsAndOnCompletion:^(NSArray *allObjectsFromSearch, NSError *error)
    {
        if (!allObjectsFromSearch && error )
        {
            [FIUAppDelegate getNotificationWithColor:AJNotificationTypeOrange Animation:AJLinedBackgroundTypeAnimated WithMessage:error.localizedDescription inView:self.view];
        }
        else
        {
            queueArray = [NSArray arrayWithArray:allObjectsFromSearch];
        
            // Settings with respect to station chosen
            switch ([[self stationChosen] intValue])
            {
                case DOCTORSTATION:
                    {
                        [navbar setTintColor:[UIColor blueColor]];
                
                        // Filter results to patient's that haven't seen the doctor
                        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"%K == %@", DOCTOROUT, nil];
                        queueArray = [NSMutableArray arrayWithArray:[queueArray filteredArrayUsingPredicate:predicate]];
                
                        // Sort queue by priority
                        [self sortBy:PRIORITY inAscendingOrder:NO];
                    }
                    break;
                case PHARMACISTSTATION:
                    {
                        [navbar setTintColor:[UIColor greenColor]];
                
                        // Filter results (Seen doctor & need to see pharmacy)
                        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"%K != %@", DOCTOROUT, nil];
                        queueArray = [NSMutableArray arrayWithArray:[queueArray filteredArrayUsingPredicate:predicate]];
                
                        // Sort queue by time patient left doctor's station
                        [self sortBy:DOCTOROUT inAscendingOrder:YES];
                    }
                    break;
                default:
                    break;
            }
        
            [_queueTableView reloadData];
        }
        // This will remove the HUD since the search is complete
        [self HideALLHUDDisplayInView:_queueTableView];
    }];
}

// Sorts queue for category specified in ascending or decending order
- (void)sortBy:(NSString *)sortCategory inAscendingOrder:(BOOL)order
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:sortCategory ascending:order];
    NSArray *sortDescriptorArray = [NSArray arrayWithObject:sortDescriptor];
    queueArray = [NSMutableArray arrayWithArray:[queueArray sortedArrayUsingDescriptors:sortDescriptorArray]];
}

- (void)popOverMenu
{
    if(self.pop != nil)
    {
        [self.pop dismissPopoverAnimated:YES];
        self.pop = nil;
        return;
    }
    
    // get datepicker view
    MenuViewController *menuPicker = [self getViewControllerFromiPadStoryboardWithName:@"menuPopover"];
    
    // Instatiate popover if not available
    self.pop = [[UIPopoverController alloc]initWithContentViewController:menuPicker];
    
    // set how the screen should return
    // set the age to the date the screen returns
    [menuPicker setScreenHandler:^(id object, NSError *error)
    {
        [self.pop dismissPopoverAnimated:YES];
    }];
    
    // show the screen beside the button
    CGRect leftBarFrame = CGRectMake(0, 5, 10, 15);
    [self.pop presentPopoverFromRect:leftBarFrame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void)viewDidUnload
{
    [self setQueueTableView:nil];
    [self setPrioritySelector:nil];
    [super viewDidUnload];
}

// Defines number of sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// Defines number of cells in table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return queueArray.count;
}

// Populate cells with respective content
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"queueCell";
    
    QueueTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(!cell)
    {
        cell = [[QueueTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *visitDic = [[NSDictionary alloc]initWithDictionary:[queueArray objectAtIndex:indexPath.row]];
    NSDictionary *patientDic = [visitDic objectForKey:OPEN_VISITS_PATIENT];
    
    // Set Priority Indicator color
    // Hide it for Pharmacy
    if([[self stationChosen]intValue] == 3)
    {
        cell.priorityIndicator.backgroundColor = [UIColor darkGrayColor];
    }
    // Show for Doctor
    else if([[visitDic objectForKey:PRIORITY]intValue] == 0)
    {
        cell.priorityIndicator.backgroundColor = [UIColor greenColor];
    }
    else if([[visitDic objectForKey:PRIORITY]intValue] == 1)
    {
        cell.priorityIndicator.backgroundColor = [UIColor yellowColor];
    }
    else if([[visitDic objectForKey:PRIORITY]intValue] == 2)
    {
        cell.priorityIndicator.backgroundColor = [UIColor redColor];
    }
    
    // Display contents of cells
    if ([[patientDic objectForKey:PICTURE]isKindOfClass:[NSData class]])
    {
        UIImage *image = [UIImage imageWithData: [patientDic objectForKey:PICTURE]];
        [cell.patientPhoto setImage:image];
    }
    else
    {
        [cell.patientPhoto setImage:[UIImage imageNamed:@"userImage.jpeg"]];
    }
    
    NSString *firstName = [patientDic objectForKey:FIRSTNAME];
    NSString *familyName = [patientDic objectForKey:FAMILYNAME];
    
    cell.patientName.text = [NSString stringWithFormat:@"%@ %@", firstName, familyName];
    cell.patientConditionTitle.text = [visitDic objectForKey:CONDITIONTITLE];
    
    // Display Nurse or Doctor's name depending on the station
    if([[self stationChosen]intValue] == 2)
    {
        cell.employeeName.text = [visitDic objectForKey:NURSEID];
    }
    else if([[self stationChosen]intValue] == 3)
    {
        cell.employeeName.text = [visitDic objectForKey:DOCTORID];
    }
    
    // Calculate wait time since patient left triage
    NSDate *now = [NSDate date];
    NSDate *triageOut = [NSDate convertSecondsToNSDate:[visitDic objectForKey:TRIAGEOUT]];
    NSTimeInterval secsSinceTriageOut = [now timeIntervalSinceDate:triageOut];
    NSInteger waitInSeconds = floor(secsSinceTriageOut);
    NSInteger waitInMinutes = waitInSeconds / 60;
    
    cell.patientWaitTime.text = [NSString stringWithFormat:@"%i min(s)", waitInMinutes];
    
    return cell;
}

// Action upon selecting cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Sets color of cell when selected
    [ColorMe ColorTint:[[tableView cellForRowAtIndexPath:indexPath]layer] forCustomColor:[UIColor lightGrayColor]];
    
    [UIView animateWithDuration:.3 animations:
     ^{
        [ColorMe ColorTint:[[tableView cellForRowAtIndexPath:indexPath]layer] forCustomColor:[UIColor clearColor]];
     }];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Push to doctor & pharmacy view controllers
    // This is Visit and Patient Data Bundle
    NSMutableDictionary * patientDic = [[NSMutableDictionary alloc]initWithDictionary:[queueArray objectAtIndex:indexPath.row]];
    
    // Lock patients / visit
    MobileClinicFacade*  mobileFacade = [[MobileClinicFacade alloc] init];
    [mobileFacade updateVisitRecord:patientDic andShouldUnlock:NO andShouldCloseVisit:NO onCompletion:^(NSDictionary *object, NSError *error)
    {
        if(!object)
        {
            [FIUAppDelegate getNotificationWithColor:AJNotificationTypeRed Animation:AJLinedBackgroundTypeDisabled WithMessage:error.localizedDescription inView:self.view];
        }
        else
        {
            if([[self stationChosen]intValue] == 2)
            {
                DoctorPatientViewController * newView = [self getViewControllerFromiPadStoryboardWithName:@"doctorPatientViewController"];
                [newView setPatientData:patientDic];
                [self.navigationController pushViewController:newView animated:YES];
            }
            else if ([[self stationChosen]intValue] == 3)
            {
                PharmacyPatientViewController * newView = [self getViewControllerFromiPadStoryboardWithName:@"pharmacyPatientViewController"];
                [newView setPatientData:patientDic];
                [self.navigationController pushViewController:newView animated:YES];
            }
        }
    }];
}

//Coloring cell depending on priority
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

- (IBAction)sortBySelected:(id)sender
{
    // Request patient's that are currently checked-in
    [mobileFacade findAllOpenVisitsAndOnCompletion:^(NSArray *allObjectsFromSearch, NSError *error)
    {
        queueArray = [NSArray arrayWithArray:allObjectsFromSearch];

        // Filter results to patient's that haven't seen the doctor
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"%K == %@", DOCTOROUT, [NSNumber numberWithInt:0]];
        queueArray = [NSMutableArray arrayWithArray:[queueArray filteredArrayUsingPredicate:predicate]];
    
        if(_prioritySelector.selectedSegmentIndex == 0)
        {
            // Sort queue by priority
            [self sortBy:PRIORITY inAscendingOrder:NO];
        }
        else if(_prioritySelector.selectedSegmentIndex == 1)
        {
            // Sort queue by wait time
            [self sortBy:TRIAGEOUT inAscendingOrder:YES];
        }
    
        [_queueTableView reloadData];
    }];
}
@end