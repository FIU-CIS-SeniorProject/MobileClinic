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
    [self.dispensedButton setBackgroundImage:[UIImage imageNamed:@"unchecked.png"] forState:UIControlStateNormal];
    [self.dispensedButton setBackgroundImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateHighlighted];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)medicationDispensed:(id)sender {
    [self.dispensedButton setHighlighted:self.dispensedButton.highlighted];
    self.medicationDispensedLabel.text = self.dispensedButton.highlighted ? @"Medication Dispensed" : @"Medication NOT Dispensed";
}

@end
