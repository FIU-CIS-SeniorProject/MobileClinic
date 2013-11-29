//
//  CurrentVisitViewController.m
//  Mobile Clinic
//
//  Created by sebastian a zanlongo on 2/18/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import "CurrentVisitViewController.h"
#import "PreviousVisitsViewController.h"
#import "MobileClinicFacade.h"

@interface CurrentVisitViewController (){
    PreviousVisitsViewController* prevVisit;
}

@property CGPoint originalCenter;

@end

@implementation CurrentVisitViewController

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
    
    currentVisit = [[NSMutableDictionary alloc]initWithCapacity:10];
    
    [currentVisit setValue:[[NSDate date]convertNSDateToSeconds] forKey:TRIAGEIN];
    
    self.conditionsTextbox.delegate = self;
    
    [self.view setBackgroundColor: [UIColor clearColor]];
    
    [ColorMe addBorder:_conditionsTextbox.layer withWidth:2 withColor:[UIColor blackColor]];
    
    [_SendToDoctor setBackgroundColor:[ColorMe colorFor:PALEPURPLE]];
    
    [_sendToPharmacy setBackgroundColor:[ColorMe colorFor:DARKGREEN]];
        
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]postNotificationName:SET_DELEGATE object:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setPatientWeightField:nil];
    [self setSystolicField:nil];
    [self setDiastolicField:nil];
    [self setHeartField:nil];
    [self setRespirationField:nil];
    [self setConditionTitleField:nil];
    [self setConditionsTextbox:nil];
    [self setVisitPriority:nil];
    [super viewDidUnload];
}

// Creates a visit for the patient and checks them in
- (IBAction)checkInButton:(id)sender {
    [self setVisitData:NO isGoingToPharmacy:NO];
}

// Allows nurse to check-out a patient without going thru doctor/pharmacy
- (IBAction)quickCheckOutButton:(id)sender {
    [self setVisitData:YES isGoingToPharmacy:NO];
}
- (IBAction)sendToPharmacy:(id)sender {
    [self setVisitData:NO isGoingToPharmacy:YES];
}
- (IBAction)cancelNewVisit:(id)sender {
    [self showIndeterminateHUDInView:self.view withText:@"Unlocking..." shouldHide:NO afterDelay:0 andShouldDim:YES];
    
    MobileClinicFacade* mcf = [[MobileClinicFacade alloc]init];
   
    [mcf updateCurrentPatient:_patientData AndShouldLock:NO onCompletion:^(NSDictionary *object, NSError *error) {
        [_delegate cancel];
        [self HideALLHUDDisplayInView:self.view];
    }];
    
}



- (void)setVisitData:(BOOL)type isGoingToPharmacy:(BOOL)toPharmacy {
    
    
    
    if (self.validateCheckin) {
        MobileClinicFacade* mobileFacade = [[MobileClinicFacade alloc]init];
        
        [currentVisit setValue:[NSNumber numberWithInt:[_patientWeightField.text intValue]] forKey:WEIGHT];
        [currentVisit setValue:[NSString stringWithFormat: @"%@/%@", _systolicField.text, _diastolicField.text] forKey:BLOODPRESSURE];
        [currentVisit setValue:_heartField.text forKey:HEARTRATE];
        [currentVisit setValue:_respirationField.text forKey:RESPIRATION];
        [currentVisit setValue:_conditionTitleField.text forKey:CONDITIONTITLE];
        [currentVisit setValue:_tempField.text forKey:TEMPERATURE];
        [currentVisit setValue:[[NSDate date]convertNSDateToSeconds] forKey:TRIAGEOUT];
        [currentVisit setValue:mobileFacade.GetCurrentUsername forKey:NURSEID];
        [currentVisit setValue:[NSNumber numberWithInteger:_visitPriority.selectedSegmentIndex] forKey:PRIORITY];
        
        if (toPharmacy) {
            if (![self validationHelper:_conditionsTextbox.text]) {
                 [currentVisit setValue:_conditionsTextbox.text forKey:MEDICATIONNOTES];
                [currentVisit setValue:[[NSDate date]convertNSDateToSeconds] forKey:DOCTORIN];
                [currentVisit setValue:[[NSDate date]convertNSDateToSeconds] forKey:DOCTOROUT];
            }else{
                UIAlertView *validateCheckinAlert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"To send to the pharmacy, fill out the medical notes" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [validateCheckinAlert show];
                return;
            }
        }
        /** This will should HUD in tableview to show alert the user that the system is working */
        [self showIndeterminateHUDInView:self.view withText:@"Saving..." shouldHide:NO afterDelay:0 andShouldDim:NO];
        
        [mobileFacade addNewVisit:currentVisit ForCurrentPatient:_patientData shouldCheckOut:type onCompletion:^(NSDictionary *object, NSError *error) {
            if (!object) {
                [FIUAppDelegate getNotificationWithColor:AJNotificationTypeOrange Animation:AJLinedBackgroundTypeAnimated WithMessage:error.localizedDescription inView:self.view];
            }else{
                [_delegate cancel];
            }
            /** This will remove the HUD since the search is complete */
            [self HideALLHUDDisplayInView:self.view];
        }];
    }
}


#pragma mark - UITextField Delegate Methods

- (BOOL)validateCheckin {
    BOOL inputIsValid = YES;
    NSString *errorMsg;
    
    if (![self validationHelper:_patientWeightField.text]){
        errorMsg = @"Weight has Letters";
        inputIsValid = NO;
    } else if (![self validationHelper:_systolicField.text]){
        errorMsg = @"Blood Pressure has Letters";
        inputIsValid = NO;
    } else if (![self validationHelper:_diastolicField.text]){
        errorMsg = @"Blood Pressure has Letters";
        inputIsValid = NO;
    } else if (![self validationHelper:_heartField.text]) {
        errorMsg = @"Heart Rate has Letters";
        inputIsValid = NO;
    } else if (![self validationHelper:_respirationField.text]) {
        errorMsg = @"Respiration has Letters";
        inputIsValid = NO;
    }
    
    //display error message on invlaid input
    if(inputIsValid == NO){
        UIAlertView *validateCheckinAlert = [[UIAlertView alloc] initWithTitle:nil message:errorMsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [validateCheckinAlert show];
    }
    
    return inputIsValid;
}

- (BOOL) validationHelper:(NSString *)string {
    NSCharacterSet *numbers = [NSCharacterSet decimalDigitCharacterSet];
    return ([[string stringByTrimmingCharactersInSet:numbers] isEqualToString:@""] || [[string stringByTrimmingCharactersInSet:numbers] isEqualToString:@"."]);
}


-(void)showPreviousVisit{
    
    prevVisit = [self getViewControllerFromiPadStoryboardWithName:@"previousVisitsViewController"];
    [prevVisit.navigationItem setHidesBackButton:YES];
    
    [self.navigationController pushViewController:prevVisit animated:YES];
}
-(void)closePreviousVisit{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
