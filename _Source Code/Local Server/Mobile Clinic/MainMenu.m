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
//  MainMenu.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 3/24/13.
//  Edited by James Mendez 11/2013
//
#import "MainMenu.h"
#import "ServerCore.h"
#import "UserView.h"
#import "LoginView.h"
#import "PatientTable.h"
#import "MedicationList.h"
#import "SystemBackup.h"
#import "CloudManagementObject.h"

SystemBackup* backup;
MedicationList* medicationView;
PatientTable* patientView;
UserView* userView;
LoginView* loginView;

id currentView;
id<ServerProtocol> connection;
@implementation MainMenu

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {

    }
    
    return self;
}

-(void)windowDidBecomeKey:(NSNotification *)notification
{
    if (!connection)
    {
        
        //Set initial view to loginView
        if (!loginView)
        {
            loginView = [[LoginView alloc]initWithNibName:@"LoginView" bundle:nil];
        }
        
        if (currentView)
        {
            [_mainScreen replaceSubview:currentView with:loginView.view];
        }
        else
        {
            [_mainScreen addSubview:loginView.view];
        }
        currentView = loginView.view;
        
        //disable buttons till login
        [_userButton setEnabled: NO];
        [_patientButton setEnabled: NO];
        [_medicationButton setEnabled: NO];
        [_logoutButton setEnabled: NO];
        
        connection = [ServerCore sharedInstance];
        [connection start];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(enableButtons:) name:@"LOGIN_OBSERVER" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(manualTableRefresh:) name:SERVER_OBSERVER object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(SetStatus:) name:SERVER_STATUS object:[[NSNumber alloc]init]];
        [self manualTableRefresh:nil];
    }
}

- (IBAction)quitApplication:(id)sender
{
    [NSApp terminate:self];
}

- (IBAction)showLoginView:(id)sender
{
    //reset current view
    if (currentView == userView.view) {
        [userView.view removeFromSuperview];
    } else if (currentView == patientView.view) {
        [patientView.view removeFromSuperview];
    } else {
        [medicationView.view removeFromSuperview];
    }
    //set view to login
    [_mainScreen addSubview:loginView.view];
    currentView = loginView.view;
    
    //disable view buttons
    [_userButton setEnabled: NO];
    [_patientButton setEnabled: NO];
    [_medicationButton setEnabled: NO];
    [_logoutButton setEnabled: NO];
}

- (IBAction)showMedicationView:(id)sender
{
    if (!medicationView)
    {
        medicationView = [[MedicationList alloc]initWithNibName:@"MedicationList" bundle:nil];
    }
    
    if (currentView)
    {
        [_mainScreen replaceSubview:currentView with:medicationView.view];
    }
    else
    {
        [_mainScreen addSubview:medicationView.view];
    }
    currentView = medicationView.view;
}

- (IBAction)showPatientView:(id)sender
{
    if (!patientView)
    {
        patientView = [[PatientTable alloc]initWithNibName:@"PatientTable" bundle:nil];
    }
    
    if (currentView)
    {
        [_mainScreen replaceSubview:currentView with:patientView.view];
    }
    else
    {
        [_mainScreen addSubview:patientView.view];
    }
    currentView = patientView.view;
}

- (IBAction)purgeTheSystem:(id)sender
{
    VisitationObject* v = [[VisitationObject alloc]init];
    NSArray* allVisits =  [v FindAllObjects];
    PatientObject* p = [[PatientObject alloc]init];
    NSArray* allPatient = [p FindAllObjects];
    
    int counter = 0;
    
    for (NSDictionary* visit in allVisits)
    {
        NSPredicate* pred = [NSPredicate predicateWithFormat:@"%K == %@",PATIENTID,[visit objectForKey:PATIENTID]];
        NSArray* filtered = [allPatient filteredArrayUsingPredicate:pred];
        
        if (filtered.count == 0)
        {
            BOOL didDelete =  [v deleteDatabaseDictionaryObject:visit];
            if (didDelete)
            {
                counter++;
            }
        }
    }
    NSAlert *alert = [[NSAlert alloc] init];
    
    NSString* msg = [NSString stringWithFormat:@"%i Unlinked visits were removed from the system",counter];
    [alert setMessageText:msg];
    [alert runModal];
}

- (IBAction)truePurgeTheSystem:(id)sender
{
    VisitationObject* v = [[VisitationObject alloc] init];
    NSArray* allVisits = [v FindAllObjects];
    PatientObject* p = [[PatientObject alloc] init];
    NSArray* allPatients = [p FindAllObjects];
    MedicationObject* m = [[MedicationObject alloc] init];
    NSArray* allMedications = [m FindAllObjects];
    UserObject* u = [[UserObject alloc] init];
    NSArray* allUsers = [u FindAllObjects];

    int vCounter = 0;
    int pCounter = 0;
    int mCounter = 0;
    int uCounter = 0;

    for (NSDictionary* visit in allVisits)
    {
        BOOL didDelete = [v deleteDatabaseDictionaryObject:visit];
        if (didDelete)
        {
            vCounter++;
        }
    }
    
    for (NSDictionary* patient in allPatients)
    {
        BOOL didDelete = [p deleteDatabaseDictionaryObject:patient];
        if (didDelete)
        {
            pCounter++;
        }
    }
    
    for (NSDictionary* medication in allMedications)
    {
        BOOL didDelete = [m deleteDatabaseDictionaryObject:medication];
        if (didDelete)
        {
            mCounter++;
        }
    }

    for (NSDictionary* user in allUsers)
    {
        BOOL didDelete = [u deleteDatabaseDictionaryObject:user];
        if (didDelete)
        {
            uCounter++;
        }
    }
    
    NSLog(@"Truly Purged The System of %i Visits, %i Patients, %i Medications, and %i Users", vCounter, pCounter, mCounter, uCounter);
}

- (IBAction)manualTableRefresh:(id)sender
{
    NSInteger num = [connection numberOfConnections];
    [_statusIndicator setIntValue:(int)num];
    
    switch (num)
    {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
            [_activityLabel setStringValue:@"Stable"];
            break;
        case 6:
        case 7:
            [_activityLabel setStringValue:@"Caution: High Load"];
            break;
        default:
            [_activityLabel setStringValue:@"Warning: Unstable!"];
            break;
    }
    [_connectionLabel setStringValue:[NSString stringWithFormat:@"%li Device(s) Connected",num]];
}

- (IBAction)showUserView:(id)sender
{
    if (!userView)
    {
        userView = [[UserView alloc]initWithNibName:@"UserView" bundle:nil];
    }
    
    if (currentView)
    {
        [_mainScreen replaceSubview:currentView with:userView.view];
       
    }
    else
    {
        [_mainScreen addSubview:userView.view];
    }
    currentView = userView.view;
}

- (IBAction)emergencyDataDump:(id)sender
{
    if (!backup)
    {
        backup = [[SystemBackup alloc]init];
    }
    
    NSError* error= [backup BackupEverything];
    
    if (error)
    {
        [NSApp presentError:error];
    }
}

-(void)SetStatus:(NSNotification*)note
{
    int i = [note.object intValue];

    switch (i)
    {
        case 0:
            [_statusLabel setStringValue:@"ON"];
            break;
        default:
            [_statusLabel setStringValue:@"OFF"];
            break;
    }
}

-(void)enableButtons:(NSNotification*)note
{
    [loginView.view removeFromSuperview];
    currentView = nil;
    //restore initial state of logged out user
    [_userButton setEnabled:YES];
    [_patientButton setEnabled:YES];
    [_medicationButton setEnabled:YES];
    [_logoutButton setEnabled:YES];
}

- (IBAction)pushPatientsToCloud:(id)sender
{
    [[[PatientObject alloc]init]pushToCloud:^(id cloudResults, NSError *error)
    {
        if (error)
        {
            NSAlert *alert = [[NSAlert alloc] init];
            //NSString* msg = [NSString stringWithFormat:@"%i Unlinked visits were removed from the system",counter];
            [alert setMessageText:error.localizedDescription];
            [alert runModal];
        }
    }];
}
@end