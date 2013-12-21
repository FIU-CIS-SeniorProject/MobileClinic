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
//  QueueManager.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 4/21/13.
//
#import <Foundation/Foundation.h>
#import "Queue.h"
#import "BaseObject.h"

@interface QueueManager : BaseObject
/* The queue is responsible for caching objects that could not go to the server. If for some reason the server was unable to process the clients commands, then the client will use the queuemanager to place the items in Line.
 * On the Dashboard interface any patient that has pending commands/actions will show in the tableview.
 * This class also has the power to send all the pending information to the server all at once in a massive dump.
 * Any command that does not make it will remain in the queue.
 */

// Convenience Class method to archive data to be sent transfered
+(NSData*) ArchiveDictionary:(NSDictionary*) dictionary;

// caches the object to database 
-(void) addQueueToDatabase:(Queue*) queue;

// Deletes the cached object from database
-(void) removeQueueObject:(Queue*) queue;

// Tries to send the queued object over to the server
-(void) sendQueObjectToServer:(Queue*) queue andOnComplete:(ObjectResponse) response;

// Finds all the cached objects that needs to be sent over
-(NSArray*)getAllQueuedObjects;

// Creates a new cached object in the database
-(Queue*)getNewQueue;

// Tries to send an array of cached objects
-(void)sendArrayOfQueuedObjectsToServer:(NSMutableArray *)queuedObjects onCompletion:(ObjectResponse)response;
@end