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
//  CurrentDiagnosisViewController.m
//  Mobile Clinic
//
//  Created by sebastian a zanlongo on 2/22/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import "CurrentDiagnosisViewController.h"

@interface CurrentDiagnosisViewController ()

@end

@implementation CurrentDiagnosisViewController

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
    _visitationData = [[VisitationObject alloc]init];
}

- (void)viewWillAppear:(BOOL)animated
{
    // Populate condition for doctor to see
    _subjectiveTextbox.text = [_patientData objectForKey:CONDITION];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setSubjectiveTextbox:nil];
    [self setObjectiveTextbox:nil];
    [self setAssessmentTextbox:nil];
    [self setSubmitButton:nil];
    [self setView:nil];
    [super viewDidUnload];
}

- (IBAction)submitButton:(id)sender
{
    // Save diagnosis
    if (self.validateFields)
    {
        [_patientData setObject:_objectiveTextbox.text forKey:OBSERVATION];
        [_patientData setObject:_assessmentTextbox.text forKey:ASSESSMENT];     // TODO: Need to add this to the database
        [[NSNotificationCenter defaultCenter] postNotificationName:SAVE_VISITATION object:_patientData];
    }
}

- (BOOL)validateFields
{
    BOOL inputIsValid = YES;
    NSString *errorMsg;
    
    // Check for missing input
    // Not checking to see if the name, family, or village strings contain numbers,
    // This can always be revised, but some names apparently have "!" to symbolize a click (now you learned something new!)
    if([_objectiveTextbox.text isEqualToString:@""] || _objectiveTextbox.text == nil)
    {
        errorMsg = @"Missing Objective";
        inputIsValid = NO;
    }
    else if([_assessmentTextbox.text isEqualToString:@""] || _assessmentTextbox.text == nil)
    {
        errorMsg = @"Missing Doctor's Assessment";
        inputIsValid = NO;
    }
    
    // Display error message on invalid input
    if(inputIsValid == NO)
    {
        UIAlertView *validateDiagnosisAlert = [[UIAlertView alloc] initWithTitle:nil message:errorMsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [validateDiagnosisAlert show];
    }
    
    return inputIsValid;
}

// Hides keyboard when whitespace is pressed
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)setScreenHandler:(ScreenHandler)myHandler
{
    handler = myHandler;
}
@end