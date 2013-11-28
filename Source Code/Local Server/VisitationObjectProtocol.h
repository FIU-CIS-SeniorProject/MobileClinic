//
//  VisitationObjectProtocol.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 3/10/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//
#define TRIAGEIN        @"triageIn"
#define TRIAGEOUT       @"triageOut"
#define DOCTORID        @"doctorId"
#define PATIENTID       @"patientId"
#define DOCTORIN        @"doctorIn"
#define DOCTOROUT       @"doctorOut"
#define ASSESSMENT      @"assessment"
#define CONDITION       @"condition"
#define CONDITIONTITLE  @"conditionTitle"
#define DTITLE          @"diagnosisTitle"
#define GRAPHIC         @"isGraphic"
#define WEIGHT          @"weight" //The different user types (look at enum)
#define OBSERVATION     @"observation"
#define NURSEID         @"nurseId"
#define BLOODPRESSURE   @"bloodPressure"
#define HEARTRATE       @"heartRate"
#define RESPIRATION     @"respiration"
#define PRIORITY        @"priority"
#define VISITID         @"visitationId"
#define CHARITYID       @"charityId"

#define ISOPEN      @"isOpen"
#define MEDICATIONNOTES @"medicationNotes"

#import "CommonObjectProtocol.h"
#import <Foundation/Foundation.h>

@protocol VisitationObjectProtocol <NSObject>
-(void)UnlockVisit:(ObjectResponse)onComplete;


@end
