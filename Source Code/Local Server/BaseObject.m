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
//
#import "BaseObject.h"
#define MAX_NUMBER_ITEMS 4
#import "BaseObject+Protected.h"

@implementation BaseObject

#pragma mark - Initialization Methods
#pragma mark-

-(id)init
{
    self = [super init];
    if (self)
    {
        cloudAPI = [[CloudService alloc]init];
        databaseObject = [super CreateANewObjectFromClass:COMMONDATABASE isTemporary:YES];
    }
    return self;
}

-(id)initAndMakeNewDatabaseObject
{
    self = [super init];
    if (self)
    {
        cloudAPI = [[CloudService alloc]init];
        databaseObject = [super CreateANewObjectFromClass:COMMONDATABASE isTemporary:NO];
    }
    return self;
}

- (id)initAndFillWithNewObject:(NSDictionary *)info
{
    self = [self init];
    if (self)
    {
        cloudAPI = [[CloudService alloc]init];
        [self unpackageFileForUser:info];
    }
    return self;
}

-(id)initWithCachedObjectWithUpdatedObject:(NSDictionary *)dic
{
    self = [super init];
    if (self)
    {
        cloudAPI = [[CloudService alloc]init];
        NSString* objectID = [dic objectForKey:COMMONID];
        [self loadObjectForID:objectID];
        if (dic)
        {
            NSError* success = [self setValueToDictionaryValues:dic];
            return (!success)?self:nil;
        }
    }
    return self;
}

#pragma mark - Convenience Methods
#pragma mark-

-(void)ServerCommand:(NSDictionary *)dataToBeRecieved withOnComplete:(ServerCommand)response
{
    commandPattern = response;
}

-(NSError*)setValueToDictionaryValues:(NSDictionary*)values
{
    NSMutableArray* badValues = [[NSMutableArray alloc]initWithCapacity:values.count];
    NSMutableArray* tracker = [[NSMutableArray alloc]init];

    for (NSString* key in values.allKeys)
    {
        @try
        {
            if (![[values objectForKey:key]isKindOfClass:[NSNull class]])
            {
                id obj = [values objectForKey:key];
                
                if (!obj)
                {
                    continue;
                }
                
                [databaseObject setValue:([obj isKindOfClass:[NSDate class]])?[obj convertNSDateToSeconds]:obj forKey:key];
            }
        }
        @catch (NSException *exception)
        {
            NSArray* test =[tracker filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF == %@",key]];
                
            if (test.count == 0)
            {
                [tracker addObject:key];
                [badValues addObject:key];
            }
            NSLog(@"Error: Bad Key: %@ or Value: %@ in %@",key,[values objectForKey:key],COMMONDATABASE);
        }
    }
   
    if (badValues.count > 0)
    {
        NSString* msg = [NSString stringWithFormat:@"The database could not handle the following Keys: %@",badValues.description];
        return [self createErrorWithDescription:msg andErrorCodeNumber:kErrorObjectMisconfiguration inDomain:COMMONDATABASE];
    }
    
    return nil;
}

-(NSMutableDictionary*)getDictionaryValuesFromManagedObject:(NSManagedObject*)object
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];
    for (NSString* key in object.entity.attributesByName.allKeys)
    {
        [dict setValue:[object valueForKey:key] forKey:key];
    }
    return dict;
}

-(NSMutableDictionary*)getDictionaryValuesFromManagedObject
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];
    for (NSString* key in databaseObject.entity.attributesByName.allKeys)
    {
        [dict setValue:[databaseObject valueForKey:key] forKey:key];
    }
    return dict;
}

#pragma mark- DATA RETRIEVAL & TELEPORTION Methods
#pragma mark-

#pragma mark- SAVE Methods
#pragma mark-

// MARK: Saves the current databaseObject without duplicating it
-(void)saveObject:(ObjectResponse)eventResponse
{
    // get the UID of the object
    id objID = [databaseObject valueForKey:COMMONID];
    
    if(!objID)
    {
        eventResponse(nil,[self createErrorWithDescription:@"Object does not have a primary key ID" andErrorCodeNumber:kErrorObjectMisconfiguration inDomain:COMMONDATABASE]);
        return;
    }

    // Find if object already exists
    NSManagedObject* obj = [self loadObjectWithID:objID];
    
    // If the old object does not exist OR
    // if the old object is Clean (Unmodified) OR
    // if the old object is dirty (modified) AND the new object is dirty
    if (!obj || ![obj valueForKey:ISDIRTY] || ([obj valueForKey:ISDIRTY] && [databaseObject valueForKey:ISDIRTY]))
    {
        // update the object we found in the database
        [obj setValuesForKeysWithDictionary:self.getDictionaryValuesFromManagedObject];
    }
    else
    {
        eventResponse(nil,[self createErrorWithDescription:@"A clean object cannot update a modified object" andErrorCodeNumber:kErrorObjectMisconfiguration inDomain:COMMONDATABASE]);
        return;
    }
    
    // if there is was something to save
    if (obj)
    {
        // save it
        [self SaveCurrentObjectToDatabase:obj];
    }
    else
    {
        obj = [self CreateANewObjectFromClass:COMMONDATABASE isTemporary:NO];
        [obj setValuesForKeysWithDictionary:self.getDictionaryValuesFromManagedObject];
        [self SaveCurrentObjectToDatabase:obj];
    }
    
    if (eventResponse)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:UPDATEPATIENT object:nil];
        eventResponse(self, nil);
    }
}

-(NSString*)convertDateNumberForPrinting:(NSNumber*)number
{
    if (number)
    {
        return [[NSDate convertSecondsToNSDate:number]convertNSDateToMonthDayYearTimeString];
    }
    return @"N/A";
}

-(BOOL)deleteCurrentlyHeldObjectFromDatabase
{
   return [self deleteNSManagedObject:databaseObject];
}

-(BOOL)deleteDatabaseDictionaryObject:(NSDictionary *)object
{
    return [self deleteObjectsFromDatabase:COMMONDATABASE withDefiningAttribute:[object objectForKey:COMMONID] forKey:COMMONID];
}

-(NSString*)convertTextForPrinting:(NSString*)text
{
    return ([text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0)?text:@"Incomplete";
}

-(NSDictionary *)consolidateForTransmitting
{
    NSMutableDictionary* consolidate = [[NSMutableDictionary alloc]initWithCapacity:1];
    [consolidate setValue:[databaseObject dictionaryWithValuesForKeys:databaseObject.entity.attributeKeys] forKey:DATABASEOBJECT];
    return consolidate;
}
@end