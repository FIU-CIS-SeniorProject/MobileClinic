//
//  DatabaseDriver.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 2/1/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//
#define OBJECTID          @"objectId"
#import <Foundation/Foundation.h>
#import "Database.h"
#import "DatabaseDriverProtocol.h"

@interface DatabaseDriver : NSObject<DatabaseDriverProtocol>

@property(nonatomic, strong) id<DatabaseProtocol> database;

-(id)init;

-(NSManagedObject*)CreateANewObjectFromClass:(NSString *)name isTemporary:(BOOL)temporary;

-(void)SaveCurrentObjectToDatabase;

-(void)SaveAndRefreshObjectToDatabase:(NSManagedObject*)object;

-(NSArray *)FindObjectInTable:(NSString *)table withCustomPredicate:(NSPredicate *)predicateString andSortByAttribute:(NSString*)attribute;

-(NSArray*)FindObjectInTable:(NSString*)table withName:(id)name forAttribute:(NSString*)attribute;


@end
