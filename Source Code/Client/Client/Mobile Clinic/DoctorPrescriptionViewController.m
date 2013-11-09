//
//  PharamcyPrescriptionViewController.m
//  Mobile Clinic
//
//  Created by Steven Berlanga on 2/24/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import "DoctorPrescriptionViewController.h"
#import "MobileClinicFacade.h"
@interface DoctorPrescriptionViewController ()

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [[NSNotificationCenter defaultCenter] postNotificationName:MOVE_TO_SEARCH_FOR_MEDICINE object:nil];
}

// Change name of button (Send to Pharmacy / Checkout)
- (IBAction)savePrescription:(id)sender {
    if([self validatePrescription]) {
        
        // TODO: NEED TO VALIDATE THAT FIELD ENTRY IS CORRECT (STRING or INTs)
        
        // Create a timestamp for Prescribe Time
        NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
        [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        NSString *dateStamp = [DateFormatter stringFromDate:[NSDate date]];
        
        // Save prescription fields
        [_prescriptionData setObject:_medicationNotes.text forKey:INSTRUCTIONS];
        [_prescriptionData setObject:[NSNumber numberWithInteger:[_tabletsTextField.text integerValue]] forKey:TABLEPERDAY];
        [_prescriptionData setObject:[NSNumber numberWithInteger:self.timeOfDay] forKey:TIMEOFDAY];
        [_prescriptionData setObject:dateStamp forKey:PRESCRIBETIME];
        [_patientData setValue:[NSDate date] forKey:DOCTOROUT];
        
        // You need to save the information on this screen. it will be too much work and complication to save it elsewhere
        MobileClinicFacade* mcf = [[MobileClinicFacade alloc]init];
        
        /* The _patientData should not be contian patient data but Visit dictionary with the patient data inside Or just the visit data alone. This method will not work if there is no visitation data*/
        // TODO: Fix this  class so that is has the visit data

        [mcf addNewPrescription:_prescriptionData ForCurrentVisit:_patientData AndlockVisit:NO onCompletion:^(NSDictionary *object, NSError *error) {
            if (!object)
                [FIUAppDelegate getNotificationWithColor:AJNotificationTypeRed Animation:AJLinedBackgroundTypeAnimated WithMessage:error.localizedDescription inView:self.view];
            else
                [[NSNotificationCenter defaultCenter] postNotificationName:SAVE_PRESCRIPTION object:_prescriptionData];
        }];
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
    
    
    for(int i = 0; i <[_timeOfDayButtons count]; i++){
        [((UIButton *)[_timeOfDayButtons objectAtIndex:i]) setEnabled:NO];
    }
}

- (BOOL)validatePrescription {
    BOOL inputIsValid = YES;
    NSString *errorMsg;
    
    if([_drugTextField.text isEqualToString:@""] || _drugTextField.text == nil) {
        errorMsg = @"Missing medication";
        inputIsValid = NO;
    } else if([_tabletsTextField.text isEqualToString:@""] || _tabletsTextField.text == nil) {
        errorMsg = @"Missing number of tablets per day";
        inputIsValid = NO;
    } else if([_timeOfDayTextFields.text isEqualToString:@""] || _timeOfDayTextFields.text == nil) {
        errorMsg = @"Choose time of day";
        inputIsValid = NO;
    }
    
    // Display error message on invalid input
    if(inputIsValid == NO){
        UIAlertView *validateDiagnosisAlert = [[UIAlertView alloc] initWithTitle:nil message:errorMsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [validateDiagnosisAlert show];
    }
    
    return inputIsValid;
}

- (void)setScreenHandler:(ScreenHandler)myHandler {
    handler = myHandler;
}

@end
