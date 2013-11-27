//
//  ConnectionTable.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 1/27/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import "ConnectionTable.h"
#import "ServerCore.h"
#import "UserObject.h"
id connection;

DatabaseDriver* userDatabaseDriver;

@implementation ConnectionTable
@synthesize listOfUsers;
#pragma mark -
#pragma mark NSTableView delegate methods

-(void)viewDidMoveToWindow{
    if (!appDelegate) {
        appDelegate = (FIUAppDelegate*)[[NSApplication sharedApplication]delegate];
        userDatabaseDriver = [[DatabaseDriver alloc]init];
        listOfUsers = [[NSMutableArray alloc]init];
        [self setDelegate:self];
        [self setDataSource:self];
        
       // connection = [ServerWrapper sharedServerManager];
        connection = [ServerCore sharedInstance];
        [connection startServer];
        
         NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
        
        // Normally the appdelegate starts first but in this case it doesnt, so
        // we listen for when the appdelegate says its up and running
        [center addObserverForName:APPDELEGATE_STARTED object:nil queue:nil usingBlock:^(NSNotification *note) {
            appDelegate = note.object;
            appDelegate.server = connection;
        }];
        
        // listen for when users add themselves to the database
        [center addObserverForName:SAVE_USER object:nil queue:nil usingBlock:^(NSNotification *note) {
            [self refreshServer:nil];
        }];
        
        [self refreshServer:nil];
    }
}



- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    UserObject* user = [[UserObject alloc]init];
    [user unpackageDatabaseFileForUser:[listOfUsers objectAtIndex:rowIndex]];
	return [user username];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    NSInteger list = listOfUsers.count;
	NSLog(@"Count: %li", list);
    return list;
}
-(BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row{
    UserObject* user = [[UserObject alloc]init];
    [user unpackageDatabaseFileForUser:[listOfUsers objectAtIndex:row]];
    [[NSNotificationCenter defaultCenter]postNotificationName:SELECTED_A_USER object:user];
    return YES;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;
{
 
}

-(void)refreshServer:(id)sender{
    [self beginUpdates];
    
    id arr= [userDatabaseDriver getListFromTable:@"Users" sortByAttr:@"username"];    
    //Sometimes the database doesnt initialze first so this tries to get a new one
    if (!arr) {
        userDatabaseDriver = [[DatabaseDriver alloc]init];
        arr = [userDatabaseDriver getListFromTable:@"Users" sortByAttr:@"username"];
    }
    listOfUsers = [NSMutableArray arrayWithArray:arr];
    [self endUpdates];
    [self reloadData];
    
}
-(void)StopServer:(id)sender{
    NSSegmentedControl* sc = sender;
    switch ([sc selectedSegment]) {
        case 0:
            [connection startServer];
            break;
        case 1:
            [connection stopServer];
            break;
        default:
            break;
    }
    
}

-(void)AuthorizeUser:(id)sender{
    
}
-(void)CommitNewUserInfo:(id)sender{
    
}
@end
