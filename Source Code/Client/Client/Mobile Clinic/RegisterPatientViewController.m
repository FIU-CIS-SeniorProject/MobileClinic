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
//  RegisterPatientViewController.m
//  Mobile Clinic
//
//  Created by sebastian a zanlongo on 2/18/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//
#import "DateController.h"
#import "RegisterPatientViewController.h"
#import "PBManageFingersController.h"
#import "FingerprintObject.h"
#import "PBBiometry.h"

UIPopoverController * pop;

@interface RegisterPatientViewController()
{
    PBBiometryUser* user;
    PBManageFingersController* manageFingersController;
    UINavigationController* navControllerManageFingers;
    FingerprintObject* fingerPrintDatabase;
    NSNumber* age;
}

@end

@implementation RegisterPatientViewController

-(id)init
{
    self = [super init];
    if (self)
    {
        //initialize these fields
    }
    return self;
}

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
    
    //    NSDate *d = [NSDate date];
    //    NSLog(@"date: %@", d);
    //
    //    NSNumber *numDate = [d convertNSDateToSeconds];
    //    NSLog(@"dateSec: %@", numDate);
    //
    //    NSLog(@"date: %@", [NSDate convertSecondsToNSDate:numDate]);
    
    facade = [[CameraFacade alloc]initWithView:self];
    
    if (!_patient)
    {
        _patient = [[NSMutableDictionary alloc]initWithCapacity:10];
    }
    else
    {
        [self Redisplay];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Create a user object. Note that user id may not be 0!
    user = [[PBBiometryUser alloc] initWithUserId:[[NSDate date] timeIntervalSince1970]];
    
    // Create the view controller used to manage fingers for a single user. Handles enrollment
    // and prevents other users from re-enrolling.
    fingerPrintDatabase = [FingerprintObject sharedClass];
    
    manageFingersController = [[PBManageFingersController alloc] initWithDatabase:fingerPrintDatabase andUser:user];
    
    navControllerManageFingers = [[UINavigationController alloc] initWithRootViewController:manageFingersController];
    
    //TODO grey out button on load when tactivo is not plugged in
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)Redisplay
{
    [_patientNameField setText:[_patient objectForKey:FIRSTNAME]];
    [_patientPhoto setImage:[UIImage imageWithData:[_patient objectForKey:PICTURE]]];
    [_familyNameField setText:[_patient objectForKey:FAMILYNAME]];
    [_villageNameField setText:[_patient objectForKey:VILLAGE]];
    [_patientSexSegment setSelectedSegmentIndex:[[_patient objectForKey:SEX]integerValue]];
}

- (void)viewDidUnload
{
    [self setCreatePatientButton:nil];
    [super viewDidUnload];
}

// Set up the camera source and view controller
- (IBAction)patientPhotoButton:(id)sender
{
    // Added Indeterminate Loader
    MBProgressHUD *progress = [MBProgressHUD showHUDAddedTo:_patientPhoto.superview animated:YES];
    [progress setMode:MBProgressHUDModeIndeterminate];
    
    [facade TakePictureWithCompletion:^(id img)
    {
        if(img)
        {
            [_patientPhoto setImage:img];
            [_patient setValue:[img convertImageToPNGBinaryData] forKey:PICTURE];
        }
        [progress hide:YES];
    }];
}

- (IBAction)createPatient:(id)sender
{
    // Before doing anything else, check that all of the fields have been completed
    if (self.validateRegistration)
    {
        [self.patientNameField resignFirstResponder];
        [self.familyNameField resignFirstResponder];
        [self.villageNameField resignFirstResponder];
        
        // Age is set when the moment the user sets it through the Popover
        if (age == nil || [self.patientAgeField.titleLabel.text isEqualToString:@"Tap to set Age"])
        {
            [_patient setValue:0 forKey:DOB];
        }
        else
        {
            [_patient setValue:age forKey:DOB];
        }        
        
        [_patient setValue:_patientNameField.text forKey:FIRSTNAME];
        [_patient setValue:_familyNameField.text forKey:FAMILYNAME];
        [_patient setValue:_villageNameField.text forKey:VILLAGE];
        [_patient setValue:[NSNumber numberWithInt:_patientSexSegment.selectedSegmentIndex] forKey:SEX];
        
        // This will create a patient locally and on the server.
        // The patient created on the server will be locked automatically.
        // This is done because of the workflow of the system
        // To unlock the patient see the documentation for the PatientObject
        MobileClinicFacade* mobileFacade = [[MobileClinicFacade alloc]init];
        
        [mobileFacade createAndCheckInPatient:_patient onCompletion:^(NSDictionary *object, NSError *error)
        {
            if (!object)
            {
                [FIUAppDelegate getNotificationWithColor:AJNotificationTypeRed Animation:AJLinedBackgroundTypeAnimated WithMessage:error.localizedDescription];
            }
            else
            {
                handler(object,error);
                [self resetData];
            }
        }];
    }
}

- (IBAction)getAgeOfPatient:(id)sender
{
    // get datepicker view
    DateController *datepicker = [self getViewControllerFromiPadStoryboardWithName:@"datePicker"];
    
    pop = [[UIPopoverController alloc]initWithContentViewController:datepicker];
    
    // Set Date if it is available
    if ([_patient objectForKey:DOB])
    {
        [datepicker.datePicker setDate:[_patient objectForKey:DOB]];
    }
    
    // set how the screen should return
    // set the age to the date the screen returns
    [datepicker setScreenHandler:^(id object, NSError *error)
    {
        // This method will return the age
        if (object)
        {
            NSDate* date = object;
            age = date.convertNSDateToSeconds;
            
            [_patientAgeField setTitle:[NSString stringWithFormat:@"%i Years Old", [date getNumberOfYearsElapseFromDate]] forState:UIControlStateNormal];
        }
        [pop dismissPopoverAnimated:YES];
    }];
    
    // show the screen beside the button
    [pop presentPopoverFromRect:_patientAgeField.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)setScreenHandler:(ScreenHandler)myHandler
{
    handler = myHandler;
}

// Checks the registration form for empty fields, or incorrect data (text in number field)
- (BOOL)validateRegistration
{
    BOOL inputIsValid = YES;
    NSString *errorMsg;
    
    // Check for missing input
    // Not checking to see if the name, family, or village strings contain numbers,
    // This can always be revised, but some names apparently have "!" to symbolize a click (now you learned something new!)
    if([_patientNameField.text isEqualToString:@""] || _patientNameField.text == nil)
    {
        errorMsg = @"Missing Name";
        inputIsValid = NO;
    }
    else if([_familyNameField.text isEqualToString:@""] || _familyNameField.text == nil)
    {
        errorMsg = @"Missing Family Name";
        inputIsValid = NO;
    }
    else if([_villageNameField.text isEqualToString:@""] || _villageNameField.text == nil)
    {
        errorMsg = @"Missing Village Name";
        inputIsValid = NO;
    }
    
    //display error message on invlaid input
    if(inputIsValid == NO)
    {
        UIAlertView *validateRegistrationAlert = [[UIAlertView alloc] initWithTitle:nil message:errorMsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [validateRegistrationAlert show];
    }
    
    return inputIsValid;
}

- (void)resetData
{
    user = nil;
    manageFingersController = nil;
    navControllerManageFingers = nil;
    
    // Create a user object. Note that user id may not be 0!
    user = [[PBBiometryUser alloc] initWithUserId:[[NSDate date] timeIntervalSince1970]];
    
    // Create the view controller used to manage fingers for a single user. Handles enrollment
    // and prevents other users from re-enrolling.
    manageFingersController = [[PBManageFingersController alloc] initWithDatabase:[FingerprintObject sharedClass] andUser:user];
    navControllerManageFingers = [[UINavigationController alloc] initWithRootViewController:manageFingersController];
    
    _patientNameField.text = @"";
    _familyNameField.text = @"";
    _villageNameField.text = @"";
    [_patientAgeField setTitle:@"Tap to set Age" forState:UIControlStateNormal];
    [_patientAgeField.titleLabel sizeToFit];
    [_patientPhoto setImage:[UIImage imageNamed:@"userImage.jpeg"]];
    [_patientSexSegment setSelectedSegmentIndex:0];
    [_patient removeAllObjects];
}

// Hides keyboard when whitespace is pressed
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (IBAction)registerFingerprintsButton:(id)sender
{
    [_patientNameField resignFirstResponder];
    [_familyNameField resignFirstResponder];
    [_villageNameField resignFirstResponder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveFingerprintNotification:) name:@"fingerprintRegistered" object:nil];
    
    pop = [[UIPopoverController alloc] initWithContentViewController:navControllerManageFingers];
    
    [pop presentPopoverFromRect:_registerFingerprintsButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void) receiveFingerprintNotification:(NSNotification *) notification
{
    _patient = [NSMutableDictionary dictionaryWithDictionary:notification.object];
   [[NSNotificationCenter defaultCenter] removeObserver:self name:@"fingerprintRegistered" object:[[NSMutableDictionary alloc] init]];
}
@end