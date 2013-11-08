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
//  BaseObject+Protected.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 3/21/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import "BaseObject+Protected.h"
#import "ServerCore.h"
#import "QueueManager.h"
id<ServerProtocol> serverManager;

@implementation BaseObject (Protected)

-(void)SendData:(NSDictionary *)data toServerWithErrorMessage:(NSString *)msg andResponse:(ObjectResponse)Response
{
    [self tryAndSendData:data withErrorToFire:^(id<BaseObjectProtocol> data, NSError *error)
    {
        Response(nil, error);
    }
    andWithPositiveResponse:^(id data)
    {
        StatusObject* status = data;
        [self SaveListOfObjectsFromDictionary:status.data];
        Response((status.status == kSuccess)?self:nil, [self createErrorWithDescription:status.errorMessage andErrorCodeNumber:status.status inDomain:self->COMMONDATABASE]);
    }];
}

-(void)tryAndSendData:(NSDictionary*)data withErrorToFire:(ObjectResponse)negativeResponse andWithPositiveResponse:(ServerCallback)posResponse
{
    if (!serverManager)
    {
        serverManager = [ServerCore sharedInstance];
    }
    
    if (![serverManager isClientConntectToServer] || ([serverManager isClientConntectToServer] && ![serverManager isProcessing]))
    {
        [serverManager setConnectionStatusHandler:^(BOOL isConnected, NSError* errorMessage)
        {
            if (isConnected)
            {
                [serverManager sendData:data withOnComplete:posResponse];
            }
            else
            {
                negativeResponse(nil,errorMessage);
            }
        }];
            
        [serverManager startClient];
    }
}

-(void)startSearchWithData:(NSDictionary*)data withsearchType:(RemoteCommands)rCommand andOnComplete:(ObjectResponse)response
{
    NSMutableDictionary* dataToSend = [[NSMutableDictionary alloc]initWithCapacity:3];
    [dataToSend setValue:data forKey:DATABASEOBJECT];
    [dataToSend setValue:[NSNumber numberWithInt:self->CLASSTYPE] forKey:OBJECTTYPE];
    [dataToSend setValue:[NSNumber numberWithInt:rCommand] forKey:OBJECTCOMMAND];
    
    [self SendData:dataToSend toServerWithErrorMessage:DATABASE_ERROR_MESSAGE andResponse:response];
}

-(void)SaveListOfObjectsFromDictionary:(NSDictionary*)patientList
{
    // get all the users returned from server
    NSArray* arr = [patientList objectForKey:ALLITEMS];
    
    // Go through all users in array
    for (NSDictionary* dict in arr)
    {
        // Try and find previously existing value
        if(![self loadObjectForID:[dict objectForKey:self->COMMONID]])
        {
            self->databaseObject = [self CreateANewObjectFromClass:self->COMMONDATABASE isTemporary:NO];
        }
       
        BOOL success = [self setValueToDictionaryValues:dict];
       
        if (success)
        {
            // Try and save while handling duplication control
            [self saveObject:^(id<BaseObjectProtocol> data, NSError *error)
            {
            
            }];
        }
        else
        {
            
        }
    }
}

-(NSMutableArray*)convertListOfManagedObjectsToListOfDictionaries:(NSArray*)managedObjects
{
    NSMutableArray* arrayWithDictionaries = [[NSMutableArray alloc]initWithCapacity:managedObjects.count];
    
    for (NSManagedObject* objs in managedObjects)
    {
        [arrayWithDictionaries addObject:[self getDictionaryValuesFromManagedObject:objs]];
    }
    return arrayWithDictionaries;
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

-(void)UpdateObject:(ObjectResponse)response shouldLock:(BOOL)shouldLock andSendObjects:(NSMutableDictionary*)dataToSend withInstruction:(NSInteger)instruction
{
    // Set/Clear the lock on the object
    NSMutableDictionary* container = [NSMutableDictionary dictionaryWithCapacity:3];
    
    NSString* lock = (shouldLock)?[BaseObject getCurrenUserName]:@"";
    
    //So the reciever knows who sent this data
    [container setValue:[BaseObject getCurrenUserName] forKey:ISLOCKEDBY];
    
    // determines whether or not object is locked
    [dataToSend setValue:lock forKey:ISLOCKEDBY];
    
    // Mark as dirty so server knows to save this to the cloud
    [dataToSend setValue:[NSNumber numberWithBool:YES] forKey:ISDIRTY];
    
    // Place the DataObject inside a dictionary
    [container setValue:dataToSend forKey:DATABASEOBJECT];
    
    // Add instructions
    [container setValue:[NSNumber numberWithInteger:instruction] forKey:OBJECTCOMMAND];
    
    // Add the object Type
    [container setValue:[NSNumber numberWithInteger:self->CLASSTYPE] forKey:OBJECTTYPE];
    
    // Try to send information to the server
    [self tryAndSendData:container withErrorToFire:^(id<BaseObjectProtocol> data, NSError *error)
    {
        // Make sure that the object is attached to this object
        if([self setValueToDictionaryValues:dataToSend])
        {
            // Create New Queue Manager
            QueueManager* qm = [[QueueManager alloc]init];
            // Create a new Queue Object
            Queue* queue = [qm getNewQueue];
            // Add Primary Key ID
            [queue setPId:[container objectForKey:COMMONID]];
            // Add Database name for the title
            [queue setTitle:COMMONDATABASE];
            // Archive and add data to be sent to the server
            [queue setData:[QueueManager ArchiveDictionary:container]];
            // Add and save the object to the database
            [qm addQueueToDatabase:queue];
            
            // Save current information if cannot connect
            [self saveObject:^(id<BaseObjectProtocol> data, NSError *noError)
            {
                response(data,error);
            }];
        }
        else
        {
            response(nil,[self createErrorWithDescription:@"Developer Error: Misconfigured Object" andErrorCodeNumber:kErrorObjectMisconfiguration inDomain:@"BaseObject + Protected"]);
            return;
        }
    } andWithPositiveResponse:^(id PosData)
    {
        // Cast Status Object
        StatusObject* status = PosData;
        if (status.status > kSuccess)
        {
            //delete Values if there was an error
            [self deleteCurrentlyHeldObjectFromDatabase];
            response(nil,[self createErrorWithDescription:status.errorMessage andErrorCodeNumber:status.status inDomain:@"BaseObject"]);
        }
        else if (status.status == kSuccess)
        {
            // Save object to this device
            if([self setValueToDictionaryValues:status.data])
            {
            [self saveObject:^(id<BaseObjectProtocol> data, NSError *error)
                {
                    response(self,[self createErrorWithDescription:status.errorMessage andErrorCodeNumber:kSuccess inDomain:@"BaseObject"]);
                }];
            }
            else
            {
                response(nil,[self createErrorWithDescription:@"Developer Error: Misconfigured Object" andErrorCodeNumber:kErrorObjectMisconfiguration inDomain:@"BaseObject + Protected"]);
            }
        }
    }];
}

- (BOOL)isConnectedToServer
{
    if (!serverManager)
    {
        serverManager = [ServerCore sharedInstance];
    }
    
    return [serverManager isClientConntectToServer];
}
@end