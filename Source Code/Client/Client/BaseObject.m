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
//  BaseObject.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 1/27/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//
#define MAX_NUMBER_ITEMS 4

#import "BaseObject+Protected.h"

@implementation BaseObject

#pragma mark- Init Methods
#pragma mark-
+(NSString *)getCurrenUserName
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:CURRENT_USER];
}

-(id)init
{
    self = [super init];
    if (self)
    {
        self->databaseObject = [super CreateANewObjectFromClass:self->COMMONDATABASE isTemporary:YES];
    }
    return self;
}

-(id)initAndMakeNewDatabaseObject
{
    self = [super init];
    if (self)
    {
        self->databaseObject = [super CreateANewObjectFromClass:self->COMMONDATABASE isTemporary:NO];
    }
    return self;
}

- (id)initAndFillWithNewObject:(NSDictionary *)info
{
    self = [self init];
    if (self)
    {
        [self unpackageFileForUser:info];
    }
    return self;
}

-(id)initWithCachedObjectWithUpdatedObject:(NSDictionary *)dic
{
    self = [super init];
    if (self)
    {
        NSString* objectID = [dic objectForKey:self->COMMONID];
        [self loadObjectForID:objectID];
        if (dic)
        {
            return ([self setValueToDictionaryValues:dic])?self:nil;
        }
    }
    return self;
}
#pragma mark- Init Methods
#pragma mark-

-(void)unpackageFileForUser:(NSDictionary *)data
{
    // Setup some of variables that are common to all the
    // the object that inherit from this base class
    self->commands = [[data objectForKey:OBJECTCOMMAND]intValue];
    [self->databaseObject setValuesForKeysWithDictionary:[data objectForKey:DATABASEOBJECT]];
}

//TODO: Not Implemented
-(void)CommonExecution
{
    NSLog(@"BaseObject:CommonExecution: Not Implemented");
}

-(NSManagedObject*)loadObjectWithID:(NSString *)objectID
{
    // checks to see if object exists
    NSArray* arr = [self FindObjectInTable:self->COMMONDATABASE withName:objectID forAttribute:self->COMMONID];
    if (arr.count > 0)
    {
        return [arr objectAtIndex:0];
    }
    return nil;
}

// Transforms the native database object into a dictionary
-(NSMutableDictionary*)getDictionaryValuesFromManagedObject
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];
    for (NSString* key in self->databaseObject.entity.attributesByName.allKeys)
    {
        [dict setValue:[self->databaseObject valueForKey:key] forKey:key];
    }
    return dict;
}

-(void)setDBObject:(NSManagedObject *)DatabaseObject
{
    self->databaseObject = DatabaseObject;
}

-(void)setObject:(id)object withAttribute:(NSString *)attribute
{
    [super setObject:object withAttribute:attribute inDatabaseObject:self->databaseObject];
}

-(id)getObjectForAttribute:(NSString *)attribute
{
   return [super getObjectForAttribute:attribute inDatabaseObject:self->databaseObject];
}

-(void)saveObject:(ObjectResponse)eventResponse
{
    id objID = [self->databaseObject valueForKey:self->COMMONID];
    
    if (!objID)
    {
        eventResponse(nil,[self createErrorWithDescription:@"Object was not assigned a primary key ID" andErrorCodeNumber:kErrorObjectMisconfiguration inDomain:@"Base Object"]);
        return;
    }
    NSManagedObject* obj = [self loadObjectWithID:objID];
    
    [obj setValuesForKeysWithDictionary:self.getDictionaryValuesFromManagedObject];
    if (obj)
    {
        if (!self->databaseObject.managedObjectContext)
        {
            [self SaveAndRefreshObjectToDatabase:obj];
        }
        else
        {
            [self SaveAndRefreshObjectToDatabase:self->databaseObject];
        }
    }
    else
    {
        if (self->databaseObject.managedObjectContext)
        {
            [self SaveAndRefreshObjectToDatabase:self->databaseObject];
        }
        else
        {
            obj = [self CreateANewObjectFromClass:self->COMMONDATABASE isTemporary:NO];
            [obj setValuesForKeysWithDictionary:self.getDictionaryValuesFromManagedObject];
            [self SaveAndRefreshObjectToDatabase:obj];
        }
    }
    eventResponse(self, nil);
}

-(BOOL)setValueToDictionaryValues:(NSDictionary*)values
{
    @try
    {
        for (NSString* key in values.allKeys)
        {
            if (![[values objectForKey:key]isKindOfClass:[NSNull class]])
            {
                id obj = [values objectForKey:key];
                [self->databaseObject setValue:([obj isKindOfClass:[NSDate class]])?[obj convertNSDateToSeconds]:obj forKey:key];
            }
        }
        return YES;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
}

-(BOOL)deleteCurrentlyHeldObjectFromDatabase
{
    return [self deleteNSManagedObject:self->databaseObject];
}

-(BOOL)deleteDatabaseDictionaryObject:(NSDictionary *)object
{
    return [self deleteObjectFromDatabase:self->COMMONDATABASE withDefiningAttribute:[object objectForKey:self->COMMONID] forKey:self->COMMONID];
}

-(BOOL)loadObjectForID:(NSString *)objectID
{
    // checks to see if object exists
    NSArray* arr = [self FindObjectInTable:self->COMMONDATABASE withName:objectID forAttribute:self->COMMONID];
    
    NSArray* filtered = [arr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K == %@",self->COMMONID,objectID]];
    
    // Stricted Condition
    if (filtered.count == 1)
    {
        self->databaseObject = [arr objectAtIndex:0];
        return  YES;
    }
    return  NO;
}
@end