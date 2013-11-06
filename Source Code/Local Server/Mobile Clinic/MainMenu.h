//
//  MainMenu.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 3/24/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MainMenu : NSViewController<NSWindowDelegate>

@property (weak) IBOutlet NSTableView *serverTable;
@property (weak) IBOutlet NSTextField *connectionLabel;
@property (weak) IBOutlet NSView *mainScreen;
@property (weak) IBOutlet NSTextField *activityLabel;
@property (weak) IBOutlet NSLevelIndicator *statusIndicator;
@property (weak) IBOutlet NSTextField *statusLabel;
- (IBAction)startOptimization:(id)sender;
- (IBAction)quitApplication:(id)sender;
- (IBAction)showMedicationView:(id)sender;
- (IBAction)showPatientView:(id)sender;
- (IBAction)purgeTheSystem:(id)sender;
- (IBAction)manualTableRefresh:(id)sender;
- (IBAction)showUserView:(id)sender;

- (IBAction)emergencyDataDump:(id)sender;
@end
