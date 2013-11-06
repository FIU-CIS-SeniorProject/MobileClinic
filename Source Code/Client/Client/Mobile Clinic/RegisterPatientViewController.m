//
//  RegisterPatientViewController.m
//  Mobile Clinic
//
//  Created by sebastian a zanlongo on 2/18/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//
#define UPDATE_PATIENT_TEXT @"Update Patient"
#define CREATE_PATIENT_TEXT @"Create Patient"

#import "DateController.h"
#import "RegisterPatientViewController.h"
#import "PBManageFingersController.h"
#import "FingerprintObject.h"
#import "PBBiometry.h"
#import "TriagePatientViewController.h"
#import "PatientResultTableCell.h"
#import "BaseObject.h"
#import "StationSwitcher.h"
UIPopoverController * pop;

typedef enum MobileClinicMode{
    kTriageMode,
    kDoctorMode,
    kPharmacistMode
} MCMode;

@interface RegisterPatientViewController ()<CancelDelegate,UIPopoverControllerDelegate,PBVerificationDelegate> {
    PBBiometryUser* user;
    MCMode mode;
    PBManageFingersController* manageFingersController;
    UINavigationController* navControllerManageFingers;
    FingerprintObject* fingerPrintDatabase;
    NSNumber* age;
    NSMutableDictionary* patientData;
    NSArray * patientSearchResultsArray;
}


@end

@implementation RegisterPatientViewController
@synthesize delegate;
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
    
	// Do any additional setup after loading the view.
    [_registerView setBackgroundColor:[ColorMe colorFor:PALEORANGE]];
    
    [ColorMe addGradientToLayer:self.view.layer colorOne:[ColorMe lightGray] andColorTwo:[ColorMe whitishColor]inFrame:self.view.bounds];
    
    [ColorMe addRoundedBlackBorderWithShadowInRect:_patientPhoto.layer];
    
   [_searchView setBackgroundColor:[ColorMe colorFor:PALEORANGE]];
    
    if (!patientData)
        patientData = [[NSMutableDictionary alloc]initWithCapacity:10];
    else
        [self Redisplay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)Redisplay {
    [_patientNameField setText:[patientData objectForKey:FIRSTNAME]];
    [_patientPhoto setImage:[UIImage imageWithData:[patientData objectForKey:PICTURE]]];
    [_familyNameField setText:[patientData objectForKey:FAMILYNAME]];
    [_villageNameField setText:[patientData objectForKey:VILLAGE]];
    [_patientSexSegment setSelectedSegmentIndex:[[patientData objectForKey:SEX]integerValue]];
    NSNumber* dateInSeconds = [patientData objectForKey:DOB];
        NSDate* date = [NSDate convertSecondsToNSDate:dateInSeconds];
     [_patientAgeField setTitle:[NSString stringWithFormat:@"%i Years Old",[date getNumberOfYearsElapseFromDate]] forState:UIControlStateNormal];
}

- (void)viewDidUnload {
    [self setCreatePatientButton:nil];
    [super viewDidUnload];
}

#pragma mark - Register New Patient Methods
#pragma mark -
// Set up the camera source and view controller
- (IBAction)patientPhotoButton:(id)sender {
    
    if (!facade) {
        facade = [[CameraFacade alloc]initWithView:self];
    }
    
    // Added Indeterminate Loader
    MBProgressHUD *progress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [progress setMode:MBProgressHUDModeIndeterminate];
    
    [facade TakePictureWithCompletion:^(id img) {
        
        if(img) {
            // Reduce Image Size
            UIImage* image = img;
            
            UIImage* scaled = [image imageByScalingAndCroppingForSize:CGSizeMake(150, 150)];
            
            // Set the image
            [_patientPhoto setImage:scaled];
            // save picture to object
            [patientData setValue:[scaled convertImageToPNGBinaryData] forKey:PICTURE];
        
        }
        
        [progress hide:YES];
    }];
}

- (IBAction)createPatient:(id)sender {
    // Before doing anything else, chech that all of the fields have been completed
    if (self.validateRegistration) {
        [self.patientNameField resignFirstResponder];
        [self.familyNameField resignFirstResponder];
        [self.villageNameField resignFirstResponder];
        
        /* Age is set when the moment the user sets it through the Popover */

        if (age == nil || [self.patientAgeField.titleLabel.text isEqualToString:@"Tap to set Age"]) {
            [patientData setValue:0 forKey:DOB];
        } else {
            [patientData setValue:age forKey:DOB];
        }        
        [patientData setValue:_patientNameField.text forKey:FIRSTNAME];
        [patientData setValue:_familyNameField.text forKey:FAMILYNAME];
        [patientData setValue:_villageNameField.text forKey:VILLAGE];
        
        [patientData setValue:[NSNumber numberWithInt:_patientSexSegment.selectedSegmentIndex] forKey:SEX];
        [self showIndeterminateHUDInView:self.view withText:@"Loading..." shouldHide:NO afterDelay:0 andShouldDim:YES];
        
        if ([_createPatientButton.titleLabel.text isEqualToString:UPDATE_PATIENT_TEXT]) {
            [self updatedPatient];
        }else if ([_createPatientButton.titleLabel.text isEqualToString:CREATE_PATIENT_TEXT]){
            [self createNewPatient];
        }
    }
}

-(void)updatedPatient{
    /**
     * This will create a patient locally and on the server.
     * The patient created on the server will be locked automatically.
     * This is done because of the workflow of the system
     * To unlock the patient see the documentation for the PatientObject
     */
    
    MobileClinicFacade* mobileFacade = [[MobileClinicFacade alloc]init];
    
    [mobileFacade updateCurrentPatient:patientData AndShouldLock:YES onCompletion:^(NSDictionary *object, NSError *error) {
        if (!object)
            [FIUAppDelegate getNotificationWithColor:AJNotificationTypeRed Animation:AJLinedBackgroundTypeAnimated WithMessage:error.localizedDescription inView:self.view];
        else{
            // Go to Next screen
            TriagePatientViewController* triagePatientViewController = [self getViewControllerFromiPadStoryboardWithName:@"triagePatientViewController"];
            [triagePatientViewController view];
            
            [triagePatientViewController setPatientData:patientData];
            
            [triagePatientViewController populateInformation];
            
            [triagePatientViewController setDelegate:self];
            
            [triagePatientViewController.navigationItem setHidesBackButton:YES];
            
            [self.navigationController pushViewController:triagePatientViewController animated:YES];
        }
        [self HideALLHUDDisplayInView:self.view];
    }];

}

-(void)createNewPatient{
    /**
     * This will create a patient locally and on the server.
     * The patient created on the server will be locked automatically.
     * This is done because of the workflow of the system
     * To unlock the patient see the documentation for the PatientObject
     */
    
    MobileClinicFacade* mobileFacade = [[MobileClinicFacade alloc]init];
    
    [mobileFacade createAndCheckInPatient:patientData onCompletion:^(NSDictionary *object, NSError *error) {
        if (!object)
            [FIUAppDelegate getNotificationWithColor:AJNotificationTypeRed Animation:AJLinedBackgroundTypeAnimated WithMessage:error.localizedDescription inView:self.view];
        else{
            // Go to Next screen
            TriagePatientViewController* triagePatientViewController = [self getViewControllerFromiPadStoryboardWithName:@"triagePatientViewController"];
            [triagePatientViewController view];
            
            [triagePatientViewController setPatientData:[NSMutableDictionary dictionaryWithDictionary:object]];
            
            [triagePatientViewController populateInformation];
            
            [triagePatientViewController setDelegate:self];
            
            [triagePatientViewController.navigationItem setHidesBackButton:YES];
            
            [self.navigationController pushViewController:triagePatientViewController animated:YES];
        }
        
        [self HideALLHUDDisplayInView:self.view];
    }];
    

}

-(void)cancel{
    [self.navigationController popToViewController:self animated:YES];
    [self resetData];
}

- (IBAction)getAgeOfPatient:(id)sender {
    // get datepicker view
    DateController *datepicker = [self getViewControllerFromiPadStoryboardWithName:@"datePicker"];
    
    pop = [[UIPopoverController alloc]initWithContentViewController:datepicker];
    
    // Set Date if it is available
    if ([patientData objectForKey:DOB]) {
        NSNumber* dateInSeconds = [patientData objectForKey:DOB];
        [datepicker.datePicker setDate:[NSDate convertSecondsToNSDate:dateInSeconds]];
    }
    
    // set how the screen should return
    // set the age to the date the screen returns
    [datepicker setScreenHandler:^(id object, NSError *error) {
        // This method will return the age
        if (object) {
            NSDate* date = object;
            age = date.convertNSDateToSeconds;
            
            [_patientAgeField setTitle:[NSString stringWithFormat:@"%i Years Old", [date getNumberOfYearsElapseFromDate]] forState:UIControlStateNormal];
        }
        [pop dismissPopoverAnimated:YES];
    }];
    
    // show the screen beside the button
    [pop presentPopoverFromRect:_patientAgeField.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

// Checks the registration form for empty fields, or incorrect data (text in number field)
- (BOOL)validateRegistration {
    BOOL inputIsValid = YES;
    NSString *errorMsg;
    
    // Check for missing input
    // Not checking to see if the name, family, or village strings contain numbers,
    // This can always be revised, but some names apparently have "!" to symbolize a click (now you learned something new!)
    if([_patientNameField.text isEqualToString:@""] || _patientNameField.text == nil) {
        errorMsg = @"Missing Name";
        inputIsValid = NO;
    }else if([_familyNameField.text isEqualToString:@""] || _familyNameField.text == nil) {
        errorMsg = @"Missing Family Name";
        inputIsValid = NO;
    } else if([_villageNameField.text isEqualToString:@""] || _villageNameField.text == nil){
        errorMsg = @"Missing Village Name";
        inputIsValid = NO;
    }
    
    //display error message on invlaid input
    if(inputIsValid == NO){
        UIAlertView *validateRegistrationAlert = [[UIAlertView alloc] initWithTitle:nil message:errorMsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [validateRegistrationAlert show];
    }
    
    return inputIsValid;
}

- (void)resetData {
    user = nil;
    manageFingersController = nil;
    navControllerManageFingers = nil;

    /* Create a user object. Note that user id may not be 0! */
    user = [[PBBiometryUser alloc] initWithUserId:[[NSDate date] timeIntervalSince1970]];
    
    /* Create the view controller used to manage fingers for a single user. Handles enrollment
     * and prevents other users from re-enrolling. */
    manageFingersController = [[PBManageFingersController alloc] initWithDatabase:[FingerprintObject sharedClass] andUser:user];
    navControllerManageFingers = [[UINavigationController alloc] initWithRootViewController:manageFingersController];
    
    _patientNameField.text = @"";
    _familyNameField.text = @"";
    _villageNameField.text = @"";
    [_patientAgeField setTitle:@"Tap to set Age" forState:UIControlStateNormal];
    [_patientAgeField.titleLabel sizeToFit];
    [_patientPhoto setImage:[UIImage imageNamed:@"userImage.jpeg"]];
    [_patientSexSegment setSelectedSegmentIndex:0];
    [patientData removeAllObjects];
    patientSearchResultsArray = nil;
    [_searchResultTableView reloadData];
    [_firstNameField setText:@""];
    [_lastNameField setText:@""];
    [_createPatientButton setTitle:CREATE_PATIENT_TEXT forState:UIControlStateNormal];
}

// Hides keyboard when whitespace is pressed
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (IBAction)registerFingerprintsButton:(id)sender {
    [_patientNameField resignFirstResponder];
    [_familyNameField resignFirstResponder];
    [_villageNameField resignFirstResponder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveFingerprintNotification:) name:@"fingerprintRegistered" object:nil];
    
    user = [[PBBiometryUser alloc] initWithUserId:[[NSDate date] timeIntervalSince1970]];

    if (!fingerPrintDatabase) {
        /* Create the view controller used to manage fingers for a single user. Handles enrollment
         * and prevents other users from re-enrolling. */
        fingerPrintDatabase = [FingerprintObject sharedClass];
        
        manageFingersController = [[PBManageFingersController alloc] initWithDatabase:fingerPrintDatabase andUser:user];
    }
 
    navControllerManageFingers = [[UINavigationController alloc] initWithRootViewController:manageFingersController];
    
    
    pop = [[UIPopoverController alloc] initWithContentViewController:navControllerManageFingers];
    
    [pop presentPopoverFromRect:_registerFingerprintsButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)receiveFingerprintNotification:(NSNotification *) notification {
   
    NSDictionary* object = notification.object;
   
    for (NSString* key in [object allKeys]) {
        [patientData setValue:[object objectForKey:key] forKey:key];
    }

   [[NSNotificationCenter defaultCenter] removeObserver:self name:@"fingerprintRegistered" object:[[NSMutableDictionary alloc] init]];
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

// Defines number of sections in the table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Defines number of row in the table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return patientSearchResultsArray.count;
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
    
    NSDictionary* base = [[NSDictionary alloc]initWithDictionary:[patientSearchResultsArray objectAtIndex:indexPath.row]];
    
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
  
    NSDictionary* patient = [NSMutableDictionary dictionaryWithDictionary:[patientSearchResultsArray objectAtIndex:indexPath.row]];
   
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
        [ColorMe addBorder:cell.layer withWidth:1 withColor:[UIColor clearColor]];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // Sets color of cell when selected
    //[[[tableView cellForRowAtIndexPath:indexPath]contentView]setBackgroundColor:[UIColor grayColor]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // TODO: MAKE SURE THAT THIS OBJECT IS NOT IN USE AND THAT YOU LOCK IT WHEN YOU USE IT.
    
    patientData = [NSMutableDictionary dictionaryWithDictionary:[patientSearchResultsArray objectAtIndex:indexPath.row]];
    
    [self Redisplay];
    
    [_createPatientButton setTitle:@"Update Patient" forState:UIControlStateNormal];
}

- (IBAction)searchByNameButton:(id)sender {

    [self broadSearchForPatient];

}

- (IBAction)startOver:(id)sender {
    [self resetData];
}

- (void)broadSearchForPatient {
    
    
    //this will remove spaces BEFORE AND AFTER the string. I am leaving spaces in the middle because we might have names that are 2+ words
    //this also updates the fields with the new format so the user knows that its being trimmed
    //also, keep in mind that adding several spaces after text adds a period
    
    _firstNameField.text = [_firstNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    _lastNameField.text = [_lastNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    MobileClinicFacade* mobileFacade = [[MobileClinicFacade alloc]init];
    
    if (_firstNameField.text.isNotEmpty || _lastNameField.text.isNotEmpty) {
        /** This will should HUD in tableview to show alert the user that the system is working */
        [self showIndeterminateHUDInView:_searchResultTableView withText:@"Searching" shouldHide:NO afterDelay:0 andShouldDim:NO];
        
        [mobileFacade findPatientWithFirstName:_firstNameField.text orLastName:_familyNameField.text onCompletion:^(NSArray *allObjectsFromSearch, NSError *error) {
            if (allObjectsFromSearch) {
                // Get all the result from the query
                patientSearchResultsArray  = [NSArray arrayWithArray:allObjectsFromSearch];
                
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
    
[_lastNameField resignFirstResponder];
[_firstNameField resignFirstResponder];
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
            patientSearchResultsArray = [NSArray arrayWithArray:allObjectsFromSearch];
            
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
        patientSearchResultsArray = [NSArray arrayWithObject:[FingerprintObject findPatientFromArrayOfPatients:patientSearchResultsArray withFinger:finger]];
        [self dismissViewControllerAnimated:YES completion:^{
            [_searchResultTableView reloadData];
        }];
    }else{
        /* Match failed, verification rejected. */
    }
}

@end
