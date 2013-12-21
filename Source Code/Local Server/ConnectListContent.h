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
//  ConnectListContent.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 1/28/13.
//
#import <Cocoa/Cocoa.h>
#import "FIUAppDelegate.h"
#import "UserObject.h"
@interface ConnectListContent : NSViewController
{
    FIUAppDelegate* appDelegate;
}
@property (nonatomic,strong)  UserObject *user;
@property (nonatomic,strong) IBOutlet NSTextView *info;
@property (nonatomic,strong) IBOutlet NSTextField *titleText;
@property (nonatomic,strong) IBOutlet NSTextField *username;
@property (nonatomic,strong)
IBOutlet NSTextField *Password;
@property (nonatomic,strong) IBOutlet NSTextField *email;
@property (nonatomic,strong) IBOutlet NSComboBox *userTypeBox;
@property (nonatomic,strong) IBOutlet NSSegmentedControl *isActiveSegment;

-(IBAction)AuthorizeUser:(id)sender;
-(IBAction)CommitNewUserInfo:(id)sender;
@end