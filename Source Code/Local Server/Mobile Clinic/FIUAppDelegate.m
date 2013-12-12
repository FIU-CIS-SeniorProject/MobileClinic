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
    
    // Initialize the CloudManagementObjects if they do not exist
    // TEST
    NSMutableDictionary* testDictionary = [[[[CloudManagementObject alloc] init] GetEnvironment:@"test"] mutableCopy];
    
    if (testDictionary == nil)
    {
        testDictionary = [[NSMutableDictionary alloc] init];
        [testDictionary setObject:@"test" forKey:NAME];
        [testDictionary setObject:@(YES) forKey:ISACTIVE];
        [testDictionary setObject:[[NSDate distantPast] convertNSDateToSeconds] forKey:LASTPULLTIME];
        [testDictionary setObject:@"http://still-citadel-8045.herokuapp.com/" forKey:CLOUDURL];
        [testDictionary setObject:@(NO) forKey: ISDIRTY];
        [testDictionary setObject:@"" forKey: ACTIVEUSER];
        
        CloudManagementObject* testCMO = [[CloudManagementObject alloc] initAndMakeNewDatabaseObject];
        [testCMO setValueToDictionaryValues: testDictionary];
        [testCMO saveObject:^(id<BaseObjectProtocol> data, NSError *error) {}];
    }
    
    //testing if it works. DELETE when it works!
    //testDictionary = [[[[CloudManagementObject alloc] init] GetEnvironment:@"test"] mutableCopy];
    
    NSMutableDictionary* productionDictionary = [[[[CloudManagementObject alloc] init] GetEnvironment:@"production"] mutableCopy];
    
    if (productionDictionary == nil)
    {
        productionDictionary = [[NSMutableDictionary alloc] init];
        [productionDictionary setObject:@"production" forKey:NAME];
        [productionDictionary setObject:@(NO) forKey:ISACTIVE];
        [productionDictionary setObject:[[NSDate distantPast] convertNSDateToSeconds] forKey:LASTPULLTIME];
        [productionDictionary setObject:@"http://pure-island-5858.herokuapp.com/" forKey:CLOUDURL];
        [productionDictionary setObject:@(NO) forKey: ISDIRTY];
        [productionDictionary setObject:@"" forKey: ACTIVEUSER];
        
        CloudManagementObject* productionCMO = [[CloudManagementObject alloc] initAndMakeNewDatabaseObject];
        [productionCMO setValueToDictionaryValues:productionDictionary];
        [productionCMO saveObject:^(id<BaseObjectProtocol> data, NSError *error) {}];
    }
    
    [self loadDefaultUser];
    
    [[[CloudManagementObject alloc] init] updateActiveUser:@""];
}

// Switching to the Test Environment
- (IBAction)setupTestPatients:(id)sender
{
    NSAlert* alert = [[NSAlert alloc] init];
    
    if ([[[[CloudManagementObject alloc]init] GetActiveUser] isEqual: @""])
    {
        [alert setMessageText:@"You must be logged in to Purge the System"];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
        return;
    }
    
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"No"];
    [alert setMessageText:@"Confirm Switch to Test Environment"];
    [alert setInformativeText:@"Switching to the test environment will purge the system of Patient and User data."];
    
    if ([alert runModal] == NSAlertFirstButtonReturn)
    {
        BOOL syncWithCloudFirst;
        BOOL loadJSON;
        BOOL syncWithCloudSecond;
        
        // Ask to sync with cloud before purging the system
        alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Yes"];
        [alert addButtonWithTitle:@"No"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert setMessageText:@"Syncronize with Cloud before Purging the system?"];
        [alert setAlertStyle:NSWarningAlertStyle];
        
        NSInteger* choice = [alert runModal];
        
        switch ((int)choice)
        {
            case NSAlertFirstButtonReturn:
                syncWithCloudFirst = YES;
                break;
            case NSAlertSecondButtonReturn:
                syncWithCloudFirst = NO;
                break;
            case NSAlertThirdButtonReturn:
                return;
                break;
            default:
                return;
                break;
        }
        
        // Ask to load from JSON files after purging the system
        alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Yes"];
        [alert addButtonWithTitle:@"No"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert setMessageText:@"Load JSON files after Purging the system?"];
        [alert setAlertStyle:NSWarningAlertStyle];
        
        choice = [alert runModal];
        
        switch ((int)choice)
        {
            case NSAlertFirstButtonReturn:
                loadJSON = YES;
                break;
            case NSAlertSecondButtonReturn:
                loadJSON = NO;
                break;
            case NSAlertThirdButtonReturn:
                return;
                break;
            default:
                return;
                break;
        }
        
        alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Yes"];
        [alert addButtonWithTitle:@"No"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert setMessageText:@"Syncronize with Cloud after Purging the system?"];
        [alert setAlertStyle:NSWarningAlertStyle];
        
        choice = [alert runModal];
        
        switch ((int)choice)
        {
            case NSAlertFirstButtonReturn:
                syncWithCloudSecond = YES;
                break;
            case NSAlertSecondButtonReturn:
                syncWithCloudSecond = NO;
                break;
            case NSAlertThirdButtonReturn:
                return;
                break;
            default:
                return;
                break;
        }
        
        // - DO NOT COMMENT: IF YOUR RESTART YOUR SERVER IT WILL PLACE DEMO PATIENTS INSIDE TO HELP ACCELERATE YOUR TESTING
        // - YOU CAN SEE WHAT PATIENTS ARE ADDED BY CHECKING THE PatientFile.json file
        NSError* err = nil;
        
        //TODO: Sync with cloud first
        if (syncWithCloudFirst)
        {
            [[[PatientObject alloc] init] pushToCloud:^(id cloudResults, NSError *error)
            {
                // Nothing
            }];
            
            [[[VisitationObject alloc] init] pushToCloud:^(id cloudResults, NSError *error)
             {
                 // Nothing
             }];
        }
        
        NSLog(@"Performing a True Purge of the System");
        [mainView completeSystemPurge];
        
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
}

// Implement switching to the Production Environment
- (IBAction)TearDownEnvironment:(id)sender
{
    NSAlert* alert = [[NSAlert alloc] init];
    
    if ([[[[CloudManagementObject alloc]init] GetActiveUser] isEqual: @""])
    {
        [alert setMessageText:@"You must be logged in to Purge the System"];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
        return;
    }
    
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"No"];
    [alert setMessageText:@"Confirm Switch to Production Environment"];
    [alert setInformativeText:@"Switching to the test environment will purge the system of Patient and User data."];
    
    if ([alert runModal] == NSAlertFirstButtonReturn)
    {
        NSError* err = nil;
        
        NSLog(@"Performing a True Purge of the System");
        [mainView truePurgeTheSystem:nil];
        
        // Set CloudManagementObject
        [cloudMO setActiveEnvironment:@"production"];
        
        // Sync Patients, Users, Medications, etc.
    }
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

-(void)loadDefaultUser
{
    NSArray* userArray = [[[UserObject alloc] init] FindAllObjects];
    
    if ([userArray count] <= 0)
    {
        NSMutableDictionary* defaultUser = [[NSMutableDictionary alloc] init];
        [defaultUser setObject:@"defaultuser@default.com" forKey:EMAIL];
        [defaultUser setObject:@"John" forKey:FIRSTNAME];
        [defaultUser setObject:@"Smith" forKey:LASTNAME];
        [defaultUser setObject:@(3) forKey:USERTYPE];
        [defaultUser setObject:@"jsmith13" forKey:USERNAME];
        [defaultUser setObject:@"orant" forKey:PASSWORD];
        [defaultUser setObject:@(YES) forKey:STATUS];
        [defaultUser setObject:@(0) forKey:CHARITYID];
        [defaultUser setObject:@(NO) forKey: ISDIRTY];
        
        UserObject* newDefaultUser = [[UserObject alloc] initAndMakeNewDatabaseObject];
        [newDefaultUser setValueToDictionaryValues:defaultUser];
        [newDefaultUser saveObject:^(id<BaseObjectProtocol> data, NSError *error) {}];
    }
}
@end