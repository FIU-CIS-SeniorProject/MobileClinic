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

+(NSData*) ArchiveDictionary:(NSDictionary*) dictionary;
-(void) addQueueToDatabase:(Queue*) queue;
-(void) removeQueueObject:(Queue*) queue;
-(void) sendQueObjectToServer:(Queue*) queue andOnComplete:(ObjectResponse) response;
-(NSArray*)getAllQueuedObjects;
-(Queue*)getNewQueue;
-(void)sendArrayOfQueuedObjectsToServer:(NSMutableArray *)queuedObjects onCompletion:(ObjectResponse)response;
@end
