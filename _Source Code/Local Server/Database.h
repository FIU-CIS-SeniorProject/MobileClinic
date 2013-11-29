//
//  Database.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 3/18/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import "DatabaseProtocol.h"
#import <Foundation/Foundation.h>

@interface Database : NSObject<DatabaseProtocol>

/**
 * @brief property for the Persistent Storee Coordinator
 */
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/**
 * @brief property for the Managed Object Model
 */
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;

/**
 * @brief property for the Managed Object Context
 */
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;



@end
