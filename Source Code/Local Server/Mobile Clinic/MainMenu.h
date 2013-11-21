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
//  MainMenu.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 3/24/13.
//
#import <Cocoa/Cocoa.h>
#import "LoginView.h"

@interface MainMenu : NSViewController<NSWindowDelegate>

@property (weak) IBOutlet NSTableView *serverTable;
@property (weak) IBOutlet NSTextField *connectionLabel;
@property (weak) IBOutlet NSView *mainScreen;
@property (weak) IBOutlet NSTextField *activityLabel;
@property (weak) IBOutlet NSLevelIndicator *statusIndicator;
@property (weak) IBOutlet NSTextField *statusLabel;
- (IBAction)startOptimization:(id)sender;
- (IBAction)quitApplication:(id)sender;
- (IBAction)showLoginView:(id)sender;
- (IBAction)showMedicationView:(id)sender;
- (IBAction)showPatientView:(id)sender;
- (IBAction)purgeTheSystem:(id)sender;
- (IBAction)truePurgeTheSystem:(id)sender;
- (IBAction)manualTableRefresh:(id)sender;
- (IBAction)showUserView:(id)sender;
- (IBAction)emergencyDataDump:(id)sender;
@end