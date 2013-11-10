//
//  CurrentDiagnosisViewController.m
//  Mobile Clinic
//
//  Created by sebastian a zanlongo on 2/22/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import "CurrentDiagnosisViewController.h"
#import "DoctorPrescriptionViewController.h"
#import "MobileClinicFacade.h"

@interface CurrentDiagnosisViewController ()<CancelDelegate>{
    DoctorPrescriptionViewController* newView;
}

@end

@implementation CurrentDiagnosisViewController

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
    UINavigationBar *navbar = [self.navigationController navigationBar];
    [navbar setTintColor:[ColorMe colorFor:PALEPURPLE]];
    
    _visitationData = [[VisitationObject alloc]init];
    
    
    [ColorMe addBorder:_objectiveTextbox.layer withWidth:1 withColor:[UIColor blackColor]];
    [ColorMe addBorder:_subjectiveTextbox.layer withWidth:1 withColor:[UIColor blackColor]];
    [ColorMe addBorder:_assessmentTextbox.layer withWidth:1 withColor:[UIColor blackColor]];

    [ColorMe addTopRoundedEdges:_subjectiveLabel.layer];
    [ColorMe addTopRoundedEdges:_objectiveLabel.layer];
    [ColorMe addTopRoundedEdges:_assessmentLabel.layer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:SET_DELEGATE object:self];

    [self.navigationController setTitle:@"Current Visit"];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self populateView];
}
-(void)populateView{
    [_subjectiveTextbox setText:[_patientData objectForKey:CONDITIONTITLE]];
    [_assessmentTextbox setText:[_patientData objectForKey:ASSESSMENT]];
    [_objectiveTextbox setText: [_patientData objectForKey:OBSERVATION]];
    [[NSNotificationCenter defaultCenter]postNotificationName:SYNC_OBJECT object:_patientData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setSubjectiveTextbox:nil];
    [self setObjectiveTextbox:nil];
    [self setAssessmentTextbox:nil];
    [self setSubmitButton:nil];
    [self setView:nil];
    [super viewDidUnload];
}

- (IBAction)submitButton:(id)sender {
    // Save diagnosis
   
        [_patientData setObject:_objectiveTextbox.text forKey:OBSERVATION];
        [_patientData setObject:_assessmentTextbox.text forKey:ASSESSMENT];     
        [_patientData setObject:_subjectiveTextbox.text forKey:CONDITION];
       

        /** This will should HUD in tableview to show alert the user that the system is working */
        [self showIndeterminateHUDInView:self.view withText:@"Saving..." shouldHide:NO afterDelay:0 andShouldDim:NO];
        
        MobileClinicFacade *mobileFacade = [[MobileClinicFacade alloc]init];
        
        [mobileFacade updateVisitRecord:_patientData andShouldUnlock:NO andShouldCloseVisit:NO onCompletion:^(NSDictionary *object, NSError *error) {
            if(!object)
                [FIUAppDelegate getNotificationWithColor:AJNotificationTypeOrange Animation:AJLinedBackgroundTypeAnimated WithMessage:error.localizedDescription inView:self.view];
    
            else{
                [self gotoNextView];
            }
            /** This will remove the HUD since the search is complete */
            [self HideALLHUDDisplayInView:self.view];
        }];
 
}

- (IBAction)cancelDiagnosis:(id)sender {
    /** This will should HUD in tableview to show alert the user that the system is working */
    [self showIndeterminateHUDInView:self.view withText:@"Unlocking" shouldHide:NO afterDelay:0 andShouldDim:YES];
    MobileClinicFacade* mcf = [[MobileClinicFacade alloc]init];
    [mcf updateVisitRecord:_patientData andShouldUnlock:YES andShouldCloseVisit:NO onCompletion:^(NSDictionary *object, NSError *error) {
        [self cancel];
        /** This will remove the HUD since the search is complete */
        [self HideALLHUDDisplayInView:self.view];
    }];

}
-(void)gotoNextView{
    newView = [self getViewControllerFromiPadStoryboardWithName:@"prescriptionFormViewController"];
   
    [newView view];
    
    [newView setDelegate:self];
    
    [newView setPatientData:_patientData];
    
    [self.navigationController pushViewController:newView animated:YES];
}
- (BOOL)validateFields {
    BOOL inputIsValid = YES;
    NSString *errorMsg;
    
    // Check for missing input
    // Not checking to see if the name, family, or village strings contain numbers,
    // This can always be revised, but some names apparently have "!" to symbolize a click (now you learned something new!)
    if([_objectiveTextbox.text isEqualToString:@""] || _objectiveTextbox.text == nil) {
        errorMsg = @"Missing Objective";
        inputIsValid = NO;
    }else if([_assessmentTextbox.text isEqualToString:@""] || _assessmentTextbox.text == nil) {
        errorMsg = @"Missing Doctor's Assessment";
        inputIsValid = NO;
    }
    
    // Display error message on invalid input
    if(inputIsValid == NO){
        UIAlertView *validateDiagnosisAlert = [[UIAlertView alloc] initWithTitle:nil message:errorMsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [validateDiagnosisAlert show];
    }
    
    return inputIsValid;
}

// Hides keyboard when whitespace is pressed
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


-(void)cancel{
    [_delegate cancel];
}

@end
