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
//  QueueManager.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 4/21/13.
//
#define ARCHIVER        @"Archive"
#import "QueueManager.h"
#import "BaseObject+Protected.h"

@implementation QueueManager
- (id)init
{
    self = [super init];
    if (self) {
        COMMONID = @"pId";
        COMMONDATABASE = @"Queue";
        
    }
    return self;
}

+(NSData*)ArchiveDictionary:(NSDictionary*)dictionary
{
    //New mutable data object
    NSMutableData *data = [[NSMutableData alloc] init];
    
    //Created an archiver to serialize dictionary into data object
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
    //encodes the dataToBeSent into data object
    [archiver encodeObject:dictionary forKey:ARCHIVER];
    
    //finalize archiving
    [archiver finishEncoding];
    
    return data;
}

-(void)addQueueToDatabase:(Queue *)queue
{
    databaseObject = queue;
    
    [self saveObject:^(id<BaseObjectProtocol> data, NSError *error)
    {
        NSLog(@"Saved a Queue object");
        databaseObject = nil;
    }];
}

-(void)removeQueueObject:(Queue *)queue
{
    [self deleteNSManagedObject:queue];
}

-(void)sendQueObjectToServer:(Queue *)queue andOnComplete:(ObjectResponse)response
{
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:queue.data];
    
    NSDictionary* myDictionary = [unarchiver decodeObjectForKey:ARCHIVER];
    
    [unarchiver finishDecoding];

    [self tryAndSendData:myDictionary withErrorToFire:^(id<BaseObjectProtocol> data, NSError *error)
    {
       response(nil,error);
    }
    andWithPositiveResponse:^(id data)
    {
       response(self,nil);
    }];
}

-(NSArray *)getAllQueuedObjects
{
    return [self FindObjectInTable:COMMONDATABASE withCustomPredicate:nil andSortByAttribute:COMMONID];
}

-(Queue*)getNewQueue
{
    return (Queue*)[self CreateANewObjectFromClass:COMMONDATABASE isTemporary:NO];
}

-(void)sendArrayOfQueuedObjectsToServer:(NSMutableArray *)queuedObjects onCompletion:(ObjectResponse)response{
    
    // If there are objects to send...
    if (queuedObjects.count > 0)
    {
        // Try and send the first object in the queue to the server
        [self sendQueObjectToServer:[queuedObjects objectAtIndex:0] andOnComplete:^(id<BaseObjectProtocol> data, NSError *error)
         {
            // If the object did not make it or some error occurred
            if (!data && error)
            {
                // Return back to the caller and stop
                response(nil,error);
            }
            else
            {
                // Remove the object that was sent 
                [self removeQueueObject:[queuedObjects objectAtIndex:0]];
                [queuedObjects removeObjectAtIndex:0];
                
                // Make a Recursive call till queue is empty
                [self sendArrayOfQueuedObjectsToServer:queuedObjects onCompletion:response];
            }
        }];
    }
    else
    {
        // Otherwise there are no objects to send so go back to caller with no error
        response(self, nil);
    }
}
@end