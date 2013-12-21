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
//  FIUAppDelegate.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 1/23/13.
//  Modified by James Mendez on 12/2013
//
#define APPDELEGATE_STARTED @"slow appdelegate"
#import <Cocoa/Cocoa.h>
#import "ServerCore.h"
#import "CloudService.h"

typedef enum
{
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