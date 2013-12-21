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
//  LoginView.m
//  Mobile Clinic
//
//  Created by Kevin Diaz on 11/17/13.
//
#import "LoginView.h"
#import "UserObject.h"
#import "Users.h"

@interface LoginView ()

@end

@implementation LoginView
@synthesize usernameTextField, passwordTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    
    return self;
}

- (IBAction)login:(id)sender
{
    UserObject* users = [[UserObject alloc]init];
    
    // Sync appropriate users from cloud to the server
    [users pullFromCloud:^(id<BaseObjectProtocol> data, NSError *error)
     {
         if (error)
         {
             [NSApp presentError:error];
         }
     }];
    
    [users loginWithUsername:[usernameTextField stringValue] andPassword:[passwordTextField stringValue] onCompletion:^(id<BaseObjectProtocol> data, NSError *error, NSDictionary *userA)
    {
        //TODO: fix error
        if (error)
        {
            [[NSApplication sharedApplication] presentError:error];
        }
        else
        {
            //notification to mainMenu to change view
            [[NSNotificationCenter defaultCenter]postNotificationName:@"LOGIN_OBSERVER" object:[usernameTextField stringValue]];
        }
        //clear text fields
        [usernameTextField setStringValue:@""];
        [passwordTextField setStringValue:@""];
    }];
}
@end