//
//  LoginView.h
//  Mobile Clinic
//
//  Created by kevin a diaz on 11/17/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LoginView : NSViewController

@property (weak) IBOutlet NSTextField *Username;
@property (weak) IBOutlet NSTextField *Password;

- (IBAction)login:(id)sender;

@end