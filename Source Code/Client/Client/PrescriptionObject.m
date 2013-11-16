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
//  PrescriptionObject.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 2/25/13.
//
#define VISITID         @"visitationId"
#define DATABASE    @"Prescription"

#import "PrescriptionObject.h"
#import "BaseObject+Protected.h"

@implementation PrescriptionObject

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
    self->COMMONID =  PRESCRIPTIONID;
    self->CLASSTYPE = kPrescriptionType;
    self->COMMONDATABASE = DATABASE;
}

#pragma mark- Public Methods
#pragma mark-

-(void)associateObjectToItsSuperParent:(NSDictionary *)parent
{
    NSString* vId = [parent objectForKey:VISITID];
    [self->databaseObject setValue:[NSString stringWithFormat:@"%@_%f",vId,[[NSDate date]timeIntervalSince1970]] forKey:PRESCRIPTIONID];
    [self->databaseObject setValue:vId forKey:VISITID];
}

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
    
    // Check for main ID's
    if (![self->databaseObject valueForKey:VISITID] || ![self->databaseObject valueForKey:PRESCRIPTIONID])
    {
        onSuccessHandler(nil,[self createErrorWithDescription:@"Developer Error: Please set visitationID and patientID" andErrorCodeNumber:kErrorObjectMisconfiguration inDomain:@"Visitation Object"]);
        return;
    }
    
    [super UpdateObject:onSuccessHandler shouldLock:NO andSendObjects:[self getDictionaryValuesFromManagedObject] withInstruction:kUpdateObject];
}

-(NSArray *)FindAllObjectsLocally
{
    return [self convertListOfManagedObjectsToListOfDictionaries:[self FindObjectInTable:DATABASE withCustomPredicate:nil andSortByAttribute:PRESCRIPTIONID]];
}

-(NSArray *)FindAllObjectsLocallyFromParentObject:(NSDictionary*)parentObject
{
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"%K == %@",VISITID,[parentObject objectForKey:VISITID]];
   return [self convertListOfManagedObjectsToListOfDictionaries:[self FindObjectInTable:self->COMMONDATABASE withCustomPredicate:pred andSortByAttribute:self->COMMONID]];
}

-(void)FindAllObjectsOnServerFromParentObject:(NSDictionary*)parentObject OnCompletion:(ObjectResponse)eventResponse
{
    NSMutableDictionary* query = [[NSMutableDictionary alloc]initWithCapacity:4];
    [query setValue:[parentObject objectForKey:VISITID] forKey:VISITID];
    [self startSearchWithData:query withsearchType:kFindObject andOnComplete:eventResponse];
}
@end