//
//  PharmacyPatientViewController.m
//  Mobile Clinic
//
//  Created by sebastian a zanlongo on 2/24/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import "MobileClinicFacade.h"
#import "PharmacyPatientViewController.h"
#import "PharmacyPatientViewControllerCell.h"

@interface PharmacyPatientViewController ()<MCSwipeTableViewCellDelegate>{
    NSMutableArray* timeOfDayArray;
    NSMutableArray* prescriptionQueue;
}

@end
/** OVERVIEW OF PHARMACYPATIENTVIEWCONTROLLER
 *  Based on the information passed by the previous screen, this view will populate the table with all the medication that the doctor prescribed and the corresponding medical notes.
 * If there is medication to dispense the user will have to fill out the medication and slide their finger to "check off" on the medication given. Once all the medication has been "Checked off" this view will automatically dismiss
 * If there are no prescriptions but a medical note (this can occur when the patient is sent from triage to pharmacist) then a checkout button will be visible.
 */
@implementation PharmacyPatientViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [_tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"tornMid.png"]]];
  
    [ColorMe addBorder:_tableView.layer withWidth:1 withColor:[UIColor blackColor]];
    
    [ColorMe addGradientToLayer:self.view.layer colorOne:[ColorMe lightGray] andColorTwo:[ColorMe whitishColor]inFrame:self.view.bounds];
    
    [ColorMe addRoundedBlackBorderWithShadowInRect:_patientPhoto.layer];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    // Get Patient Data from Visit
    NSDictionary * patientDic = [_patientData objectForKey:OPEN_VISITS_PATIENT];
    
    // Setup patient Picture
    id data = [[_patientData objectForKey:OPEN_VISITS_PATIENT]objectForKey:PICTURE];
    
    UIImage* img = ([data isKindOfClass:[NSData class]])?[UIImage imageWithData:data]:[UIImage imageNamed:@"userImage.jpeg"];
    
    [_patientPhoto setImage:img];
    
    _patientNameField.text = [patientDic objectForKey:FIRSTNAME];
    _familyNameField.text = [patientDic objectForKey:FAMILYNAME];
    _villageNameField.text = [patientDic objectForKey:VILLAGE];
    _patientAgeField.text = [NSString stringWithFormat:@"%i",[[NSDate convertSecondsToNSDate:[patientDic objectForKey:DOB]]getNumberOfYearsElapseFromDate]];
    _patientSexField.text = ([[patientDic objectForKey:SEX]integerValue]==0)?@"Female":@"Male";
    
    NSString* text = [_patientData objectForKey:MEDICATIONNOTES];
    [_medicalNotes setText:text];
    
    [ColorMe addBorder:_medicalNotes.layer withWidth:2 withColor:[UIColor blackColor]];
    
    [ColorMe ColorTint:_patientView.layer forCustomColor:[ColorMe colorFor:DARKGREEN]];
   
    [self showIndeterminateHUDInView:_tableView withText:@"Loading..." shouldHide:NO afterDelay:0 andShouldDim:YES];
    
    MobileClinicFacade *mobileFacade = [[MobileClinicFacade alloc]init];
    // Given a Visit, Find all medication
    [mobileFacade findAllPrescriptionForCurrentVisit:_patientData AndOnCompletion:^(NSArray *allObjectsFromSearch, NSError *error) {
        
        // Store Medication for the visit
        _prescriptions = [NSMutableArray arrayWithArray:allObjectsFromSearch];
        
        [_tableView reloadData];
       
        [self HideALLHUDDisplayInView:_tableView];
    }];

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
    [self setTableView:nil];
    [super viewDidUnload];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_prescriptions.count == 0) {
        [_checkoutButton setHidden:NO];
    }else{
        [_checkoutButton setHidden:YES];
    }
    return _prescriptions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString * currentVisitCellIdentifier = @"Cell";
    
    PharmacyPatientViewControllerCell * cell = [tableView dequeueReusableCellWithIdentifier:currentVisitCellIdentifier];
    
    if (!cell) {
        cell = [[PharmacyPatientViewControllerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:currentVisitCellIdentifier];
    }
    
    [cell setDelegate:self];
    
    [cell setFirstStateIconName:@"check.png"
                     firstColor:[UIColor colorWithRed:98.0/255.0 green:128.0/255.0 blue:86.0/255.0 alpha:.5]
            secondStateIconName:nil
                    secondColor:nil
                  thirdIconName:nil
                     thirdColor:nil
                 fourthIconName:nil
                    fourthColor:nil];
    
    // Setting the type of the cell
    [cell setMode:MCSwipeTableViewCellModeSwitch];
    
     [self configureCell:cell forRow:indexPath];
    
    return cell;
}

-(void)configureCell:(PharmacyPatientViewControllerCell*    )cell forRow:(NSIndexPath*)indexPath{
    
    // Let the cell fill its own information out
    [cell populateFieldsWithData:[self.prescriptions objectAtIndex:indexPath.row]];
 
}

- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didTriggerState:(MCSwipeTableViewCellState)state withMode:(MCSwipeTableViewCellMode)mode
{
    
    // If Switch mode
    if (mode == MCSwipeTableViewCellModeSwitch)
    {
        
        // Get the row for the cell selected
        NSIndexPath* index = [_tableView indexPathForCell:cell];

        switch (state) {
                // If the state is positive
            case MCSwipeTableViewCellState1:
            {
                // Save the prescription object (Should decrement the medication)
                [_prescriptions removeObjectAtIndex:index.row];
                [_tableView reloadData];
                [self checkoutPatient:nil];
                
            }
                break;
            default:
                /** This will remove the HUD since the search is complete */
                [self HideALLHUDDisplayInView:self.view];
                break;
        }
        
        [cell setBackgroundColor:[UIColor clearColor]];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [ColorMe addBorder:cell.layer withWidth:2 withColor:[UIColor blackColor]];
}

// Hides keyboard when whitespace is pressed
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (IBAction)checkoutPatient:(id)sender {
   
    if (_prescriptions.count == 0) {

    
    MobileClinicFacade* mcf = [[MobileClinicFacade alloc]init];
    
    
    /** This will should HUD in tableview to show alert the user that the system is working */
    [self showIndeterminateHUDInView:self.view withText:@"Saving..." shouldHide:NO afterDelay:0 andShouldDim:YES];
    
    
    
    [mcf checkoutVisit:_patientData forPatient:[_patientData objectForKey:OPEN_VISITS_PATIENT] AndWillUlockOnCompletion:^(NSDictionary *object, NSError *error) {
        
        /** This will remove the HUD since the search is complete */
        [self HideALLHUDDisplayInView:self.view];
        if (error.code > kErrorDisconnected) {
            [FIUAppDelegate getNotificationWithColor:AJNotificationTypeOrange Animation:AJLinedBackgroundTypeAnimated WithMessage:error.localizedDescription inView:self.view];
        }else{
            [_delegate PharmacyPatientViewUpdatedAndClose];
        }
    }];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (!prescriptionQueue) {
        prescriptionQueue = [[NSMutableArray alloc]initWithCapacity:_prescriptions.count];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
