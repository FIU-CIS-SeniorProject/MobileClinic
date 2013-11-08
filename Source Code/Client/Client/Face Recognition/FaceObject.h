//
//  FaceObject.h
//  Mobile Clinic
//
//  Created by Humberto Suarez on 11/1/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseObject.h"
#import "FaceObjectProtocol.h"
#import "Face.h"
@interface FaceObject : BaseObject<FaceObjectProtocol,CommonObjectProtocol>{//NSObject{
    Face *face;

//id client;

/** This needs to be set (during unpackageFileForUser:(NSDictionary*)data
 * method) so that any recieving device knows how to unpack the
 * information
 */
//ObjectTypes objectType;
/** This needs to be set during the unpackageFileForUser:(NSDictionary*)data
 * method so the recieving device knows how to execute the request via
 * the CommonExecution method
 */
//RemoteCommands commands;

/** This needs to be set during the unpackageFileForUser:(NSDictionary*)data
 * method so the recieving device knows how to execute the request via
 * the CommonExecution method
 */
//NSManagedObject* databaseObject;
/** This needs to be set during the unpackageFileForUser:(NSDictionary*)data
 * method so the recieving device knows how to execute the request via
 * the CommonExecution method
 */
//NSString* COMMONDATABASE;
/** This needs to be set during the unpackageFileForUser:(NSDictionary*)data
 * method so the recieving device knows how to execute the request via
 * the CommonExecution method
 */
//NSString* COMMONID;
/** This needs to be set during the unpackageFileForUser:(NSDictionary*)data
 * method so the recieving device knows how to execute the request via
 * the CommonExecution method
 */
//NSInteger CLASSTYPE;
}

+(NSString*)getCurrenUserName;
@end
