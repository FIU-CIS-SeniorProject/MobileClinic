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
//  PharmacyPrescriptionViewController.m
//  Mobile Clinic
//
//  Created by Steven Berlanga on 3/18/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//
#import "PharmacyPrescriptionViewController.h"

@interface PharmacyPrescriptionViewController ()
@end

@implementation PharmacyPrescriptionViewController

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
    [self.dispensedButton setBackgroundImage:[UIImage imageNamed:@"unchecked.png"] forState:UIControlStateNormal];
    [self.dispensedButton setBackgroundImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateHighlighted];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)medicationDispensed:(id)sender
{
    [self.dispensedButton setHighlighted:self.dispensedButton.highlighted];
    self.medicationDispensedLabel.text = self.dispensedButton.highlighted ? @"Medication Dispensed" : @"Medication NOT Dispensed";
}
@end