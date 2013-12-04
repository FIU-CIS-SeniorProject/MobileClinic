//
//  BaseObject.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 1/27/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

// OTHER OBJECTS MAY NEED THESE TWO VARIABLES //
#define PATIENTBYID     @"patient_for_id"
#define ALLPATIENTS     @"patients"
#define UPDATEPATIENT   @"update_patient"
#define CREATEPATIENT   @"create_patient"
#define UPDATEVISIT     @"update_visit"
#define UPDATEFACES     @"update_faces"
#define DATABASEOBJECT @"Database Object"

#import "NSObject+CustomTools.h"
#import <Foundation/Foundation.h>
#import "DatabaseDriver.h"
#import "BaseObjectProtocol.h"
#import "StatusObject.h"
#import "CloudServiceProtocol.h"

@interface BaseObject : DatabaseDriver <BaseObjectProtocol>{
    ObjectResponse respondToEvent;
    ServerCommand commandPattern;
    StatusObject* status;
    id<CloudServiceProtocol> cloudAPI;
    
    /** This needs to be set everytime information is recieved
     * by the serverCore, so it knows how to send information
     * back
     */
      id client;
    
      NSString* isLockedBy;
    /** This needs to be set (during unpackageFileForUser:(NSDictionary*)data
     * method) so that any recieving device knows how to unpack the
     * information
     */
    ObjectTypes objectType;
    /** This needs to be set during the unpackageFileForUser:(NSDictionary*)data
     * method so the recieving device knows how to execute the request via
     * the CommonExecution method
     */
    RemoteCommands commands;
    
    /** This needs to be set during the unpackageFileForUser:(NSDictionary*)data
     * method so the recieving device knows how to execute the request via
     * the CommonExecution method
     */
    NSManagedObject* databaseObject;
    
    /** This needs to be set during the unpackageFileForUser:(NSDictionary*)data
     * method so the recieving device knows how to execute the request via
     * the CommonExecution method
     */
      NSString* COMMONDATABASE;
    /** This needs to be set during the unpackageFileForUser:(NSDictionary*)data
     * method so the recieving device knows how to execute the request via
     * the CommonExecution method
     */
    NSString* COMMONID;
    /** This needs to be set during the unpackageFileForUser:(NSDictionary*)data
     * method so the recieving device knows how to execute the request via
     * the CommonExecution method
     */
    NSInteger CLASSTYPE;
}


@end
