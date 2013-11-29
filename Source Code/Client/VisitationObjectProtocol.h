//
//  VisitationObjectProtocol.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 3/3/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//
#define TRIAGEIN        @"triageIn"
#define TRIAGEOUT       @"triageOut"
#define DOCTORID        @"doctorId"
#define PATIENTID       @"patientId"
#define DOCTORIN        @"doctorIn"
#define DOCTOROUT       @"doctorOut"
#define CONDITION       @"condition"
#define CONDITIONTITLE  @"conditionTitle"
#define DTITLE          @"diagnosisTitle"
#define ASSESSMENT      @"assessment"
#define GRAPHIC         @"isGraphic"
#define WEIGHT          @"weight" 
#define OBSERVATION     @"observation"
#define NURSEID         @"nurseId"
#define BLOODPRESSURE   @"bloodPressure"
#define VISITID         @"visitationId"
#define HEARTRATE       @"heartRate"
#define RESPIRATION     @"respiration"
#define TEMPERATURE     @"temperature"
#define PRIORITY        @"priority"
#define ISOPEN          @"isOpen"
#define MEDICATIONNOTES @"medicationNotes"

#import <Foundation/Foundation.h>
#import "CommonObjectProtocol.h"

@protocol VisitationObjectProtocol <NSObject>

/**
 *
 */
-(void) SyncAllOpenVisitsOnServer:(ObjectResponse)Response;
/**
 *
 */
-(NSArray*) FindAllOpenVisitsLocally;
/**
 *
 */
-(BOOL)shouldSetCurrentVisitToOpen:(BOOL)shouldOpen;
/**
 *
 */
-(NSArray*)FindAllVisitsWithinTheLastXHours:(int)hours;


@end
