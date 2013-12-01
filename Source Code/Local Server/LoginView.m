//
//  LoginView.m
//  Mobile Clinic
//
//  Created by kevin a diaz on 11/17/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import "LoginView.h"
#import "PatientTable.h"
//#import "ServerCore.h"
@interface LoginView ()

@end

//id<ServerProtocol> connection;
@implementation LoginView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    
    return self;
}

- (IBAction)login:(id)sender {
    //connection = [ServerCore sharedInstance];
    //[connection start];
    NSLog(@"Button Pressed"); // Testing
    //self.view.hidden = YES;
    [self.view removeFromSuperview]; //
}

@end
