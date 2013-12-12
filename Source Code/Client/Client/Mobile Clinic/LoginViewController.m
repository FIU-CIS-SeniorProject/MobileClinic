//
//  LoginViewController.m
//  Mobile Clinic
//
//  Created by sebastian a zanlongo on 2/18/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//
#define TESTING @"Test"

#import "MBProgressHUD.h"
#import "LoginViewController.h"
#import "MedicationObject.h"
#import "PatientObject.h"
#import "ServerCore.h"
#import "SystemBackup.h"
#import "MobileClinicFacade.h"

@interface LoginViewController()
{
    MBProgressHUD* progress;
}

@property (nonatomic, retain) UIScrollView* scrollView;
@property (nonatomic, retain) NSMutableArray* slideImages;
@property (nonatomic, retain) NSTimer* timer;
@property (nonatomic, assign) CAGradientLayer *gradient;

@end

@implementation LoginViewController
@synthesize scrollView = _scrollView;
@synthesize slideImages = _slideImages;
@synthesize gradient = _gradient;
@synthesize usernameTextField, passwordTextField;

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
    
    [ColorMe addGradientToLayer:self.view.layer colorOne:[ColorMe lightGray] andColorTwo:[ColorMe whitishColor]inFrame:self.view.bounds];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   
    [self setupEnvironment];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupEnvironment
{
    // This will populate the databaes with values from the JSON files
    // Use this for testing only
    
    // Leave this while Device is in Testing mode
    NSUserDefaults* uDefault = [NSUserDefaults standardUserDefaults];
   
    if (![uDefault boolForKey:TESTING]) {
        [self setupUser:nil];
        [self createTestMedications:nil];
        //[self setupTestPatients:nil];
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:TESTING];
    }else{
       // [self setupUser:nil];
       // [self DeleteMedications:nil];
       // [self createTestMedications:nil];
        [usernameTextField setText:[uDefault objectForKey:CURRENT_USER]];
    }
    
}

/** Initiates Login */
- (IBAction)loginButton:(id)sender
{
    /** This will should HUD in tableview to show alert the user that the system is working */
    [self showIndeterminateHUDInView:self.view withText:@"Logging In" shouldHide:NO afterDelay:0 andShouldDim:YES];
   
    
    // Dismiss the keyboard
    [usernameTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
    
    // format username and login the user
    [self login:[[UserObject alloc]init] Password:passwordTextField.text Username:[[usernameTextField.text lowercaseString]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    
}

/** Private Method: Login the user and store the username for faster login */
-(void)login:(UserObject*)login Password:(NSString*)password Username:(NSString*)username{
    
    // Store Username for application user and login memory
    [[NSUserDefaults standardUserDefaults]setObject:username forKey:CURRENT_USER];
    
    // Save
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    // Attempt to login the user based on username and password
    [login loginWithUsername:username andPassword:password onCompletion:^(id<BaseObjectProtocol> data, NSError *error, Users *userA) {
        
        /** This will remove the HUD since the search is complete */
        [self HideALLHUDDisplayInView:self.view];
        
        if (error)
        {
            [FIUAppDelegate getNotificationWithColor:AJNotificationTypeRed Animation:AJLinedBackgroundTypeAnimated WithMessage:error.localizedDescription inView:self.view];
        }
        else
        {
            // Listens for the logout button
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(LogOffDevice) name:LOGOFF object:nil];
            
            // Listens for changing views
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(SwitchViews:) name:SWITCH_STATIONS object:nil];
   
            // Open the Appropriate View
            [self loadViewBasedOnUserType:userA.userType.integerValue];
            
        }
    }];
}

/** Private Helper Method: Called through notifications to switch views*/
-(void)SwitchViews:(NSNotification*)notification
{
    [self dismissViewControllerAnimated:YES completion:^
    {
        int view = [notification.object integerValue];
        [self loadViewBasedOnUserType:view];
    }];
}
/** Private Method: Closes the view, and clears all text fields and username memory */
- (void)LogOffDevice
{
    [self dismissViewControllerAnimated:YES completion:^
    {
        // Stops listening
        [passwordTextField setText:@""];
        
        [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:CURRENT_USER];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        [[NSNotificationCenter defaultCenter]removeObserver:self];
    }];
}

- (void) PerformSystemPurge
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purge System:" message:@"Enter credentials to confirm purge" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    alert.tag = 12;
    
    [alert addButtonWithTitle:@"Go"];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 12)
    {
        if (buttonIndex == 1)
        {
            UITextField* usernameField = [alertView textFieldAtIndex:0];
            UITextField* passwordField = [alertView textFieldAtIndex:1];
            
            NSString* username = usernameField.text;
            NSString* password = passwordField.text;
            
            [[[UserObject alloc] init] loginWithUsername:username andPassword:password onCompletion:^(id<BaseObjectProtocol> data, NSError *error, Users *userA)
            {
                if (error)
                {
                    [FIUAppDelegate getNotificationWithColor:AJNotificationTypeRed Animation:AJLinedBackgroundTypeAnimated WithMessage:error.localizedDescription inView:self.view];
                }
                else
                {
                    [[[MobileClinicFacade alloc] init] completeSystemPurge];
                    [self LogOffDevice];
                }
            }];
        }
    }
}

/** Private Method: Switches the view based on the usertype. */
-(void)loadViewBasedOnUserType:(UserTypes)type{
   
    UINavigationController * newView;
   
    switch (type)
    {
        case kTriageNurse:
        case kAdministrator:
            newView = [self getViewControllerFromiPadStoryboardWithName:@"triageController"];
            break;
        case kDoctor:
            newView = [self getViewControllerFromiPadStoryboardWithName:@"doctorQueueController"];
            break;
        case kPharmacists:
            newView = [self getViewControllerFromiPadStoryboardWithName:@"PharmacyQueueController"];
            break;
        case kPurgeSystem:
            [self PerformSystemPurge];
            break;
        default:
            break;
    }
    
    if (newView != nil)
    {
        [self presentViewController:newView animated:YES completion:^{ }];
    }
}

- (void)viewDidUnload
{
    [self setUsernameTextField:nil];
    [self setPasswordTextField:nil];
    [super viewDidUnload];
}

#pragma mark- Moving Tiles
#pragma mark-

- (IBAction)setupTestPatients:(id)sender
{
    // - DO NOT COMMENT: IF YOUR RESTART YOUR SERVER IT WILL PLACE DEMO PATIENTS INSIDE TO HELP ACCELERATE YOUR TESTING
    // - YOU CAN SEE WHAT PATIENTS ARE ADDED BY CHECKING THE PatientFile.json file
    NSError *err = nil;
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"PatientFile" ofType:@"json"];
    NSArray *patients = [NSArray arrayWithArray:[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath]options:0 error:&err]];
    
    NSLog(@"Imported Patients: %@", patients);
    
    [patients enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        PatientObject *base = [[PatientObject alloc]init];
        
        if([base setValueToDictionaryValues:obj]){
            [base saveObject:^(id<BaseObjectProtocol> data, NSError *error) {
            }];
        }
    }];
}

- (IBAction)setupUser:(id)sender
{
    NSError *err = nil;
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"User" ofType:@"json"];
    NSArray *users = [NSArray arrayWithArray:[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath]options:0 error:&err]];
    
    NSLog(@"Imported User: %@", users);
    
    [users enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
       
        UserObject *base = [[UserObject alloc]init];
        
        if([base setValueToDictionaryValues:obj]){
            [base saveObject:^(id<BaseObjectProtocol> data, NSError *error) {
            }];
        }
    }];
}

- (IBAction)createTestMedications:(id)sender
{
    NSError *err = nil;
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"MedicationFile" ofType:@"json"];
    NSArray *meds = [NSArray arrayWithArray:[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath]options:0 error:&err]];
    
    NSLog(@"Imported Medications: %@", meds.description);
    
    [meds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        MedicationObject *base = [[MedicationObject alloc]init];
        
        if([base setValueToDictionaryValues:obj])
        {
            [base saveObject:^(id<BaseObjectProtocol> data, NSError *error) {}];
        }
    }];
}

- (IBAction)DeleteMedications:(id)sender
{
    MedicationObject *base = [[MedicationObject alloc]init];
    NSArray* allMeds = [base FindAllObjectsLocallyFromParentObject:nil];
    [allMeds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        [base deleteDatabaseDictionaryObject:obj];
    }];
}
@end