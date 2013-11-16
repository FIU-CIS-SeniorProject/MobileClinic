//
//  Login View & Controller.h
//  Mobile Clinic
//
//  Created by kevin a diaz on 11/16/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@interface LoginView : NSViewController<NSTextFieldDelegate>


- (IBAction)login:(id)sender;

@end


/*
 //
 //  UserView.h
 //  Mobile Clinic
 //
 //  Created by Michael Montaque on 3/23/13.
 //  Copyright (c) 2013 Florida International University. All rights reserved.
 //
 
 #import <Cocoa/Cocoa.h>
 #import "UserObject.h"
 @interface UserView : NSViewController<NSTableViewDataSource,NSTableViewDelegate>
 
 @property (weak) IBOutlet NSTableView *tableView;
 @property (weak) IBOutlet NSTextField *usernameLabel;
 @property (weak) IBOutlet NSComboBox *primaryRolePicker;
 @property (weak) IBOutlet NSProgressIndicator *loadIndicator;
 @property (weak) IBOutlet NSComboBox *userStatus;
 @property (weak) IBOutlet NSButton *sTriage;
 @property (weak) IBOutlet NSButton *sDoctor;
 @property (weak) IBOutlet NSButton *sPharmacist;
 @property (weak) IBOutlet NSButton *sAdministrator;
 
 - (IBAction)refreshTable:(id)sender;
 - (IBAction)commitChanges:(id)sender;
 - (IBAction)cloudSync:(id)sender;
 
 @end



*/