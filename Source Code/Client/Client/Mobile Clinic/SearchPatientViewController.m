//
//  SearchPatientViewController.m
//  Mobile Clinic
//
//  Created by sebastian a zanlongo on 2/18/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import "SearchPatientViewController.h"
#import "MobileClinicFacade.h"
#import "FingerprintObject.h"
#import "PBVerificationController.h"
#import "PatientObject.h"

@interface SearchPatientViewController (){

}

@end

@implementation SearchPatientViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    if (!_patientData)
        _patientData = [[NSMutableDictionary alloc]init];
    
    // Set height of rows of result table
    _searchResultTableView.rowHeight = 75;
    [_searchResultTableView setDelegate:self];
    [_searchResultTableView setDataSource:self];
}

- (void)setScreenHandler:(ScreenHandler)myHandler {
    // Responsible for dismissing the screen
    handler = myHandler;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

// Defines number of sections in the table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Defines number of row in the table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _patientSearchResultsArray.count;
}

// Defines content of cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"resultCell";
    
    PatientResultTableCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(!cell) {
        cell = [[PatientResultTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        UINib * nib = [UINib nibWithNibName:@"PatientResultTableCellView" bundle:nil];
        cell = [nib instantiateWithOwner:nil options:nil][0];
    }
    
    NSDictionary* base = [[NSDictionary alloc]initWithDictionary:[_patientSearchResultsArray objectAtIndex:indexPath.row]];
    
    // Display contents of cells
    if ([[base objectForKey:PICTURE]isKindOfClass:[NSData class]]) {
        UIImage* image = [UIImage imageWithData: [base objectForKey:PICTURE]];
        [cell.patientImage setImage:image];
    }else{
        [cell.patientImage setImage:[UIImage imageNamed:@"userImage.jpeg"]];
    }
    
    cell.patientName.text = [NSString stringWithFormat:@"%@ %@", [base objectForKey:FIRSTNAME], [base objectForKey:FAMILYNAME]];
   
    // All Things that are Date are NSNumbers...
    NSNumber* numberDate = [base objectForKey:DOB];
    
    NSString* yearsOld = @" Not Available";
    
    NSString* birthday = yearsOld;
    
    //convert nsnumber to date
    if (numberDate) {
        NSDate* date = [NSDate convertSecondsToNSDate:numberDate];
        
        yearsOld = [NSString stringWithFormat:@"%i Years Old",[date getNumberOfYearsElapseFromDate]];
                    
        birthday = [date convertNSDateFullBirthdayString];
    }
    
    cell.patientAge.text = yearsOld;
                    
    cell.patientDOB.text = birthday;
                    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary* patient = [NSMutableDictionary dictionaryWithDictionary:[_patientSearchResultsArray objectAtIndex:indexPath.row]];
    NSString * lockedBy = [patient  objectForKey:ISLOCKEDBY];
    BOOL isOpen = [[patient  objectForKey:ISOPEN]boolValue];
    
    if(![lockedBy isEqualToString:[BaseObject getCurrenUserName ]]) {
        [[[tableView cellForRowAtIndexPath:indexPath]contentView]setBackgroundColor:[UIColor yellowColor]];
    }else{
        [[[tableView cellForRowAtIndexPath:indexPath]contentView]setBackgroundColor:[UIColor whiteColor]];
    }
    
    if (isOpen) {
        [ColorMe addBorder:cell.layer withWidth:3 withColor:[UIColor redColor]];
    }else{
        [ColorMe addBorder:cell.layer withWidth:1 withColor:[UIColor blackColor]];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // Sets color of cell when selected
    [[[tableView cellForRowAtIndexPath:indexPath]contentView]setBackgroundColor:[UIColor grayColor]];
    
    // TODO: MAKE SURE THAT THIS OBJECT IS NOT IN USE AND THAT YOU LOCK IT WHEN YOU USE IT.
    
    _patientData = [NSMutableDictionary dictionaryWithDictionary:[_patientSearchResultsArray objectAtIndex:indexPath.row]];
    
    handler(_patientData, nil);
}

- (IBAction)searchByNameButton:(id)sender {
    // Check if there is at least one name
    switch (_mode) {
        case kTriageMode:
            [self broadSearchForPatient];
            break;
        default:
            [self broadSearchForPatient];
            break;
    }
}

- (void)broadSearchForPatient {
     
    //this will remove spaces BEFORE AND AFTER the string. I am leaving spaces in the middle because we might have names that are 2+ words
    //this also updates the fields with the new format so the user knows that its being trimmed
    //also, keep in mind that adding several spaces after text adds a period
    
    _patientNameField.text = [_patientNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    _familyNameField.text = [_familyNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    MobileClinicFacade* mobileFacade = [[MobileClinicFacade alloc]init];
    
    if (_patientNameField.text.isNotEmpty || _familyNameField.text.isNotEmpty) {
        /** This will should HUD in tableview to show alert the user that the system is working */
        [self showIndeterminateHUDInView:_searchResultTableView withText:@"Searching" shouldHide:NO afterDelay:0 andShouldDim:NO];
        
        [mobileFacade findPatientWithFirstName:_patientNameField.text orLastName:_familyNameField.text onCompletion:^(NSArray *allObjectsFromSearch, NSError *error) {
            if (allObjectsFromSearch) {
                // Get all the result from the query
                _patientSearchResultsArray  = [NSArray arrayWithArray:allObjectsFromSearch];
                
                // Redisplay the information
                [_searchResultTableView reloadData];
                [FIUAppDelegate getNotificationWithColor:AJNotificationTypeBlue Animation:AJLinedBackgroundTypeAnimated WithMessage:error.localizedDescription inView:self.view];
            }else{
                [FIUAppDelegate getNotificationWithColor:AJNotificationTypeRed Animation:AJLinedBackgroundTypeAnimated WithMessage:error.localizedDescription inView:self.view];
            }
            /** This will remove the HUD since the search is complete */
            [self HideALLHUDDisplayInView:_searchResultTableView];
        }];
    }
}

- (void)presentNoEnrolledFingersAlert {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"No enrolled fingers" message:@"Please enroll at least one finger to be able to verify" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
}

- (void)presentVerificationController: (PBVerificationController*)verificationController {
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:verificationController];
    
    NSLog(@"Verifying with timeout %d, security %d verifyAgainstAllFingers %d.", verificationController.config.timeout, verificationController.config.falseAcceptRate, verificationController.verifyAgainstAllFingers);
    
    [self presentViewController:navController animated:YES completion:nil];
}

- (IBAction)searchByFingerprintButton:(id)sender {
    /** This will should HUD in tableview to show alert the user that the system is working */
    [self showIndeterminateHUDInView:_searchResultTableView withText:@"Searching" shouldHide:NO afterDelay:0 andShouldDim:YES];
    
    MobileClinicFacade *mcf = [[MobileClinicFacade alloc] init];
    
    [mcf findPatientWithFirstName:nil orLastName:nil onCompletion:^(NSArray *allObjectsFromSearch, NSError *error) {
        if([allObjectsFromSearch count] > 0) {
            _patientSearchResultsArray = [NSArray arrayWithArray:allObjectsFromSearch];
            
            FingerprintObject *fo = [[FingerprintObject alloc] initWithEnrolledFingers:allObjectsFromSearch];
            
            if (fo) {
                PBVerificationController* verificationController = [[PBVerificationController alloc] initWithDatabase:fo andFingers:[fo getEnrolledFingers] andDelegate:self andTitle:@"Swipe to search ..."];
                [self presentVerificationController:verificationController];
            }
            
            
            
            /* Present verification controller as modal. */
            
        }else{
            /* No enrolled fingers, nothing to verify against. */
            [self presentNoEnrolledFingersAlert];
        }
        /** This will remove the HUD since the search is complete */
        [self HideALLHUDDisplayInView:_searchResultTableView];
    }];
    }

- (void)verificationVerifiedFinger:(PBBiometryFinger *)finger {
   
    if(finger != nil) {
        _patientSearchResultsArray = [NSArray arrayWithObject:[FingerprintObject findPatientFromArrayOfPatients:_patientSearchResultsArray withFinger:finger]];
        [self dismissViewControllerAnimated:YES completion:^{
            [_searchResultTableView reloadData];
        }];
    }else{
        /* Match failed, verification rejected. */
    }
}

// Hides keyboard when whitespace is pressed
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)resetData {
    [_patientData removeAllObjects];
    [_familyNameField setText:@""];
    [_patientNameField setText:@""];
    _patientSearchResultsArray = nil;
    [_searchResultTableView reloadData];
}

@end
