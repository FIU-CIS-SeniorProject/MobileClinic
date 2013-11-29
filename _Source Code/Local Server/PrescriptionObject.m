//
//  PrescriptionObject.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 3/11/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import "PrescriptionObject.h"
#import "BaseObject+Protected.h"

#define DATABASE    @"Prescription"
NSString* visitID;
NSString* isLockedBy;
@implementation PrescriptionObject

#pragma mark - BaseObjectProtocol Methods
#pragma mark -

+(NSString *)DatabaseName
{
    return DATABASE;
}

- (id)init
{
    [self setupObject];
    return [super init];
}
-(id)initAndMakeNewDatabaseObject
{
    [self setupObject];
    return [super initAndMakeNewDatabaseObject];
}
- (id)initAndFillWithNewObject:(NSDictionary *)info
{
    [self setupObject];
    return [super initAndFillWithNewObject:info];
}
-(id)initWithCachedObjectWithUpdatedObject:(NSDictionary *)dic
{
    [self setupObject];
    return [super initWithCachedObjectWithUpdatedObject:dic];
}

-(void)setupObject{
    
    self->COMMONID =  PRESCRIPTIONID;
    self->CLASSTYPE = kPrescriptionType;
    self->COMMONDATABASE = DATABASE;
}

-(void)ServerCommand:(NSDictionary *)dataToBeRecieved withOnComplete:(ServerCommand)response{
    [super ServerCommand:nil withOnComplete:response];
    [self unpackageFileForUser:dataToBeRecieved];
    [self CommonExecution];
}

-(void)unpackageFileForUser:(NSDictionary *)data{
    [super unpackageFileForUser:data];
    visitID = [self->databaseObject valueForKey:VISITID];
}


-(void)CommonExecution
{
    switch (self->commands) {
        case kAbort:
            break;
        case kUpdateObject:
            [super UpdateObjectAndSendToClient];
            break;
        case kFindObject:
            [self sendSearchResults:[self FindAllObjectsLocallyFromParentObject]];            break;
        default:
            break;
    }
}

#pragma mark - COMMON OBJECT Methods
#pragma mark -
-(NSArray *)FindAllObjects{
    return [self convertListOfManagedObjectsToListOfDictionaries:[self FindObjectInTable:DATABASE withCustomPredicate:nil andSortByAttribute:PRESCRIBETIME]];
}
-(NSArray *)FindAllObjectsLocallyFromParentObject{
    
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"%K == %@",VISITID,visitID];
    
    return [self convertListOfManagedObjectsToListOfDictionaries:[self FindObjectInTable:DATABASE withCustomPredicate:pred andSortByAttribute:PRESCRIBETIME]];
}

-(NSArray *)FindAllObjectsUnderParentID:(NSString *)parentID{
    visitID = parentID;
    return [self FindAllObjectsLocallyFromParentObject];
}
-(NSAttributedString *)printFormattedObject:(NSDictionary *)object{

    
    NSMutableAttributedString* container = [[NSMutableAttributedString alloc]init];
    /*
    for (NSString* key in object.allKeys) {
        
        NSString* main = [NSString stringWithFormat:@"%@:\n",key];
        
        NSMutableAttributedString* line1 = [[NSMutableAttributedString alloc]initWithString:main];
        
        [line1 addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"HelveticaNeue-Bold" size:16.0] range:[main rangeOfString:main]];
    

        NSString* secondary = [NSString stringWithFormat:@"%@:\n",[[object objectForKey:key] description]];
        
        NSMutableAttributedString* line2 = [[NSMutableAttributedString alloc]initWithString:secondary];
        
        [line2 addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"HelveticaNeue" size:14.0] range:[secondary rangeOfString:secondary]];
        
        [line1 appendAttributedString:line2];
        
        [container appendAttributedString:line1];
    }
    
    return container;
    */
NSString* main = [NSString stringWithFormat:@" Medication Name:\t%@ \n Dose:\t%@ \n Notes:\t%@ \n ",[object objectForKey:MEDNAME],[object objectForKey:TABLEPERDAY],[object objectForKey:INSTRUCTIONS]];
    
    NSMutableAttributedString* line1 = [[NSMutableAttributedString alloc]initWithString:main];
    
    [line1 addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"HelveticaNeue" size:16.0] range:[main rangeOfString:main]];
    
    [container appendAttributedString:line1];
    
    return container;
}
-(NSArray *)covertAllSavedObjectsToJSON{
    
    NSArray* allPatients= [self FindObjectInTable:COMMONDATABASE withCustomPredicate:[NSPredicate predicateWithFormat:@"%K == YES",ISDIRTY] andSortByAttribute:PRESCRIPTIONID];
    NSMutableArray* allObject = [[NSMutableArray alloc]initWithCapacity:allPatients.count];
    
    for (NSManagedObject* obj in allPatients) {
        [allObject addObject:[obj dictionaryWithValuesForKeys:[obj attributeKeys]]];
    }
    return  allObject;
}
@end
