// The MIT License (MIT)
//
// Copyright (c) 2013 Florida International University
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//  VisitationObject.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 2/11/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//
#define DATABASE    @"Visitation"
#define ALLVISITS   @"all visits"

#import "VisitationObject.h"
#import "BaseObject+Protected.h"
#import "Visitation.h"
@implementation VisitationObject

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

-(void)setupObject
{
    self->COMMONID =  VISITID;
    self->CLASSTYPE = kVisitationType;
    self->COMMONDATABASE = DATABASE;
}

#pragma mark- Private Methods
#pragma mark-

-(void)UpdateObjectAndShouldLock:(BOOL)shouldLock witData:(NSMutableDictionary *)dataToSend AndInstructions:(NSInteger)instruction onCompletion:(ObjectResponse)response
{
    [self UpdateObject:response shouldLock:shouldLock andSendObjects:dataToSend withInstruction:instruction];
}

-(void)createNewObject:(NSDictionary*) object onCompletion:(ObjectResponse)onSuccessHandler
{
    if (![self setValueToDictionaryValues:object])
    {
        onSuccessHandler(nil,[self createErrorWithDescription:@"Developer Error: Misconfigured Object" andErrorCodeNumber:kErrorObjectMisconfiguration inDomain:@"Visistation Object"]);
        return;
    }
    
    // Check for patientID and returns an error if there's none
    if (![self->databaseObject valueForKey:VISITID] || ![self->databaseObject valueForKey:PATIENTID])
    {
        onSuccessHandler(nil,[self createErrorWithDescription:@"Developer Error: Please set visitationID  and patientID" andErrorCodeNumber:kErrorObjectMisconfiguration inDomain:self->COMMONDATABASE]);
        return;
    }
    // Gets all open visits and narrows visits to a specific patient
    NSArray* localVisit = [[self FindAllOpenVisitsLocally]filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K == %@",PATIENTID,[self->databaseObject valueForKey:PATIENTID]]];
    
    if (localVisit.count <= 1 )
    {
         [super UpdateObject:onSuccessHandler shouldLock:NO andSendObjects:[self getDictionaryValuesFromManagedObject] withInstruction:kConditionalCreate];
    }
    else
    {
        [self deleteCurrentlyHeldObjectFromDatabase];
        onSuccessHandler(nil,[self createErrorWithDescription:MULTIPLE_VISIT_ERROR andErrorCodeNumber:kError inDomain:self->COMMONDATABASE]);
    }
}

-(NSArray *)FindAllObjectsLocallyFromParentObject:(NSDictionary*)parentObject
{
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"%K == %@",PATIENTID,[parentObject objectForKey:PATIENTID]];
    
    return [self convertListOfManagedObjectsToListOfDictionaries: [self FindObjectInTable:DATABASE withCustomPredicate:pred andSortByAttribute:PATIENTID]];
}

-(void)FindAllObjectsOnServerFromParentObject:(NSDictionary*)parentObject OnCompletion:(ObjectResponse)eventResponse
{
    NSMutableDictionary* query = [[NSMutableDictionary alloc]initWithCapacity:4];
    [query setValue:[parentObject objectForKey:PATIENTID] forKey:PATIENTID];
    [self startSearchWithData:query withsearchType:kFindObject andOnComplete:eventResponse];
}

-(void)linkVisit
{
    visit = (Visitation*)self->databaseObject;
}

#pragma mark- Public Methods
#pragma mark-

-(void)associateObjectToItsSuperParent:(NSDictionary *)parent
{
    [self linkVisit];
    NSString* pId = [parent objectForKey:PATIENTID];
    [visit setVisitationId:[NSString stringWithFormat:@"%@_%f",pId,[[NSDate date]timeIntervalSince1970]]];
    [visit setPatientId:pId];
}

-(BOOL)shouldSetCurrentVisitToOpen:(BOOL)shouldOpen
{
    BOOL isAlreadyOpen = ([[self->databaseObject valueForKey:ISOPEN]boolValue]);
    
    if (isAlreadyOpen)
    {
        return NO;
    }
    
    [self->databaseObject setValue:[NSNumber numberWithBool:shouldOpen] forKey:ISOPEN];
    
    return YES;
}

-(void) SyncAllOpenVisitsOnServer:(ObjectResponse)Response
{
   [self startSearchWithData:[[NSDictionary alloc]init] withsearchType:kFindOpenObjects andOnComplete:Response];
}

-(NSArray*)FindAllOpenVisitsLocally
{
   //Predicate to return list of Open Objects
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"isOpen == TRUE"];
    
    return [self convertListOfManagedObjectsToListOfDictionaries:[self FindObjectInTable:DATABASE withCustomPredicate:pred andSortByAttribute:TRIAGEIN]];
}
@end