//
//  MedicationList.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 3/16/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MedicationObject.h"
@interface MedicationList : NSViewController <NSTableViewDataSource,NSTableViewDelegate>

@property (weak) IBOutlet NSTableView *tableView;
- (IBAction)destructiveResync:(id)sender;
- (IBAction)setupView:(id)sender;
@end
