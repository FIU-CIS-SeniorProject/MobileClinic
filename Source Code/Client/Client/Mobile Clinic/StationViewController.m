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
//  StationViewController.m
//  Mobile Clinic
//
//  Created by sebastian a zanlongo on 2/18/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//
#import "PatientObject.h"
#import "StationViewController.h"
#import "StationViewHandlerProtocol.h"
#import "GenericStartViewController.h"
#import "PatientQueueViewController.h"

@interface StationViewController ()

@end

@implementation StationViewController

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
}

- (void)viewWillAppear:(BOOL)animated
{
    UINavigationBar *bar =[self.navigationController navigationBar];
    [bar setTintColor:[UIColor lightGrayColor]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logout:(id)sender
{
    [[NSNotificationCenter defaultCenter]postNotificationName:LOGOFF object:nil];
}

- (IBAction)triageButton:(id)sender
{
    [self goToGenericStart:1];
}

- (IBAction)doctorButton:(id)sender
{
    [self goToPatientQueue:2];
}

- (IBAction)pharmacyButton:(id)sender
{
    [self goToPatientQueue:3];
}

- (void)goToGenericStart:(int)station
{
    GenericStartViewController * newView = [self getViewControllerFromiPadStoryboardWithName:@"genericStartViewController"];
    [newView setStationChosen:[NSNumber numberWithInt:station]];
    [self.navigationController pushViewController:newView animated:YES];
}

- (void)goToPatientQueue:(int)station
{
    PatientQueueViewController * newView = [self getViewControllerFromiPadStoryboardWithName:@"patientQueueViewController"];
    [newView setStationChosen:[NSNumber numberWithInt:station]];
    [self.navigationController pushViewController:newView animated:YES];
}
@end