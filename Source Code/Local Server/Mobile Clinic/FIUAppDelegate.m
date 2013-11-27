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
//  FIUAppDelegate.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 1/23/13.
//
#import "FIUAppDelegate.h"
#import "BaseObject.h"
#import "MainMenu.h"
#import "PatientTable.h"
#import "MedicationList.h"
#import "LoginView.h"
#import "UserView.h"
#import "Database.h"
#import "CloudManagementObject.h"

#define PTESTING @"Patients Testing"
#define MTESTING @"Medicine Testing"

ServerCore* connection;
UserView* userView;
MedicationList* medList;
PatientTable *pTable;
MainMenu* mainView;
NSTimer* switchTimer;
Optimizer isOptimized;
CloudManagementObject* cloudMO;

@implementation FIUAppDelegate

//@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
//@synthesize managedObjectModel = _managedObjectModel;
//@synthesize managedObjectContext = _managedObjectContext;

- (void)showPatientsView:(id)sender
{

}

- (IBAction)showUserView:(id)sender
{

}

- (void)showUsersView:(id)sender
{
    if(![_window isVisible])
    {
        [_window makeKeyAndOrderFront:sender];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    isOptimized = kFirstSync;
    [_OptimizeToggler setTitle:@"First Sync -> Fast Sync"];
    [CloudService cloud];
    [_window setHidesOnDeactivate:NO];
}

// Switching to the Test Environment
- (IBAction)setupTestPatients:(id)sender
{
    // - DO NOT COMMENT: IF YOUR RESTART YOUR SERVER IT WILL PLACE DEMO PATIENTS INSIDE TO HELP ACCELERATE YOUR TESTING
    // - YOU CAN SEE WHAT PATIENTS ARE ADDED BY CHECKING THE PatientFile.json file
    NSError* err = nil;
    
    NSLog(@"Performing a True Purge of the System");
    [mainView truePurgeTheSystem:nil];
    
    // Set CloudManagementObject
    [cloudMO setActiveEnvironment:@"test"];
    
    NSString* dataPath = [[NSBundle mainBundle] pathForResource:@"PatientFile" ofType:@"json"];
    
    NSArray* patients = [NSArray arrayWithArray:[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath]options:0 error:&err]];
    
    [patients enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:obj];
        PatientObject *base = [[PatientObject alloc]init];
        
        NSError* success = [base setValueToDictionaryValues:dic];

        [base saveObject:^(id<BaseObjectProtocol> data, NSError *error)
        {
                
        }];
    }];
    
    NSLog(@"Imported Patients: \n%@", patients);
    
    dataPath = [[NSBundle mainBundle] pathForResource:@"MedicationFile" ofType:@"json"];
    
    NSArray* Meds = [NSArray arrayWithArray:[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath]options:0 error:&err]];
    
    [Meds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        MedicationObject* base = [[MedicationObject alloc]init];
        NSError* success = [base setValueToDictionaryValues:obj];
        [base saveObject:^(id<BaseObjectProtocol> data, NSError *error)
        {
                
        }];
    }];
    
    NSLog(@"Imported Medications: \n%@", Meds.description);
}

// Implement switching to the Production Environment
- (IBAction)TearDownEnvironment:(id)sender
{
    NSError* err = nil;
    
    NSLog(@"Performing a True Purge of the System");
    [mainView truePurgeTheSystem:nil];
    
    // Set CloudManagementObject
    [cloudMO setActiveEnvironment:@"production"];
    
    // Sync Patients, Users, Medications, etc.
}

- (void) testCloud
{
//    BaseObject * obj = [[BaseObject alloc] init];
//    
//    NSMutableDictionary * mDic = [[NSMutableDictionary alloc]init];
//    
//    [mDic setObject:@"pooop" forKey:@"userName"];
//    [mDic setObject:@"poooop" forKey:@"password"];
//    [mDic setObject:@"poop" forKey:@"firstName"];
//    [mDic setObject:@"poop" forKey:@"lastName"];
//    [mDic setObject:@"poop@popper.com" forKey:@"email"];
//    [mDic setObject:@"1" forKey:@"userType"];
//    [mDic setObject:@"1" forKey:@"status"];
//    //    [mDic setObject:@"asd" forKey:@"remember_token"];
//    [obj query:@"deactivate_user" parameters:mDic completion:^(NSError *error, NSDictionary *result) {
//    }];
}

-(void)applicationWillTerminate:(NSNotification *)notification
{
    
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    return NSTerminateNow;
}

- (IBAction)restartServer:(id)sender
{
    if (connection.isServerRunning)
    {
        [connection stopServer];
    }
    
    [connection start];
}

- (IBAction)shutdownServer:(id)sender
{
    if (connection.isServerRunning)
    {
        [connection stopServer];
    }
}

- (IBAction)showMedicineView:(id)sender
{
    
}

- (IBAction)showMainServerView:(id)sender
{
    if(![_window isVisible] )
        [_window makeKeyAndOrderFront:sender];
}


- (IBAction)ToggleOptimization:(id)sender
{
    switch (isOptimized)
    {
        case kFirstSync:
            isOptimized = kFastSync;
            [_OptimizeToggler setTitle:@"Fast Sync -> Stabilize Sync"];
            break;
        case kFastSync:
            isOptimized = kStabilize;
            [_OptimizeToggler setTitle:@"Stabilize Sync -> Finalize Sync"];
            break;
        case kStabilize:
            isOptimized = kFinalize;
            [_OptimizeToggler setTitle:@"Finalize Sync-> First Sync"];
            break;
        case kFinalize:
            isOptimized = kFirstSync;
            [_OptimizeToggler setTitle:@"First Sync -> Fast Sync"];
            break;
    }
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    [_window makeKeyAndOrderFront:self];
    return YES;
}

-(Optimizer)isOptimized
{
    return isOptimized;
}
@end