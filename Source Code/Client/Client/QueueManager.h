//
//  QueueManager.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 4/21/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
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
