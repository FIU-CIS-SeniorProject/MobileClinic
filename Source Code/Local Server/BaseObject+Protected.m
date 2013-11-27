//
//  BaseObject+Protected.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 3/26/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import "BaseObject+Protected.h"

@implementation BaseObject (Protected)

-(void)makeCloudCallWithCommand:(NSString *)command withObject:(id)object onComplete:(CloudCallback)onComplete
{
    [[CloudService cloud] query:command parameters:object  completion:^(NSError *error, NSDictionary *result)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            onComplete(result,error);
            NSLog(@"BASEOBJECT LOG: %@",result);
        });
        
    }];

}


-(void)copyDictionaryValues:(NSDictionary*)dictionary intoManagedObject:(NSManagedObject*)mObject{
    for (NSString* key in dictionary.allKeys) {
        [mObject setValue:[dictionary objectForKey:key] forKey:key];
    }
}
// MARK: Sends a Dictionary to the client
-(void)sendInformation:(id)data toClientWithStatus:(int)kStatus andMessage:(NSString*)message{
    if (!status) {
        status =[[StatusObject alloc]init];
    }
    // set data
    [status setData:data];
    
    // Set message
    [status setErrorMessage:message];
    
    // set status
    [status setStatus:kStatus];
    
    commandPattern([status consolidateForTransmitting]);
}

-(BOOL)isObject:(id)obj UniqueForKey:(NSString*)key
{
    // Check if it exists in database
    if ([self FindObjectInTable:self->COMMONDATABASE withName:obj forAttribute:key].count > 0) {
        return NO;
    }
    return YES;
}

// MARK: Loads objects to an instantiated databaseObject
-(BOOL)loadObjectForID:(NSString *)objectID{
    // checks to see if object exists
    NSArray* arr = [self FindObjectInTable:self->COMMONDATABASE withName:objectID forAttribute:self->COMMONID];
    
    if (arr.count == 1) {
        self->databaseObject = [arr objectAtIndex:0];
        return  YES;
    }
    return  NO;
}

-(NSManagedObject*)loadObjectWithID:(NSString *)objectID{
    // checks to see if object exists
    NSArray* arr = [self FindObjectInTable:self->COMMONDATABASE withName:objectID forAttribute:self->COMMONID];
    if (arr.count > 0) {
        return [arr objectAtIndex:0];
    }
    return nil;
}

// MARK: Converts and array of NSManagedObjects to an array of dictionaries
-(NSMutableArray*)convertListOfManagedObjectsToListOfDictionaries:(NSArray*)managedObjects{
    
    NSMutableArray* arrayWithDictionaries = [[NSMutableArray alloc]initWithCapacity:managedObjects.count];
    
    for (NSManagedObject* objs in managedObjects) {
        [arrayWithDictionaries addObject:[self getDictionaryValuesFromManagedObject:objs]];
    }
    return arrayWithDictionaries;
}

// MARK: Send and array of dictionaries to the client
-(void)sendSearchResults:(NSArray*)results{
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc]initWithCapacity:2];
    
    [dict setValue:[NSNumber numberWithInteger:self->CLASSTYPE] forKey:OBJECTTYPE];
    
    [dict setValue:results forKey:ALLITEMS];
    
    [self sendInformation:dict toClientWithStatus:kSuccess andMessage:@"Server search completed"];
}

-(void)setObject:(id)object withAttribute:(NSString *)attribute{
    [super setObject:object withAttribute:attribute inDatabaseObject:self->databaseObject];
}

-(id)getObjectForAttribute:(NSString *)attribute{
    return [super getObjectForAttribute:attribute inDatabaseObject:self->databaseObject];
}


// MARK: Updates the object and sends the info to the client
-(void)UpdateObjectAndSendToClient{
    
    // Load old patient in global object and save new patient in variable
    NSManagedObject* oldValue = [self loadObjectWithID:[self->databaseObject valueForKey:self->COMMONID]];
    
    NSString* lockedByOlduser = [oldValue valueForKey:ISLOCKEDBY] ;
    
    BOOL isNotLockedUp = (!oldValue || [lockedByOlduser isEqualToString:self->isLockedBy] || lockedByOlduser.length == 0);
    
    if (isNotLockedUp) {
        // save to local database
        [self saveObject:^(id<BaseObjectProtocol> data, NSError *error) {
            if (!data && error) {
                [self sendInformation:nil toClientWithStatus:kError andMessage:error.localizedDescription];
            }else{
                [self sendInformation:[data getDictionaryValuesFromManagedObject] toClientWithStatus:kSuccess andMessage:@"Succesfully updated & synced"];
            }
        }];
    }else{
        
        [self sendInformation:nil toClientWithStatus:kError andMessage:[NSString stringWithFormat:@"This currently being used by %@",lockedByOlduser]];
    }
    
}

-(void)CommonExecution{
    
}



-(void)unpackageFileForUser:(NSDictionary *)data{
   
    if (!data) {
        self->commands = kAbort;
          [self sendInformation:nil toClientWithStatus:kErrorObjectMisconfiguration andMessage:@"Server Error: The object sent was not configured properly"];
        return;
    }
    
    self->commands = [[data objectForKey:OBJECTCOMMAND]intValue];
    
    self->isLockedBy = [data objectForKey:ISLOCKEDBY];
    
    databaseObject = [self CreateANewObjectFromClass:self->COMMONDATABASE isTemporary:YES];
    
    NSError* success = [self setValueToDictionaryValues:[data objectForKey:DATABASEOBJECT]];
   
    // When Clients send information Everything must be saved
    // So if values cannot be added, Abort
    if (success)
    {
        self->commands = kAbort;
        [self sendInformation:nil toClientWithStatus:kErrorObjectMisconfiguration andMessage:success.localizedDescription];
    }
}

-(void)handleCloudCallback:(CloudCallback)callBack UsingData:(NSArray*)data WithPotentialError:(NSError *)error{
  
    NSMutableArray* newObjects = [[NSMutableArray alloc]initWithCapacity:data.count];
    
    if (!error) {
        
        for (NSMutableDictionary* object in data) {
            NSMutableDictionary* unlocked = [NSMutableDictionary dictionaryWithDictionary:object];
            [unlocked setValue:[NSNumber numberWithBool:NO] forKey:ISDIRTY];
            [newObjects addObject:unlocked];
        }
        
        NSArray* allErrors = [self SaveListOfObjectsFromDictionary:newObjects];
        
        if (allErrors.count > 0) {
            
            error = [[NSError alloc]initWithDomain:COMMONDATABASE code:kErrorObjectMisconfiguration userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[allErrors.lastObject description],NSLocalizedDescriptionKey, nil]];
        }
    }
    
    callBack((!error || error.code == kErrorObjectMisconfiguration)?data:nil,error);
}

// MARK: Saves an array of Dictionaries
-(NSArray*)SaveListOfObjectsFromDictionary:(NSArray*)List
{
    NSMutableArray* array = [[NSMutableArray alloc]initWithCapacity:List.count];
    
    // Go through all users in array
    for (NSDictionary* dict in List) {

        //TODO: Revise this section to handle possibility of failure
       NSError* err = [self setValueToDictionaryValues:dict];
        
        if (err) {
            [array addObject:err.localizedDescription];
        }
        
        // Try and save while handling duplication control
        [self saveObject:^(id<BaseObjectProtocol> data, NSError *error) {
            databaseObject = [self CreateANewObjectFromClass:COMMONDATABASE isTemporary:YES];
        }];
    }
    return array;
}

@end
