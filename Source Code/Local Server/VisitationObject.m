//
//  VisitationObject.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 2/11/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//


#import "VisitationObject.h"
#import "UserObject.h"
#import "StatusObject.h"
#import "Visitation.h"
#import "BaseObject+Protected.h"
#import "FIUAppDelegate.h"
#import "CloudManagementObject.h"

#define DATABASE    @"Visitations"
NSString* patientID;
NSString* isLockedBy;
@implementation VisitationObject

+(NSString *)DatabaseName{
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

-(void)setupObject
{
    self->COMMONID =  VISITID;
    self->CLASSTYPE = kVisitationType;
    self->COMMONDATABASE = DATABASE;
}

-(void)ServerCommand:(NSDictionary *)dataToBeRecieved withOnComplete:(ServerCommand)response
{
    [super ServerCommand:nil withOnComplete:response];
    [self unpackageFileForUser:dataToBeRecieved];
    [self CommonExecution];
}

-(void)unpackageFileForUser:(NSDictionary *)data{
    [super unpackageFileForUser:data];
    patientID = [self->databaseObject valueForKey:PATIENTID];
}


-(void)CommonExecution
{
    switch (self->commands) {
        case kAbort:
            break;
        case kUpdateObject:
            [super UpdateObjectAndSendToClient];
            break;
        case kConditionalCreate:
            [self checkForExisitingOpenVisit];
            break;
        case kFindObject:
            [self sendSearchResults:[self FindAllObjectsLocallyFromParentObject]];
            break;
        case kFindOpenObjects:
            [self sendSearchResults:[self OptimizedFindAllObjects]];
            break;
        default:
            break;
    }
}
#pragma mark - COMMON OBJECT Methods
#pragma mark -
-(NSArray*)OptimizedFindAllObjects{
    
    FIUAppDelegate* app = (FIUAppDelegate*)[[NSApplication sharedApplication]delegate];
    
    switch ([app isOptimized]) {
        case kFirstSync:
            return [self FindAllObjects];
        case kFastSync:
            return [self FindAllPatientsWithinMinutes];
        case kStabilize:
        case kFinalize:
            return [self FindAllOpenVisits];
    }

}
-(NSArray*)FindAllPatientsWithinMinutes{
    
    NSDate* aDayPrior = [[NSDate alloc] initWithTimeInterval:-60*15 sinceDate:[NSDate date]];
   
    NSNumber* hoursBefore = [NSNumber numberWithInteger:[aDayPrior timeIntervalSince1970]];
    
    return [self convertListOfManagedObjectsToListOfDictionaries:[self FindObjectInTable:DATABASE withCustomPredicate:[NSPredicate predicateWithFormat:@"%K == YES && %K >= %@",ISDIRTY,TRIAGEOUT,hoursBefore] andSortByAttribute:TRIAGEOUT]];
}

-(NSArray*)FindAllDirtyVisits{
    return [self convertListOfManagedObjectsToListOfDictionaries:[self FindObjectInTable:DATABASE withCustomPredicate:[NSPredicate predicateWithFormat:@"%K >= %@",ISDIRTY,YES] andSortByAttribute:TRIAGEIN]];
}

-(void)checkForExisitingOpenVisit{
    NSArray* allVisits = [self FindAllOpenVisits];
    
    NSArray* filtered = [allVisits filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K == %@",PATIENTID,patientID]];
   
    if (filtered.count <= 1) {
        [super UpdateObjectAndSendToClient];
    }
    else
    {
        [super sendInformation:nil toClientWithStatus:kError andMessage:@"This Patient already has an open visit"];
    }
}
-(NSArray *)FindAllObjectsLocallyFromParentObject{
    
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"%K == %@",PATIENTID,patientID];
    return [self convertListOfManagedObjectsToListOfDictionaries:[self FindObjectInTable:DATABASE withCustomPredicate:pred andSortByAttribute:TRIAGEIN]];
}

-(NSArray *)FindAllObjectsUnderParentID:(NSString *)parentID{
    patientID = parentID;
    return [self FindAllObjectsLocallyFromParentObject];
}

-(NSAttributedString *)printFormattedObject:(NSDictionary *)object{

    NSString* titleString = [NSString stringWithFormat:@"\n\nVisitation Information\n"];
    
    NSMutableAttributedString* title = [[NSMutableAttributedString alloc]initWithString:titleString];
    
    [title addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Gill Sans" size:22.0] range:[titleString rangeOfString:titleString]];
    
    
    NSMutableAttributedString* container = [[NSMutableAttributedString alloc]initWithAttributedString:title];

    
    NSString* main = [NSString stringWithFormat:@"Blood Pressure:\t%@ \n Heart Rate:\t%@ \n Respiration:\t%@ \n Weight:\t%@ \n Chief Complaint:\t%@ \n Diagnosis:\t%@ \nAssessment:\t%@ \nTriage In:\t%@ \n Triage Out:\t%@ \n Doctor In:\t%@ \n Doctor Out:\t%@ \nAdditional Medical Notes:\t%@ \n\n",[self convertTextForPrinting:[object objectForKey:BLOODPRESSURE]],[self convertTextForPrinting:[object objectForKey:HEARTRATE]],[self convertTextForPrinting:[object objectForKey:RESPIRATION]],[object objectForKey:WEIGHT],[self convertTextForPrinting:[object objectForKey:CONDITIONTITLE]],[self convertTextForPrinting:[object objectForKey:OBSERVATION]],[self convertTextForPrinting:[object objectForKey:ASSESSMENT]],[self convertDateNumberForPrinting:[object objectForKey:TRIAGEIN]],[self convertDateNumberForPrinting:[object objectForKey:TRIAGEOUT]],[self convertDateNumberForPrinting:[object objectForKey:DOCTORIN]],[self convertDateNumberForPrinting:[object objectForKey:DOCTOROUT]],[self convertTextForPrinting:[object objectForKey:MEDICATIONNOTES]]];
    
    NSMutableAttributedString* line1 = [[NSMutableAttributedString alloc]initWithString:main];
    
    [line1 addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"HelveticaNeue" size:16.0] range:[main rangeOfString:main]];
    
    [container appendAttributedString:line1];
    
    return container;
}
-(NSString*)convertDateNumberForPrinting:(NSNumber*)number
{
    if (number)
    {
        return [[NSDate convertSecondsToNSDate:number]convertNSDateToMonthDayYearTimeString];
    }
    return @"N/A";
}

-(NSString*)convertTextForPrinting:(NSString*)text
{
    return ([text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0)?text:@"Incomplete";
}

-(NSArray *)FindAllObjects
{
    return [self convertListOfManagedObjectsToListOfDictionaries:[self FindObjectInTable:DATABASE withCustomPredicate:nil andSortByAttribute:TRIAGEIN]];
}

-(void)UnlockVisit:(ObjectResponse)onComplete{
    [self setObject:@"" withAttribute:ISLOCKEDBY];
    [self saveObject:onComplete];
}
#pragma mark - Private Methods
#pragma mark-

-(NSArray*)FindAllOpenVisits{
    
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"%K == YES",ISOPEN];
    
    return [self convertListOfManagedObjectsToListOfDictionaries:[self FindObjectInTable:DATABASE withCustomPredicate:pred andSortByAttribute:TRIAGEIN]];
}

-(NSArray *)covertAllSavedObjectsToJSON{
    
    NSArray* allPatients= [self FindObjectInTable:COMMONDATABASE withCustomPredicate:[NSPredicate predicateWithFormat:@"%K == YES",ISDIRTY] andSortByAttribute:VISITID];
    NSMutableArray* allObject = [[NSMutableArray alloc]initWithCapacity:allPatients.count];
    
    for (NSManagedObject* obj in allPatients) {
        [allObject addObject:[obj dictionaryWithValuesForKeys:[obj attributeKeys]]];
    }
    return  allObject;
}

-(void)pushToCloud:(CloudCallback)onComplete
{
    NSArray* allVisits= [self convertListOfManagedObjectsToListOfDictionaries:[self FindObjectInTable:COMMONDATABASE withCustomPredicate:[NSPredicate predicateWithFormat:@"%K == YES",ISDIRTY] andSortByAttribute:VISITID]];
    
    [self makeCloudCallWithCommand:UPDATEVISIT withObject:[NSDictionary dictionaryWithObject:allVisits forKey:DATABASE] onComplete:^(id cloudResults, NSError *error)
     {
         [self handleCloudCallback:onComplete UsingData:allVisits WithPotentialError:error];
     }];
}

-(void)pullFromCloud:(CloudCallback)onComplete
{
    // allocate and init a CloudManagementObject for timestamp
    CloudManagementObject* TSCloudMO = [[CloudManagementObject alloc] init];
    NSNumber* timestamp = [TSCloudMO GetActiveTimestamp];
    NSMutableDictionary* timeDic = [[NSMutableDictionary alloc] init];
    [timeDic setObject:timestamp forKey:@"Timestamp"];
    
    //TODO: replace "withObject:nil" with timestamp dictionary
    [self makeCloudCallWithCommand:DATABASE withObject:timeDic onComplete:^(id cloudResults, NSError *error)
     {
         NSArray* allVisits = [cloudResults objectForKey:@"data"];
         [self handleCloudCallback:onComplete UsingData:allVisits WithPotentialError:error];
     }];
}

@end
