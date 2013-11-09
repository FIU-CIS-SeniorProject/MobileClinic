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
//  MedicationObject.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 3/11/13.
//
#define DATABASE    @"Medication"

#import "MedicationObject.h"
#import "BaseObject+Protected.h"

@implementation MedicationObject

#pragma mark- DATABASE PROTOCOL OVERIDES
#pragma mark-

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

#pragma mark- PRIVATE METHODS
#pragma mark-

+(NSString *)DatabaseName
{
    return DATABASE;
}

-(void)setupObject
{
    self->COMMONID =  MEDICATIONID;
    self->CLASSTYPE = kMedicationType;
    self->COMMONDATABASE = DATABASE;
}

#pragma mark- COMMON PROTOCOL METHODS
#pragma mark-

-(void)UpdateObjectAndShouldLock:(BOOL)shouldLock witData:(NSMutableDictionary *)dataToSend AndInstructions:(NSInteger)instruction onCompletion:(ObjectResponse)response
{
    NSLog(@"Does not need to be implemented");
}

-(void)createNewObject:(NSDictionary*) object onCompletion:(ObjectResponse)onSuccessHandler
{
    NSLog(@"Does not need to be implemented");
}

-(void)associateObjectToItsSuperParent:(NSDictionary *)parent
{
    NSLog(@"Does not need to be implemented");
}

-(NSArray *)FindAllObjectsLocallyFromParentObject:(NSDictionary *)parentObject
{
    return [self convertListOfManagedObjectsToListOfDictionaries:[self FindObjectInTable:DATABASE withCustomPredicate:nil andSortByAttribute:self->COMMONID]];
}

-(void)FindAllObjectsOnServerFromParentObject:(NSDictionary*)parentObject OnCompletion:(ObjectResponse)eventResponse{
 
    [self startSearchWithData:parentObject withsearchType:kFindObject andOnComplete:eventResponse];
}
@end