//
//  ConnectListContent.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 1/28/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FIUAppDelegate.h"
#import "UserObject.h"
@interface ConnectListContent : NSViewController {
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
