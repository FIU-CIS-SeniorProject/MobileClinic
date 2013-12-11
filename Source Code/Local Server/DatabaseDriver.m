//
//  DatabaseDriver.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 2/1/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import "DatabaseDriver.h"
#import "Database.h"
NSManagedObjectContext* context;
@implementation DatabaseDriver

-(id)init{
    if (self = [super init]) {
        database = [Database sharedInstance];
        context = [database managedObjectContext];
    }
return self;
}


-(id)getValueForKey:(NSString *)key FromObject:(NSManagedObject*)databaseObject{
   return [databaseObject valueForKey:key];
}

-(BOOL)deleteNSManagedObject:(NSManagedObject *)object{
    
    if (object) {
        [context deleteObject:object];
        NSError* error = nil;
        return ![context save:&error];
    }
    return NO;
}

-(BOOL)deleteObjectsFromDatabase:(NSString *)table withDefiningAttribute:(NSString *)attrib forKey:(NSString *)key{
    
    if (!table || !key || !attrib) {
        return NO;
    }
    
    NSArray* objects = [self FindObjectInTable:table withName:attrib forAttribute:key];
    
    for (NSManagedObject* object in objects) {
        [context deleteObject:object];
    }
    
    NSError* error = nil;
    return ![context save:&error];
}

-(NSManagedObject*)CreateANewObjectFromClass:(NSString *)name isTemporary:(BOOL)temp{
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:name inManagedObjectContext:database.managedObjectContext];
   
    return [[NSManagedObject alloc]initWithEntity:entity insertIntoManagedObjectContext:(temp)?nil:database.managedObjectContext];

}

-(void)SaveCurrentObjectToDatabase:(NSManagedObject*)databaseObject{
    [database saveContext];
    [database.managedObjectContext refreshObject:databaseObject mergeChanges:YES];
}


-(NSArray*)FindObjectInTable:(NSString*)table withName:(NSString*)name forAttribute:(NSString*)attribute{
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc]init];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:attribute ascending:YES];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetch setSortDescriptors:sortDescriptors];
    
    
    if (name.length > 3) {
        NSPredicate* pred = [NSPredicate predicateWithFormat:@"%K contains[cd] %@",attribute,name];
        [fetch setPredicate:pred];
    }
    return [self fetchElementsUsingFetchRequest:fetch withTable:table];
}

-(NSArray *)FindObjectInTable:(NSString *)table withCustomPredicate:(NSPredicate *)predicateString andSortByAttribute:(NSString*)attribute{
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc]init];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:attribute ascending:YES];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetch setSortDescriptors:sortDescriptors];
    
    if (predicateString)
    {
        [fetch setPredicate:predicateString];
    }
    
    return [self fetchElementsUsingFetchRequest:fetch withTable:table];
}


-(NSArray*)fetchElementsUsingFetchRequest:(NSFetchRequest*)request withTable:(NSString*)tableName
{
    NSManagedObjectContext* ctx = database.managedObjectContext;
    
    if (ctx)
    {
        NSEntityDescription* semesterEntity = [NSEntityDescription entityForName:tableName inManagedObjectContext: ctx];
        [request setEntity:semesterEntity];
        [request setFetchBatchSize:15];
        
        NSError *error  = nil;
        
        NSArray*  temp = [NSArray arrayWithArray: [ctx executeFetchRequest:request error:&error]];
        
        if (error)
        {
            NSLog(@"ERROR: DATAMODEL COULD NOT FETCH");
            return nil;
        }
        return temp;
    }
    return nil;
}

-(void)setObject:(id)object withAttribute:(NSString*)attribute inDatabaseObject:(NSManagedObject*)DBObject{
    [DBObject setValue:object forKey:attribute];
}
-(id)getObjectForAttribute:(NSString*)attribute inDatabaseObject:(NSManagedObject*)DBObject{
    return [DBObject valueForKey:attribute];
}
@end
