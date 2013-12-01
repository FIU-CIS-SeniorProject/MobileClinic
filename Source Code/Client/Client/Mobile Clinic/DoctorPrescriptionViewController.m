//
//  PharamcyPrescriptionViewController.m
//  Mobile Clinic
//
//  Created by Steven Berlanga on 2/24/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import "DoctorPrescriptionViewController.h"
#import "MobileClinicFacade.h"
#import "PharmacyPatientViewControllerCell.h"
#import "MedicineSearchViewController.h"
@interface DoctorPrescriptionViewController ()<MCSwipeTableViewCellDelegate,MedicineSearchViewProtocol,UINavigationControllerDelegate>{
    NSMutableArray* prescriptions;
    MedicineSearchViewController* newView;
}

@property (nonatomic) int timeOfDay;
@end

@implementation DoctorPrescriptionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [_instructionLabel setBackgroundColor:[ColorMe colorFor:PALEPURPLE]];
    [ColorMe addBorder:_medicationNotes.layer withWidth:2 withColor:[UIColor blackColor]];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(syncronizeObject:) name:SYNC_OBJECT object:_patientData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setDelegate:self];
    [_drugTableView setDelegate:self];
    [_drugTableView setDataSource:self];
    [_medicationNotes setText:[_patientData objectForKey:MEDICATIONNOTES]];
}
-(void)syncronizeObject:(NSNotification*)notif{
    NSMutableDictionary* sync = notif.object;
    if (!_patientData) {
        _patientData = [[NSMutableDictionary alloc]initWithDictionary:sync];
    }else{
        for (id key in sync.allKeys) {
        [_patientData setValue:[sync objectForKey:key] forKey:key];
        }
    }
}
- (void)viewDidUnload {
    [self setTabletsTextField:nil];
    [self setTimeOfDayTextFields:nil];
    [self setDrugTextField:nil];
    [self setTimeOfDayButtons:nil];
    [self setMedicationNotes:nil];
    [super viewDidUnload];
}

- (IBAction)newTimeOfDay:(id)sender {
   
    for(int i = 0; i < [_timeOfDayButtons count]; i++) {
        if([[_timeOfDayButtons objectAtIndex:i] isEqual:sender]) {
            [((UIButton *)sender) setAlpha:1];
            _timeOfDayTextFields.text = [self getTimeOfDay:((UIButton *)sender).tag];
            self.timeOfDay = ((UIButton *)sender).tag;
        }else
            [((UIButton *)[_timeOfDayButtons objectAtIndex:i]) setAlpha:0.35];
    }
}

- (NSString *)getTimeOfDay:(int)num {
    switch (num) {
        case 0:
            return @"Morning";
            break;
        case 1:
            return @"Mid-Afternoon";
            break;
        case 2:
            return @"Midday";
            break;
        case 3:
            return @"Evening";
            break;
        default:
            return @"";
            break;
    }
}

- (IBAction)findDrugs:(id)sender {
    if (!newView) {
        newView = [self getViewControllerFromiPadStoryboardWithName:@"MedicineSearchViewController"];
        [newView view];
    }
    
    [newView setDelegate:self];
    [newView resetView];
    [newView.navigationItem.leftBarButtonItem setTitle:@"Cancel"];
    
    [self.navigationController pushViewController:newView animated:YES];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:DISABLE_EDIT object:[NSNumber numberWithBool:NO]];

}

-(void)configureCell:(PharmacyPatientViewControllerCell*)cell forRow:(NSIndexPath*)indexPath{
    

    
    [cell populateFieldsWithData:[prescriptions objectAtIndex:indexPath.row]];
    
//    [cell.dosage setText:[NSString stringWithFormat:@"%i Days", [[data objectForKey:TABLEPERDAY] integerValue]]];
//    
//    [cell.drugName setText: [data objectForKey:MEDNAME]];
//    
//    [cell.timeOfDay setText:[NSString stringWithFormat:@"%@ ", [data objectForKey:TIMEOFDAY]]];
//    
//    [cell.instructions setText:[NSString stringWithFormat:@"%@", [data objectForKey:INSTRUCTIONS]]];
  
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * currentVisitCellIdentifier = @"Cell";
    
    PharmacyPatientViewControllerCell * cell = [tableView dequeueReusableCellWithIdentifier:currentVisitCellIdentifier];
    
    if (!cell) {
        cell = [[PharmacyPatientViewControllerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:currentVisitCellIdentifier];
    }
    
    [cell setDelegate:self];
    
    [cell setFirstStateIconName:nil
                     firstColor:nil
            secondStateIconName:@"check.png"
                    secondColor:[ColorMe colorFor:DARKGREEN]
                  thirdIconName:nil
                     thirdColor:nil
                 fourthIconName:@"cross.png"
                    fourthColor:[ColorMe colorFor:PALERED]];
    
    // Setting the type of the cell
    [cell setMode:MCSwipeTableViewCellModeSwitch];
    [cell.contentView setBackgroundColor:[UIColor whiteColor]];
    [self configureCell:cell forRow:indexPath];
    
    return cell;
}

- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didTriggerState:(MCSwipeTableViewCellState)state withMode:(MCSwipeTableViewCellMode)mode
{
    
    // If Switch mode
    if (mode == MCSwipeTableViewCellModeSwitch)
    {
        
        // Get the row for the cell selected
        NSIndexPath* index = [_drugTableView indexPathForCell:cell];
        NSMutableDictionary* data = [prescriptions objectAtIndex:index.row];
        switch (state) {
                // If the state is positive
            case MCSwipeTableViewCellState2:
            {
                // Save the prescription object (Should decrement the medication)
                [self savePrescriptionToServer:data atIndexPath:index];
            }
                break;
            case MCSwipeTableViewCellState4:
                [prescriptions removeObjectAtIndex:index.row];
                if (prescriptions.count == 0 ) {
                    [_checkOutBtn setHidden:NO];
                }
                [_drugTableView reloadData];
                break;
            default:
                /** This will remove the HUD since the search is complete */
                [self HideALLHUDDisplayInView:self.view];
                break;
        }
        
        [cell setBackgroundColor:[UIColor clearColor]];
    }
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (prescriptions.count == 0) {
        [_instructionLabel setText:@"Tap \"Checkout\" to dismiss the patient without prescribing medication"];
        [_checkOutBtn setHidden:NO];
    }else{
         [_instructionLabel setText:@"Slide medication to the right to save and send to pharmacy. OR Slide medication to the left to delete"];
        [_checkOutBtn setHidden:YES];
    }
    return prescriptions.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}



-(void)savePrescriptionToServer:(NSMutableDictionary*)prescription atIndexPath:(NSIndexPath*)path{
    
    
    [_patientData setValue:[NSDate date] forKey:DOCTOROUT];
    
    [_patientData setValue:_medicationNotes.text forKey:MEDICATIONNOTES];
    // You need to save the information on this screen. it will be too much work and complication to save it elsewhere
    MobileClinicFacade* mcf = [[MobileClinicFacade alloc]init];
    
    /** This will should HUD in tableview to show alert the user that the system is working */
    [self showIndeterminateHUDInView:self.view withText:@"Saving..." shouldHide:NO afterDelay:0 andShouldDim:NO];
    
    [mcf addNewPrescription:prescription ForCurrentVisit:_patientData AndlockVisit:NO onCompletion:^(NSDictionary *object, NSError *error) {
        if (!object)
            [FIUAppDelegate getNotificationWithColor:AJNotificationTypeOrange Animation:AJLinedBackgroundTypeAnimated WithMessage:error.localizedDescription inView:self.view];
        else{
            [prescriptions removeObjectAtIndex:path.row];
            [_drugTableView reloadData];
            [self savePrescription:nil];
        }
            
        /** This will remove the HUD since the search is complete */
        [self HideALLHUDDisplayInView:self.view];
    }];
}

// Change name of button (Send to Pharmacy / Checkout)
- (IBAction)savePrescription:(id)sender {
     // TODO: NEED TO VALIDATE THAT FIELD ENTRY IS CORRECT (STRING or INTs)
        
    if (prescriptions.count == 0) {
        [_delegate cancel];
    }
}

- (IBAction)CheckOutPatient:(id)sender {
    if (prescriptions.count == 0) {
       
        [_patientData setValue:[NSDate date] forKey:DOCTOROUT];
        
        [_patientData setValue:_medicationNotes.text forKey:MEDICATIONNOTES];
        // You need to save the information on this screen. it will be too much work and complication to save it elsewhere
        MobileClinicFacade* mcf = [[MobileClinicFacade alloc]init];
        
        /** This will should HUD in tableview to show alert the user that the system is working */
        [self showIndeterminateHUDInView:self.view withText:@"Saving..." shouldHide:NO afterDelay:0 andShouldDim:NO];
        
        [mcf checkoutVisit:_patientData forPatient:[_patientData objectForKey:OPEN_VISITS_PATIENT] AndWillUlockOnCompletion:^(NSDictionary *object, NSError *error) {
           
            if (!object)
                [FIUAppDelegate getNotificationWithColor:AJNotificationTypeOrange Animation:AJLinedBackgroundTypeAnimated WithMessage:error.localizedDescription inView:self.view];
            else{
                [self savePrescription:nil];
            }

            /** This will remove the HUD since the search is complete */
            [self HideALLHUDDisplayInView:self.view];
        }];
    }else{
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"Please slide check out medication manually by sliding following instructions at the bottom of the screen" delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
        [alert show];
    }
}

// Hides keyboard when whitespace is pressed
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)deactivateControllerFields {
    [_medicationNotes setEditable:NO];
    [_tabletsTextField setEnabled:NO];
    [_timeOfDayTextFields setEnabled:NO];

}
-(void)addPrescription:(NSMutableDictionary *)prescription{
   
    if (!prescriptions) {
        prescriptions = [[NSMutableArray alloc]init];
    }
    
    [prescriptions addObject:prescription];
    
    [_drugTableView reloadData];
    
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (viewController == (UIViewController*)_delegate) {
         [[NSNotificationCenter defaultCenter]removeObserver:self name:SYNC_OBJECT object:_patientData];
    }else if (viewController == self){
        [[NSNotificationCenter defaultCenter]postNotificationName:DISABLE_EDIT object:[NSNumber numberWithBool:YES]];
    }
}

@end
