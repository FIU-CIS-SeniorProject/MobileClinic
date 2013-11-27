//
//  PatientObjectProtocol.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 3/1/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#define FIRSTNAME                   @"firstName"
#define FAMILYNAME                  @"familyName"
#define VILLAGE                     @"villageName"
#define HEIGHT                      @"height"
#define SEX                         @"sex"
#define DOB                         @"age"
#define PICTURE                     @"photo"
#define USERID                      @"userID"
#define FINGERPOSITION              @"fingerPosition"
#define FINGERDATA                  @"fingerData"
#define DATASIZE                    @"dataSize"
#define TEMPLATETYPE                @"templateType"
#define LABEL                       @"label"

#import "DataProcessor.h"
#import "BaseObjectProtocol.h"
#import "CommonObjectProtocol.h"
@protocol PatientObjectProtocol <NSObject>

-(NSArray*)FindAllOpenPatientsLocally;

-(void) SyncAllOpenPatietnsOnServer:(ObjectResponse)Response;


@end
