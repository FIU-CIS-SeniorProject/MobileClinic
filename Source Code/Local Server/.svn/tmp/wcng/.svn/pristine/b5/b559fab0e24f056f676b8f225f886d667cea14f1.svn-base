//
//  DatabaseDriver.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 2/1/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//
#define OBJECTID          @"objectId"
#import <Foundation/Foundation.h>

@interface DatabaseDriver : NSObject {
    NSManagedObject* databaseObject;
}

@property(nonatomic, strong) NSManagedObjectID* objID;


-(id)init;
-(BOOL)FindDataBaseObjectWithID;
-(void)addObjectToDatabaseObject:(id)obj forKey:(NSString*)key;
-(id)getValueForKey:(NSString*)key;
-(BOOL)CreateANewObjectFromClass:(NSString *)name;
-(void)SaveCurrentObjectToDatabase;
-(NSArray*)getListFromTable:(NSString*)tableName sortByAttr:(NSString*)sortAttr;
-(NSArray*)FindObjectInTable:(NSString*)table withName:(id)name forAttribute:(NSString*)attribute;
@end
