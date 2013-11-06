//
//  Database.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 3/12/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <Foundation/Foundation.h> 
#import "DatabaseProtocol.h"
#import "ServerProtocol.h"



@interface Database : NSObject<DatabaseProtocol>{
}

@property (strong, nonatomic) id<ServerProtocol> ServerManager;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (id)sharedInstance;

@end
