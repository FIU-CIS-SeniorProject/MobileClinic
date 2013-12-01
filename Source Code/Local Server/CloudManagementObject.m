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
//  CloudManagementObject.m
//  Mobile Clinic
//
//  Created by Kevin Diaz on 11/02/13.
//
#import "BaseObject+Protected.h"
#import "CloudManagementObject.h"

#define DATABASE    @"CloudManagement"

NSString* name;
NSString* url;
NSDate* lastPullTime;
int* isActive;

@implementation CloudManagementObject

+(NSString *)DatabaseName
{
    return DATABASE;
}

-(id)init
{
    [self setupObject];
    return [super init];
}

-(id)initAndMakeNewDatabaseObject
{
    [self setupObject];
    return [super initAndMakeNewDatabaseObject];
}

-(id)initAndFillWithNewObject:(NSDictionary *)info
{
    [self setupObject];
    return [super initAndFillWithNewObject:info];
}

-(id)initWithCachedObjectWithUpdatedObject:(NSDictionary *)dic
{
    [self setupObject];
    return [super initWithCachedObjectWithUpdatedObject:dic];
}

-(void)setupObject
{
    self->COMMONID =  NAME;
    self->CLASSTYPE = kCloudManagementType;
    self->COMMONDATABASE = DATABASE;
}

-(void)linkDatabase
{
    cloudMO = (CloudManager*)self->databaseObject;
}

-(void)unpackageFileForUser:(NSDictionary *)data
{
    [super unpackageFileForUser:data];
    name = [self->databaseObject valueForKey:NAME];
    url = [self->databaseObject valueForKey:CLOUDURL];
}

-(NSArray *)FindAllObjects
{
    return [self convertListOfManagedObjectsToListOfDictionaries:[self FindObjectInTable:DATABASE withCustomPredicate:nil andSortByAttribute:NAME]];
}

-(NSArray *)FindAllObjectsUnderParentID:(NSString *)parentID
{
    return [self FindAllObjects];
}

-(NSDictionary *)GetActiveEnvironment
{
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"%K == YES", ISACTIVE];
    NSArray* managedObjects = [self FindObjectInTable:DATABASE withCustomPredicate:pred andSortByAttribute:NAME];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    if (managedObjects.count == 1)
    {
        for (NSManagedObject* objs in managedObjects)
        {
            dict = [self getDictionaryValuesFromManagedObject:objs];
        }
    }
    return dict;
}

-(NSNumber *)GetActiveTimestamp
{
    NSDictionary* dict = [self GetActiveEnvironment];
    NSNumber* lastPullTime = nil;
    
    if (dict != nil)
    {
        lastPullTime = [dict valueForKey:LASTPULLTIME];
    }
    
    return lastPullTime;
}

-(NSString *)GetActiveURL
{
    NSDictionary* dict = [self GetActiveEnvironment];
    NSString* activeURL = nil;
    
    if (dict != nil)
    {
        activeURL = [dict valueForKey:CLOUDURL];
    }
    
    return activeURL;
}

-(NSDate *)GetTimestamp: (NSString*)environment
{
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"%K == %@",NAME, environment];
    NSArray* managedObjects = [self FindObjectInTable:DATABASE withCustomPredicate:pred andSortByAttribute:NAME];
    NSDate* lastPullTime = nil;
    
    if (managedObjects.count == 1)
    {
        // take object in array and put into dictionary
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        for (NSManagedObject* objs in managedObjects)
        {
            dict = [self getDictionaryValuesFromManagedObject:objs];
        }
        lastPullTime = [dict valueForKey:LASTPULLTIME];
        // take value for key of last pull in dictionary
    }
    return lastPullTime;
}

//TODO: Implement
-(void)setActiveEnvironment: (NSString*)environmentName
{
    NSMutableDictionary* active = [[self GetActiveEnvironment] mutableCopy];
    CloudManagementObject* activeCMO;
    
    if (active == nil)
    {
        active = [[self GetEnvironment:environmentName] mutableCopy];
        [active setObject:[NSNumber numberWithBool:YES] forKey:ISACTIVE];
        activeCMO = [[CloudManagementObject alloc] initWithCachedObjectWithUpdatedObject:active];
        [activeCMO saveObject:^(id<BaseObjectProtocol> data, NSError *error)
        {
             // Nothing?
        }];
    }
    else if ([active valueForKey:NAME] != environmentName)
    {
        // Set Active Environment to inactive
        [active setObject:[NSNumber numberWithBool:NO] forKey:ISACTIVE];
        
        // Get requested Environment
        NSMutableDictionary* requested = [[self GetEnvironment:environmentName] mutableCopy];
        
        // Set requested environment to active
        [requested setObject:[NSNumber numberWithBool:YES] forKey:ISACTIVE];
        
        // Save both environments
        activeCMO = [[CloudManagementObject alloc] initWithCachedObjectWithUpdatedObject:active];
        [activeCMO saveObject:^(id<BaseObjectProtocol> data, NSError *error)
        {
            // Nothing?
        }];
        
        CloudManagementObject* reqCMO = [[CloudManagementObject alloc] initWithCachedObjectWithUpdatedObject:requested];
        [reqCMO saveObject:^(id<BaseObjectProtocol> data, NSError *error)
        {
            // Nothing?
        }];
    }
}

//TODO: Implement
-(NSDictionary *)GetEnvironment: (NSString*)environment
{
    NSMutableDictionary *cmo = [[NSMutableDictionary alloc] init];
    
    //NSPredicate* pred = [NSPredicate predicateWithFormat:@"%@ == %@",NAME, environment];
    //NSArray* managedObjects = [self FindObjectInTable:DATABASE withCustomPredicate:nil andSortByAttribute:NAME];
    //Compare to finding a user
    //NSArray* managedObjects = [self FindObjectInTable:DATABASE withName:environment forAttribute:NAME];
    //NSDate* lastPullTime = nil;
    
    // Try to find user from username in local DB
    BOOL didFindCMO = [self loadObjectForID:environment];
    
    // link databaseObject to convenience Object named "user"
    [self linkDatabase];

    if (didFindCMO)
    {
        // take object in array and put into dictionary
        //dict = [self getDictionaryValuesFromManagedObject:managedObjects[0]];
        [cmo setObject:cloudMO.name forKey:NAME];
        [cmo setObject:cloudMO.isActive forKey:ISACTIVE];
        [cmo setObject:cloudMO.isDirty forKey:ISDIRTY];
        [cmo setObject:cloudMO.cloudURL forKey:CLOUDURL];
        [cmo setObject:cloudMO.lastPullTime forKey:LASTPULLTIME];
    }
    else
    {
        cmo = nil;
    }
    
    return cmo;
}

// MARK: Loads objects to an instantiated databaseObject
-(BOOL)loadObjectForID:(NSString *)objectID
{
    // checks to see if object exists
    NSArray* arr = [self FindObjectInTable:DATABASE withName:objectID forAttribute:NAME];
    
    if (arr.count == 1)
    {
        self->databaseObject = [arr objectAtIndex:0];
        return  YES;
    }
    else
    {
        return  NO;
    }
}
@end