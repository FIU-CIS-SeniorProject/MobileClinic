// The MIT License (MIT)//// Copyright (c) 2013 Florida International University//// Permission is hereby granted, free of charge, to any person obtaining a copy// of this software and associated documentation files (the "Software"), to deal// in the Software without restriction, including without limitation the rights// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell// copies of the Software, and to permit persons to whom the Software is// furnished to do so, subject to the following conditions://// The above copyright notice and this permission notice shall be included in// all copies or substantial portions of the Software.//// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN// THE SOFTWARE.////  PatientObject.m//  Mobile Clinic////  Created by Steven Berlanga on 2/4/13.//  Copyright (c) 2013 Steven Berlanga. All rights reserved.//#define PATIENTID   @"patientId"#define ALLPATIENTS @"all patients"#define DATABASE    @"Patients"#import "BaseObject+Protected.h"#import "PatientObject.h"#import "VisitationObject.h"#import "Patients.h"#import "UIImage+ImageVerification.h"StatusObject* tempStatusObject;Patients* patient;VisitationObject* currentVisit;@implementation PatientObject+(NSString*)DatabaseName{    return DATABASE;}#pragma mark- Base Protocol Methods Overide#pragma mark-- (id)init{    [self setupObject];    return [super init];}-(id)initAndMakeNewDatabaseObject{     [self setupObject];    return [super initAndMakeNewDatabaseObject];}- (id)initAndFillWithNewObject:(NSDictionary *)info{     [self setupObject];    return [super initAndFillWithNewObject:info];}-(id)initWithCachedObjectWithUpdatedObject:(NSDictionary *)dic{    [self setupObject];    return [super initWithCachedObjectWithUpdatedObject:dic];}-(void)setupObject{    self->COMMONID =  PATIENTID;    self->CLASSTYPE = kPatientType;    self->COMMONDATABASE = DATABASE;}-(void)UpdateObjectAndShouldLock:(BOOL)shouldLock witData:(NSMutableDictionary *)dataToSend AndInstructions:(NSInteger)instruction onCompletion:(ObjectResponse)response{    [self UpdateObject:response shouldLock:shouldLock andSendObjects:dataToSend withInstruction:instruction];}#pragma mark- Public Methods#pragma mark--(void)createNewObject:(NSDictionary*) object onCompletion:(ObjectResponse)onSuccessHandler{        if (![self setValueToDictionaryValues:object] || !object)    {        onSuccessHandler(nil,[self createErrorWithDescription:@"Developer Error: Misconfigured Object" andErrorCodeNumber:kErrorObjectMisconfiguration inDomain:@"Visistation Object"]);        return;    }        // Check for patientID    if (![databaseObject valueForKey:PATIENTID])    {        // Adds an ID if it is not present        NSString* username = [BaseObject getCurrenUserName];        NSString* usernameID = [NSString stringWithFormat:@"TestUser_%f",[[NSDate date]timeIntervalSince1970]];                if (username)        {            usernameID = [NSString stringWithFormat:@"%@_%f",username,[[NSDate date]timeIntervalSince1970]];        }                [databaseObject setValue:usernameID forKey:PATIENTID];    }        [self saveObject:^(id<BaseObjectProtocol> data, NSError *error)    {        onSuccessHandler(data,error);    }];}-(NSArray *)FindAllObjectsLocallyFromParentObject:(NSDictionary*)parentObject{    NSString* firstname = [parentObject objectForKey: FIRSTNAME];    NSString* lastname = [parentObject objectForKey: FAMILYNAME];        NSPredicate* pred = [NSPredicate predicateWithFormat:@"%K beginswith[cd] %@ || %K beginswith[cd] %@",FIRSTNAME,firstname,FAMILYNAME,lastname];       if ((!firstname && !lastname) || (firstname.length == 0 && lastname.length == 0))    {        pred = nil;    }    return [self convertListOfManagedObjectsToListOfDictionaries:[self FindObjectInTable:DATABASE withCustomPredicate:pred andSortByAttribute:FIRSTNAME]];}-(void)FindAllObjectsOnServerFromParentObject:(NSDictionary*)parentObject OnCompletion:(ObjectResponse)eventResponse{    [self startSearchWithData:parentObject withsearchType:kFindObject andOnComplete:eventResponse];}//TODO: Empty Method?-(void)syncAllPatientsAndVisits{    }-(void) SyncAllOpenPatietnsOnServer:(ObjectResponse)Response{    [self startSearchWithData:[[NSDictionary alloc]init] withsearchType:kFindOpenObjects andOnComplete:Response];}-(NSArray*)FindAllOpenPatientsLocally{    //Predicate to return list of Open Objects    NSPredicate* pred = [NSPredicate predicateWithFormat:@"%K == TRUE",ISOPEN];        return [self convertListOfManagedObjectsToListOfDictionaries:[self FindObjectInTable:DATABASE withCustomPredicate:pred andSortByAttribute:FAMILYNAME]];}#pragma mark- Internal Private Methods#pragma mark--(void)linkPatient{    patient = (Patients*)self->databaseObject;}//TODO: Need a method to push all patients to the server@end