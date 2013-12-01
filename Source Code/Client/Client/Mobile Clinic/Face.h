//
//  Face.h
//  Mobile Clinic
//
//  Created by Humberto Suarez on 11/1/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Face : NSManagedObject{


//@public id client;

/** This needs to be set (during unpackageFileForUser:(NSDictionary*)data
 * method) so that any recieving device knows how to unpack the
 * information
 */
//@public ObjectTypes objectType;
/** This needs to be set during the unpackageFileForUser:(NSDictionary*)data
 * method so the recieving device knows how to execute the request via
 * the CommonExecution method
 */
//@public RemoteCommands commands;

/** This needs to be set during the unpackageFileForUser:(NSDictionary*)data
 * method so the recieving device knows how to execute the request via
 * the CommonExecution method
 */
//@public NSManagedObject* databaseObject;
/** This needs to be set during the unpackageFileForUser:(NSDictionary*)data
 * method so the recieving device knows how to execute the request via
 * the CommonExecution method
 */
//@public NSString* COMMONDATABASE;
/** This needs to be set during the unpackageFileForUser:(NSDictionary*)data
 * method so the recieving device knows how to execute the request via
 * the CommonExecution method
 */
//@public NSString* COMMONID;
/** This needs to be set during the unpackageFileForUser:(NSDictionary*)data
 * method so the recieving device knows how to execute the request via
 * the CommonExecution method
 */
//@public NSInteger CLASSTYPE;
}
@property (nonatomic, retain) NSData * photo;
@property (nonatomic, retain) NSString * familyName;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * patientId;
@property (nonatomic, retain) NSNumber * label;
+(NSString*)getCurrenUserName;

@end
