//
//  UserView.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 3/23/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import "UserView.h"

@interface UserView (){
    NSMutableDictionary* currentUser;
}
@property(strong)NSArray* allUsers;
@end

@implementation UserView
@synthesize allUsers,tableView,usernameLabel,primaryRolePicker,loadIndicator;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self refreshTable:nil];
    }
    
    return self;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    NSDictionary* user = [allUsers objectAtIndex:rowIndex];
    
    if ([aTableColumn.identifier isEqualToString:STATUS]) {
        return ([[user objectForKey:aTableColumn.identifier]integerValue]==0)?@"Inactive":@"Active";
    }else if ([aTableColumn.identifier isEqualToString:USERTYPE]){
        switch ([[user objectForKey:aTableColumn.identifier]integerValue]) {
            case kTriageNurse:
                return @"Triage Nurse";
            case kDoctor:
                return @"Doctor";
            case kPharmacists:
                return @"Pharmacists";
            case kAdministrator:
                return @"Administrator";
            default:
                return @"Unspecified";
        }
    }
    return [user objectForKey:aTableColumn.identifier];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return allUsers.count;
}

-(BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row{
    
    currentUser = [NSMutableDictionary dictionaryWithDictionary:[allUsers objectAtIndex:row]];
    
    [primaryRolePicker selectItemAtIndex:[[currentUser objectForKey:USERTYPE]integerValue]];
    
    NSString* name = [NSString stringWithFormat:@"%@ %@",[currentUser objectForKey:FIRSTNAME],[currentUser objectForKey:LASTNAME]];
    
    [usernameLabel setStringValue:name];
    
    NSNumber* stat = [currentUser objectForKey: STATUS];
    
    [_userStatus selectItemAtIndex:(stat.boolValue)?1:0];
    
    return YES;
}

- (IBAction)refreshTable:(id)sender {
    [loadIndicator startAnimation:self];
    allUsers = [NSArray arrayWithArray:[[[UserObject alloc]init]FindAllObjects]];
    [loadIndicator stopAnimation:self];
    [tableView reloadData];
}

- (IBAction)commitChanges:(id)sender {
    
    [currentUser setValue:[NSNumber numberWithBool:(_userStatus.indexOfSelectedItem==1)] forKey:STATUS];
    
    UserObject* user =[[UserObject alloc]initWithCachedObjectWithUpdatedObject:currentUser];
    
    [user saveObject:^(id<BaseObjectProtocol> data, NSError *error) {
        NSLog(@"User save status:%@",(!error)?@"OK":@"FAILED");
        [self refreshTable:nil];
    }];
}

- (IBAction)cloudSync:(id)sender {
    
    UserObject* users = [[UserObject alloc]init];
    
    [loadIndicator startAnimation:self];
    
    [users pullFromCloud:^(id<BaseObjectProtocol> data, NSError *error) {
      
        if (error) {
            [NSApp presentError:error];
        }
        
        [self refreshTable:nil];
        
        [loadIndicator stopAnimation:self];
            
    }];
}
@end
