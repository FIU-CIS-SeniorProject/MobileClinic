//
//  DoctorPatientViewController.m
//  Mobile Clinic
//
//  Created by sebastian a zanlongo on 2/18/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import "DoctorPatientViewController.h"
#import "CurrentDiagnosisViewController.h"
#import "EditVisit.h"
@interface DoctorPatientViewController ()<CancelDelegate,EditVisitDelegate,UIPopoverControllerDelegate>{

    CurrentDiagnosisViewController* newView;
    EditVisit* editCurrentVisitView;
    UIBarButtonItem* edit;
    UIPopoverController* pop;
}

@end

@implementation DoctorPatientViewController

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

    edit =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editPatientAndVisitInfo)];
    [self.navigationItem setRightBarButtonItem:edit];
    // allows this class to set itself as the delegate for the first view in the container
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setDelegateMethod:) name:SET_DELEGATE object:newView];
    // toggles the edit button when going into medication search
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(toggleEditButton:) name:DISABLE_EDIT object:[[NSNumber alloc]init]];
   [ColorMe addGradientToLayer:self.view.layer colorOne:[ColorMe lightGray] andColorTwo:[ColorMe whitishColor]inFrame:self.view.bounds];
}

-(void)updatedVisit:(NSMutableDictionary *)updatedVisit{
    [_patientData setDictionary:updatedVisit];
    [pop dismissPopoverAnimated:YES];
    [self displayPatientData];
    [newView setPatientData:_patientData];
    [newView populateView];
    
}
-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    [edit setEnabled:YES];
}
-(BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController{
    return NO;
}
-(void)editPatientAndVisitInfo{
    if (!editCurrentVisitView) {
        editCurrentVisitView = [self getViewControllerFromiPadStoryboardWithName:@"EditVisit"];
        [editCurrentVisitView view];
        
    }
    pop = [[UIPopoverController alloc]initWithContentViewController:editCurrentVisitView];
    
    [pop setDelegate:self];
    
    [editCurrentVisitView setDelegate:self];
    
    [editCurrentVisitView setVisitData:_patientData];
    
    [pop presentPopoverFromBarButtonItem:edit permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}
-(void)setDelegateMethod:(NSNotification*)notif{
    newView = notif.object;
    [newView setDelegate:self];
    [newView setPatientData:_patientData];
}
- (void)viewWillAppear:(BOOL)animated {
    //set notifications that will be called when the keyboard is going to be displayed
    [super viewWillAppear:animated];
    
    // Display patient data
    [self displayPatientData];
  
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //remove the notifications that open the keyboard
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

// Display patient info & vitals
- (void)displayPatientData {
    // Extract patient name/village/etc from visit dictionary
    NSDictionary * patientDic = [_patientData objectForKey:OPEN_VISITS_PATIENT];

    // Populate patient info
    id data = [patientDic objectForKey:PICTURE];
    
    UIImage* img = ([data isKindOfClass:[NSData class]])?[UIImage imageWithData:data]:[UIImage imageNamed:@"userImage.jpeg"];
    [_patientPhoto setImage:img];
    
    [ColorMe addRoundedBlackBorderWithShadowInRect:_patientPhoto.layer];
    
    _patientNameField.text = [patientDic objectForKey:FIRSTNAME];
    _familyNameField.text = [patientDic objectForKey:FAMILYNAME];
    _villageNameField.text = [patientDic objectForKey:VILLAGE];
    _patientAgeField.text = [NSString stringWithFormat:@"%i",[[NSDate convertSecondsToNSDate:[patientDic objectForKey:DOB]]getNumberOfYearsElapseFromDate]];
    _patientSexField.text = ([[patientDic objectForKey:SEX]integerValue]==0)?@"Female":@"Male";
    
    // Populate patient's vitals from triage
    _patientWeightLabel.text = [NSString stringWithFormat:@"%.1f %@",[[_patientData objectForKey:WEIGHT]doubleValue], @"kg"];
    _patientBPLabel.text = [NSString stringWithFormat:@"%@ %@",[_patientData objectForKey:BLOODPRESSURE], @"mmHg"];
    _patientHRLabel.text = [NSString stringWithFormat:@"%@ %@",[_patientData objectForKey:HEARTRATE], @"bpm"];
    _patientRespirationLabel.text = [NSString stringWithFormat:@"%@ %@",[_patientData objectForKey:RESPIRATION], @"bpm"];
    _patientTempLabel.text = [NSString stringWithFormat:@"%@ %@",[_patientData objectForKey:TEMPERATURE], @"°C"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setPatientNameField:nil];
    [self setFamilyNameField:nil];
    [self setVillageNameField:nil];
    [self setPatientAgeField:nil];
    [self setPatientSexField:nil];
    [self setPatientPhoto:nil];
    [self setPatientWeightLabel:nil];
    [self setPatientBPLabel:nil];
    [self setPatientHRLabel:nil];
    [self setPatientRespirationLabel:nil];
    [self setToolBar:nil];
    [self setPatientTempLabel:nil];
    [super viewDidUnload];
}

#pragma mark - TableView Methods
#pragma mark -

- (IBAction)segmentClicked:(id)sender {
    switch (_segmentedControl.selectedSegmentIndex) {
        case 0:
           
            break;
        case 1:
            
            break;
        default:
            break;
    }

}


// Hides keyboard when whitespace is pressed
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - Keyboard/View Movement
#pragma mark -
//the Y position of the cell will be at 216


//method to move the view up/down whenever the keyboard is shown/dismissed

-(void)toggleEditButton:(NSNotification*)notif{
    [edit setEnabled:[notif.object boolValue]];
}
-(void)cancel{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:SET_DELEGATE object:newView];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:DISABLE_EDIT object:[[NSNumber alloc]init]];
    
    [_delegate DoctorPatientViewUpdateAndClose];
}

@end
