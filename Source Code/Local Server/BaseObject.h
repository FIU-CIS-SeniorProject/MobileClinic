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
//  BaseObject.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 1/27/13.
//
// OTHER OBJECTS MAY NEED THESE TWO VARIABLES //
#define PATIENTBYID         @"patient_for_id"
#define ALLPATIENTS         @"patients"
#define UPDATEPATIENT       @"update_patient"
#define CREATEPATIENT       @"create_patient"
#define UPDATEVISIT         @"update_visit"
#define UPDATEFACES         @"update_faces"
#define UPDATEPRESCRIPTION  @"update_prescription"
#define DATABASEOBJECT      @"Database Object"

#import "NSObject+CustomTools.h"
#import <Foundation/Foundation.h>
#import "DatabaseDriver.h"
#import "BaseObjectProtocol.h"
#import "StatusObject.h"
#import "CloudServiceProtocol.h"

@interface BaseObject : DatabaseDriver <BaseObjectProtocol>
{
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