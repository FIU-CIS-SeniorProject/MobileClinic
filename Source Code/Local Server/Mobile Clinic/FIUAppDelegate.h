// 
//  FIUAppDelegate.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 1/23/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//
#define APPDELEGATE_STARTED @"slow appdelegate"
#import <Cocoa/Cocoa.h>
#import "ServerCore.h"
#import "CloudService.h"

typedef enum {
    kFirstSync  = 120,
    kFastSync   = 1000,
    kStabilize  = 500,
    kFinalize   = 300,
}Optimizer;

@interface FIUAppDelegate : NSObject <NSTableViewDataSource,NSTableViewDelegate,NSApplicationDelegate>


@property (weak) IBOutlet NSMenuItem *createPatientMenu;
@property (weak) IBOutlet NSMenuItem *createMedicineMenu;
@property (weak) IBOutlet NSMenuItem *OptimizeToggler;

- (IBAction)showMainServerView:(id)sender;

@property (nonatomic, strong) ServerCore *server;
@property (assign) IBOutlet NSWindow *window;

- (IBAction)restartServer:(id)sender;
- (IBAction)shutdownServer:(id)sender;

- (IBAction)showMedicineView:(id)sender;

- (IBAction)setupTestPatients:(id)sender;
- (IBAction)TearDownEnvironment:(id)sender;

- (Optimizer)isOptimized;

- (IBAction)showPatientsView:(id)sender;
- (IBAction)showUserView:(id)sender;

@end
