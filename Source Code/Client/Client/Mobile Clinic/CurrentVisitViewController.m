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
//  CurrentVisitViewController.m
//  Mobile Clinic
//
//  Created by sebastian a zanlongo on 2/18/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//
#import "CurrentVisitViewController.h"
#import "MobileClinicFacade.h"

@interface CurrentVisitViewController ()
@property CGPoint originalCenter;
@end

@implementation CurrentVisitViewController
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
    currentVisit = [[NSMutableDictionary alloc]initWithCapacity:10];
    [currentVisit setValue:[[NSDate date]convertNSDateToSeconds] forKey:TRIAGEIN];
    self.conditionsTextbox.delegate = self;
    
    //FOR TESTING ONLY.  PLEASE COMMENT OUT WHEN DONE.
    _patientWeightField.text = @"180";
    _systolicField.text = @"120";
    _diastolicField.text = @"80";
    _heartField.text = @"70";
    _respirationField.text = @"30";
    _tempField.text = @"100";
//    _conditionTitleField.text = @"";
    _conditionsTextbox.text = @"Patient has a problem that needs to be checked by the doctor.";
}

- (void)viewWillAppear:(BOOL)animated
{

}

// Assigns patientData from Notification
- (void)assignPatientData:(NSNotification *)note
{
    _patientData = note.object;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
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
- (IBAction)checkInButton:(id)sender
{
    [self setVisitData:NO];
}

// Allows nurse to check-out a patient without going thru doctor/pharmacy
- (IBAction)quickCheckOutButton:(id)sender
{
    [self setVisitData:YES];
}

- (void)setVisitData:(BOOL)type
{
    // This will should HUD in tableview to show alert the user that the system is working
    [self showIndeterminateHUDInView:self.view withText:@"Saving..." shouldHide:NO afterDelay:0 andShouldDim:NO];
    
    if (self.validateCheckin)
    {
        MobileClinicFacade* mobileFacade = [[MobileClinicFacade alloc]init];
        
        [currentVisit setValue:[NSNumber numberWithInt:[_patientWeightField.text intValue]] forKey:WEIGHT];
        [currentVisit setValue:[NSString stringWithFormat: @"%@/%@", _systolicField.text, _diastolicField.text] forKey:BLOODPRESSURE];
        [currentVisit setValue:_heartField.text forKey:HEARTRATE];
        [currentVisit setValue:_respirationField.text forKey:RESPIRATION];
        [currentVisit setValue:_conditionsTextbox.text forKey:CONDITION];
        [currentVisit setValue:_conditionTitleField.text forKey:CONDITIONTITLE];
        [currentVisit setValue:_tempField.text forKey:TEMPERATURE];
        [currentVisit setValue:[[NSDate date]convertNSDateToSeconds] forKey:TRIAGEOUT];
        [currentVisit setValue:mobileFacade.GetCurrentUsername forKey:NURSEID];
        [currentVisit setValue:[NSNumber numberWithInteger:_visitPriority.selectedSegmentIndex] forKey:PRIORITY];
        
        [mobileFacade addNewVisit:currentVisit ForCurrentPatient:_patientData shouldCheckOut:type onCompletion:^(NSDictionary *object, NSError *error)
        {
            if (!object)
            {
                [FIUAppDelegate getNotificationWithColor:AJNotificationTypeOrange Animation:AJLinedBackgroundTypeAnimated WithMessage:error.localizedDescription inView:self.view];
            }
            else
            {
                handler(object,error);
            }
            
            // This will remove the HUD since the search is complete
            [self HideALLHUDDisplayInView:self.view];
        }];
    }
}

// Hides keyboard when whitespace is pressed
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - UITextField Delegate Methods
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView == self.conditionsTextbox)
    {
        [UIView animateWithDuration:0.3 animations:
         ^{
            self.view.center = CGPointMake(self.view.center.x + 130, self.view.center.y);
            
            // Move Weight objects
            CGRect weightFrame = self.patientWeightField.frame;
            weightFrame.origin.y += 46;
            weightFrame.origin.x -= 64;
            self.patientWeightField.frame = weightFrame;
            
            CGRect weightLabelFrame = self.patientWeightLabel.frame;
            weightLabelFrame.origin.y += 46;
            weightLabelFrame.origin.x -= 64;
            self.patientWeightLabel.frame = weightLabelFrame;
            
            CGRect weightLabelMeasurement = self.patientWeightMeasurementLabel.frame;
            weightLabelMeasurement.origin.y += 46;
            weightLabelMeasurement.origin.x -= 64;
            self.patientWeightMeasurementLabel.frame = weightLabelMeasurement;
            
            
            // Move Heart Rate objects
            CGRect heartFrame = self.heartField.frame;
            heartFrame.origin.y += 46;
            heartFrame.origin.x -= 95;
            self.heartField.frame = heartFrame;
            
            CGRect heartLabelFrame = self.heartFieldLabel.frame;
            heartLabelFrame.origin.y += 46;
            heartLabelFrame.origin.x -= 95;
            self.heartFieldLabel.frame = heartLabelFrame;
            
            CGRect heartMeasurementFrame = self.heartMeasurementLabel.frame;
            heartMeasurementFrame.origin.y += 46;
            heartMeasurementFrame.origin.x -= 95;
            self.heartMeasurementLabel.frame = heartMeasurementFrame;
            
            
            // Move Respiration objects
            CGRect respirationLabelFrame = self.respirationLabel.frame;
            respirationLabelFrame.origin.y += 46;
            respirationLabelFrame.origin.x -= 115;
            self.respirationLabel.frame = respirationLabelFrame;
            
            CGRect respirationMeasurementFrame = self.respirationMeasurementLabel.frame;
            respirationMeasurementFrame.origin.y += 46;
            respirationMeasurementFrame.origin.x -= 115;
            self.respirationMeasurementLabel.frame = respirationMeasurementFrame;
            
            CGRect respirationFrame = self.respirationField.frame;
            respirationFrame.origin.y += 46;
            respirationFrame.origin.x -= 115;
            self.respirationField.frame = respirationFrame;
            
            // Move Temperature objects
            CGRect tempFrame = self.tempField.frame;
            tempFrame.origin.y += 46;
            tempFrame.origin.x -= 127;
            self.tempField.frame = tempFrame;
            
            CGRect tempLabelFrame = self.tempLabel.frame;
            tempLabelFrame.origin.y += 46;
            tempLabelFrame.origin.x -= 127;
            self.tempLabel.frame = tempLabelFrame;
            
            CGRect tempLabelMeasurement = self.tempMeasurementLabel.frame;
            tempLabelMeasurement.origin.y += 46;
            tempLabelMeasurement.origin.x -= 127;
            self.tempMeasurementLabel.frame = tempLabelMeasurement;
            
            // Move BP objects
            CGRect bloodPressureFrame = self.bloodPressureLabel.frame;
            bloodPressureFrame.origin.y += 5;
            bloodPressureFrame.origin.x += 441;
            self.bloodPressureLabel.frame = bloodPressureFrame;
            
            CGRect bloodPressureDividerFrame = self.bloodPressureDivider.frame;
            bloodPressureDividerFrame.origin.y += 5;
            bloodPressureDividerFrame.origin.x += 441;
            self.bloodPressureDivider.frame = bloodPressureDividerFrame;
            
            CGRect bloodPressureMeasurementFrame = self.bloodPressureMeasurementLabel.frame;
            bloodPressureMeasurementFrame.origin.y += 5;
            bloodPressureMeasurementFrame.origin.x += 441;
            self.bloodPressureMeasurementLabel.frame = bloodPressureMeasurementFrame;
            
            CGRect systolicField = self.systolicField.frame;
            systolicField.origin.y += 5;
            systolicField.origin.x += 441;
            self.systolicField.frame = systolicField;
            
            CGRect diastolicField = self.diastolicField.frame;
            diastolicField.origin.y += 5;
            diastolicField.origin.x += 441;
            self.diastolicField.frame = diastolicField;
        }];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView == self.conditionsTextbox)
    {
        [UIView animateWithDuration:0.3 animations:
         ^{
            
            self.view.center = CGPointMake(self.view.center.x - 130, self.view.center.y);
            
            // Move Weight objects
            CGRect weightFrame = self.patientWeightField.frame;
            weightFrame.origin.y -= 46;
            weightFrame.origin.x += 64;
            self.patientWeightField.frame = weightFrame;
            
            CGRect weightLabelFrame = self.patientWeightLabel.frame;
            weightLabelFrame.origin.y -= 46;
            weightLabelFrame.origin.x += 64;
            self.patientWeightLabel.frame = weightLabelFrame;
            
            CGRect weightLabelMeasurement = self.patientWeightMeasurementLabel.frame;
            weightLabelMeasurement.origin.y -= 46;
            weightLabelMeasurement.origin.x += 64;
            self.patientWeightMeasurementLabel.frame = weightLabelMeasurement;
            
            
            // Move Heart Rate objects
            CGRect heartFrame = self.heartField.frame;
            heartFrame.origin.y -= 46;
            heartFrame.origin.x += 95;
            self.heartField.frame = heartFrame;
            
            CGRect heartLabelFrame = self.heartFieldLabel.frame;
            heartLabelFrame.origin.y -= 46;
            heartLabelFrame.origin.x += 95;
            self.heartFieldLabel.frame = heartLabelFrame;
            
            CGRect heartMeasurementFrame = self.heartMeasurementLabel.frame;
            heartMeasurementFrame.origin.y -= 46;
            heartMeasurementFrame.origin.x += 95;
            self.heartMeasurementLabel.frame = heartMeasurementFrame;
            
            
            // Move Respiration objects
            CGRect respirationLabelFrame = self.respirationLabel.frame;
            respirationLabelFrame.origin.y -= 46;
            respirationLabelFrame.origin.x += 115;
            self.respirationLabel.frame = respirationLabelFrame;
            
            CGRect respirationMeasurementFrame = self.respirationMeasurementLabel.frame;
            respirationMeasurementFrame.origin.y -= 46;
            respirationMeasurementFrame.origin.x += 115;
            self.respirationMeasurementLabel.frame = respirationMeasurementFrame;
            
            CGRect respirationFrame = self.respirationField.frame;
            respirationFrame.origin.y -= 46;
            respirationFrame.origin.x += 115;
            self.respirationField.frame = respirationFrame;
            
            
            // Move Temperature objects
            CGRect tempFrame = self.tempField.frame;
            tempFrame.origin.y -= 46;
            tempFrame.origin.x += 127;
            self.tempField.frame = tempFrame;
            
            CGRect tempLabelFrame = self.tempLabel.frame;
            tempLabelFrame.origin.y -= 46;
            tempLabelFrame.origin.x += 127;
            self.tempLabel.frame = tempLabelFrame;
            
            CGRect tempLabelMeasurement = self.tempMeasurementLabel.frame;
            tempLabelMeasurement.origin.y -= 46;
            tempLabelMeasurement.origin.x += 127;
            self.tempMeasurementLabel.frame = tempLabelMeasurement;
            
            
            // Move BP objects
            CGRect bloodPressureFrame = self.bloodPressureLabel.frame;
            bloodPressureFrame.origin.y -= 5;
            bloodPressureFrame.origin.x -= 441;
            self.bloodPressureLabel.frame = bloodPressureFrame;
            
            CGRect bloodPressureDividerFrame = self.bloodPressureDivider.frame;
            bloodPressureDividerFrame.origin.y -= 5;
            bloodPressureDividerFrame.origin.x -= 441;
            self.bloodPressureDivider.frame = bloodPressureDividerFrame;
            
            CGRect bloodPressureMeasurementFrame = self.bloodPressureMeasurementLabel.frame;
            bloodPressureMeasurementFrame.origin.y -= 5;
            bloodPressureMeasurementFrame.origin.x -= 441;
            self.bloodPressureMeasurementLabel.frame = bloodPressureMeasurementFrame;
            
            CGRect systolicField = self.systolicField.frame;
            systolicField.origin.y -= 5;
            systolicField.origin.x -= 441;
            self.systolicField.frame = systolicField;
            
            CGRect diastolicField = self.diastolicField.frame;
            diastolicField.origin.y -= 5;
            diastolicField.origin.x -= 441;
            self.diastolicField.frame = diastolicField;
        }];
    }
}

- (BOOL)validateCheckin
{
    BOOL inputIsValid = YES;
    NSString *errorMsg;
    
    if (![self validationHelper:_patientWeightField.text])
    {
        errorMsg = @"Weight has Letters";
        inputIsValid = NO;
    }
    else if (![self validationHelper:_systolicField.text])
    {
        errorMsg = @"Blood Pressure has Letters";
        inputIsValid = NO;
    }
    else if (![self validationHelper:_diastolicField.text])
    {
        errorMsg = @"Blood Pressure has Letters";
        inputIsValid = NO;
    }
    else if (![self validationHelper:_heartField.text])
    {
        errorMsg = @"Heart Rate has Letters";
        inputIsValid = NO;
    }
    else if (![self validationHelper:_respirationField.text])
    {
        errorMsg = @"Respiration has Letters";
        inputIsValid = NO;
    }
    
    //display error message on invlaid input
    if(inputIsValid == NO)
    {
        UIAlertView *validateCheckinAlert = [[UIAlertView alloc] initWithTitle:nil message:errorMsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [validateCheckinAlert show];
    }
    
    return inputIsValid;
}

- (BOOL) validationHelper:(NSString *)string
{
    NSCharacterSet *numbers = [NSCharacterSet decimalDigitCharacterSet];
    return ([[string stringByTrimmingCharactersInSet:numbers] isEqualToString:@""] || [[string stringByTrimmingCharactersInSet:numbers] isEqualToString:@"."]);
}

- (void)setScreenHandler:(ScreenHandler)myHandler
{
    handler = myHandler;
}
@end