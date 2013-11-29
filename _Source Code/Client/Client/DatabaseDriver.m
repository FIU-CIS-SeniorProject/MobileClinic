//
//  DatabaseDriver.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 2/1/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import "DatabaseDriver.h"

NSManagedObjectContext* context;
@implementation DatabaseDriver

@synthesize database;

-(id)init{
    if (self = [super init]) {
        //appDelegate = (FIUAppDelegate*)[[UIApplication sharedApplication]delegate];
        database = [Database sharedInstance];
        context = database.managedObjectContext;
    }
return self;
}

-(BOOL)deleteObjectFromDatabase:(NSString *)table withDefiningAttribute:(NSString *)attrib forKey:(NSString *)key{

    if (!table || !key || !attrib) {
        return NO;
    }
    
    NSArray* objects = [self FindObjectInTable:table withName:attrib forAttribute:key];
   
    for (NSManagedObject* obj in objects) {
        [context deleteObject:obj];
    }
        NSError* error = nil;
        return ![context save:&error];
}

-(BOOL)deleteNSManagedObject:(NSManagedObject *)object{
   
    if (object) {
        [context deleteObject:object];
        NSError* error = nil;
        return ![context save:&error];
    }
return NO;
}

-(NSArray*)FindObjectInTable:(NSString*)table withName:(NSString*)name forAttribute:(NSString*)attribute{
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc]init];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:attribute ascending:YES];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetch setSortDescriptors:sortDescriptors];
    
    
    if (name.length > 0) {
        NSPredicate* pred = [NSPredicate predicateWithFormat:@"%K contains[cd] %@",attribute,name];
        [fetch setPredicate:pred];
    }
    
    return [self fetchElementsUsingFetchRequest:fetch withTable:table];

}

-(NSManagedObject*)CreateANewObjectFromClass:(NSString *)name isTemporary:(BOOL)temporary{
    if (name.length > 0) {
        NSEntityDescription *entity = [NSEntityDescription entityForName:name inManagedObjectContext:context];
        return [[NSManagedObject alloc]initWithEntity:entity insertIntoManagedObjectContext:(temporary)?nil:context];
    }
    return nil;
}

-(void)SaveCurrentObjectToDatabase{
    [database saveContext];
}

-(void)SaveAndRefreshObjectToDatabase:(NSManagedObject *)object{
    [self SaveCurrentObjectToDatabase];
    [context refreshObject:object mergeChanges:YES];
}

-(NSArray *)FindObjectInTable:(NSString *)table withCustomPredicate:(NSPredicate *)predicateString andSortByAttribute:(NSString*)attribute{

    NSFetchRequest *fetch = [[NSFetchRequest alloc]init];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:attribute ascending:YES];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetch setSortDescriptors:sortDescriptors];
   
    if (predicateString) {
        [fetch setPredicate:predicateString];
    }
    
    return [self fetchElementsUsingFetchRequest:fetch withTable:table];
}

-(NSArray*)fetchElementsUsingFetchRequest:(NSFetchRequest*)request withTable:(NSString*)tableName{
    
    if (context) {
        NSEntityDescription* semesterEntity = [NSEntityDescription entityForName:tableName inManagedObjectContext: context];

        [request setEntity:semesterEntity];
        
        [request setFetchBatchSize:15];
        
        NSError *error  = nil;
        
        NSArray*  temp = [NSArray arrayWithArray: [context executeFetchRequest:request error:&error]];
        
        if (error) {
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
