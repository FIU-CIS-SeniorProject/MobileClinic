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
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"K == YES", ISACTIVE];
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

-(NSDate *)GetActiveTimestamp
{
    NSDictionary* dict = [self GetActiveEnvironment];
    NSDate* lastPullTime = nil;
    
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

-(NSString *)GetActiveUser
{
    NSDictionary* dict = [self GetActiveEnvironment];
    NSString* activeUser = nil;
    
    if (dict != nil)
    {
        activeUser = [dict valueForKey:ACTIVEUSER];
    }
    
    return activeUser;
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
-(void *)setActiveEnvironment: (NSString*)environmentName
{
    NSMutableDictionary* active = [[self GetActiveEnvironment] mutableCopy];
    
    if ([active valueForKey:NAME] != environmentName)
    {
        
    }
}
@end
