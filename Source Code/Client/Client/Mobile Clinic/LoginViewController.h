//
//  LoginViewController.h
//  Mobile Clinic
//
//  Created by sebastian a zanlongo on 2/18/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserObject.h"
#import "GenericStartViewController.h"
#import "PatientQueueViewController.h"

@interface LoginViewController : UIViewController

- (IBAction)loginButton:(id)sender;
@property (strong, nonatomic) UserObject*user;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

- (IBAction)move:(id)sender;

@end
