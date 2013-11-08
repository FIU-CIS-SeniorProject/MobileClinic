//
//  MainMenu.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 3/24/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import "MainMenu.h"
#import "ServerCore.h"
#import "UserView.h"
#import "PatientTable.h"
#import "MedicationList.h"
#import "SystemBackup.h"
SystemBackup* backup;
MedicationList* medicationView;
PatientTable* patientView;
UserView* userView;
id currentView;
id<ServerProtocol> connection;
@implementation MainMenu

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
            }
    
    return self;
}
-(void)windowDidBecomeKey:(NSNotification *)notification{
    if (!connection){
        
        connection = [ServerCore sharedInstance];
        
        [connection start];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(manualTableRefresh:) name:SERVER_OBSERVER object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(SetStatus:) name:SERVER_STATUS object:[[NSNumber alloc]init]];
        
        [self manualTableRefresh:nil];
    }
  
}




- (IBAction)quitApplication:(id)sender {
    [NSApp terminate:self];
}

- (IBAction)showMedicationView:(id)sender {
    if (!medicationView) {
        medicationView = [[MedicationList alloc]initWithNibName:@"MedicationList" bundle:nil];
    }
    if (currentView) {
        [_mainScreen replaceSubview:currentView with:medicationView.view];
        
    }else{
        [_mainScreen addSubview:medicationView.view];
        
    }
    currentView = medicationView.view;
}

- (IBAction)showPatientView:(id)sender {
    if (!patientView) {
        patientView = [[PatientTable alloc]initWithNibName:@"PatientTable" bundle:nil];
    }
    if (currentView) {
        [_mainScreen replaceSubview:currentView with:patientView.view];
        
    }else{
        [_mainScreen addSubview:patientView.view];
        
    }
    currentView = patientView.view;
}

- (IBAction)purgeTheSystem:(id)sender {
    VisitationObject* v = [[VisitationObject alloc]init];
    
    NSArray* allVisits =  [v FindAllObjects];
    
    PatientObject* p = [[PatientObject alloc]init];
    
    NSArray* allPatient = [p FindAllObjects];
    
    int counter = 0;
    
    for (NSDictionary* visit in allVisits) {

        NSPredicate* pred = [NSPredicate predicateWithFormat:@"%K == %@",PATIENTID,[visit objectForKey:PATIENTID]];
        
       NSArray* filtered = [allPatient filteredArrayUsingPredicate:pred];
        
        if (filtered.count == 0) {
            
          BOOL didDelete =  [v deleteDatabaseDictionaryObject:visit];
            if (didDelete) {
                counter++;
            }
        }
    }
    NSAlert *alert = [[NSAlert alloc] init];
    
    NSString* msg = [NSString stringWithFormat:@"%i Unlinked visits were removed from the system",counter];
    [alert setMessageText:msg];
    
    [alert runModal];
}

- (IBAction)manualTableRefresh:(id)sender {
   
    NSInteger num = [connection numberOfConnections];
    
    [_statusIndicator setIntValue:(int)num];
    
    switch (num) {
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

- (IBAction)showUserView:(id)sender {
    if (!userView) {
        userView = [[UserView alloc]initWithNibName:@"UserView" bundle:nil];
    }
    if (currentView) {
        [_mainScreen replaceSubview:currentView with:userView.view];
       
    }else{
        [_mainScreen addSubview:userView.view];

    }
    currentView = userView.view;
}

- (IBAction)emergencyDataDump:(id)sender {
    if (!backup) {
        backup = [[SystemBackup alloc]init];
    }
    
    NSError* error= [backup BackupEverything];
    
    if (error) {
        [NSApp presentError:error];
    }
}

-(void)SetStatus:(NSNotification*)note{
    
    int i = [note.object intValue];

    switch (i) {
        case 0:
            [_statusLabel setStringValue:@"ON"];
            
            break;

        default:
            [_statusLabel setStringValue:@"OFF"];
            break;
    }
}
- (IBAction)pushPatientsToCloud:(id)sender {
    
    [[[PatientObject alloc]init]pushToCloud:^(id cloudResults, NSError *error) {
        
        if (error) {
        NSAlert *alert = [[NSAlert alloc] init];
        
       // NSString* msg = [NSString stringWithFormat:@"%i Unlinked visits were removed from the system",counter];
        
        [alert setMessageText:error.localizedDescription];
        
        [alert runModal];
        }
    }];
}
@end
