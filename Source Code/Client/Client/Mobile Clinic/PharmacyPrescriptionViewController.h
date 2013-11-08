//
//  PharmacyPrescriptionViewController.h
//  Mobile Clinic
//
//  Created by Steven Berlanga on 3/18/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PharmacyPrescriptionViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *timeOfDayButton;
@property (weak, nonatomic) IBOutlet UILabel *drugNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeOfDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfPrescriptionLabel;
@property (weak, nonatomic) IBOutlet UITextView *doctorsNotesField;
- (IBAction)medicationDispensed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *dispensedButton;
@property (weak, nonatomic) IBOutlet UILabel *medicationDispensedLabel;

@end
