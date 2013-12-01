//
//  BaseObjectProtocol.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 2/1/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//
#define ISLOCKEDBY          @"isLockedBy"
#define OBJECTTYPE          @"objectType"
#define OBJECTCOMMAND       @"userCommand" //The different user types (look at enum)
#define ALLITEMS            @"ALL_ITEMS"

#import "NSString+Validation.h"
#import "DataProcessor.h"
#import <Foundation/Foundation.h>

/* These are all the classes the server and client will know how to handle */
typedef enum {
    kUserType           = 1,
    kStatusType         = 2,
    kPatientType        = 3,
    kVisitationType     = 4,
    kPharmacyType       = 5,
    kPrescriptionType   = 6,
    kMedicationType     = 7,
    kCloudManagementType = 8,
    kFaceType           = 10,
}ObjectTypes;

/* These are all the commands the server and client will understand */
typedef enum {
    kAbort                      = -1,
    kPullAllUsers               = 0,
    kLoginUser                  = 1,
    kLogoutUser                 = 2,
    kStatusClientWillRecieve    = 3,
    kStatusServerWillRecieve    = 4,
    kUpdateObject               = 5,
    kFindObject                 = 6,
    kFindOpenObjects            = 7,
    kConditionalCreate          = 8,
    kFindUsingPredicate         = 9,
    kRegisterFace               =10,
}RemoteCommands;

@protocol BaseObjectProtocol <NSObject>

typedef void (^ObjectResponse)(id<BaseObjectProtocol> data, NSError* error);
typedef void (^ServerCommand)(NSDictionary* dataToBeSent);
typedef void (^CloudCallback)(id cloudResults, NSError* error);

@required
/** This needs to be set during the unpackageFileForUser:(NSDictionary*)data
 * method so the recieving device knows how to execute the request via
 * the CommonExecution method
 */
- (id)init;
/** This needs to be set during the unpackageFileForUser:(NSDictionary*)data
 * method so the recieving device knows how to execute the request via
 * the CommonExecution method
 */
- (id)initAndMakeNewDatabaseObject;
/** This needs to be set during the unpackageFileForUser:(NSDictionary*)data
 * method so the recieving device knows how to execute the request via
 * the CommonExecution method
 */
- (id)initAndFillWithNewObject:(NSDictionary *)info;
/** This needs to be set during the unpackageFileForUser:(NSDictionary*)data
 * method so the recieving device knows how to execute the request via
 * the CommonExecution method
 */
- (id)initWithCachedObjectWithUpdatedObject:(NSDictionary*)dic;

/** This method should take all the objects important information
 * and place them inside a dictionary with keys that should be
 * reflected in the server.
 *
 * Once packaged, return the dictionary
 */
-(NSDictionary*) consolidateForTransmitting;

- (void)ServerCommand:(NSDictionary*)dataToBeRecieved withOnComplete:(ServerCommand)response;


/** This only needs to be implemented if the object needs to save to
 * its local database
 */
-(void)saveObject:(ObjectResponse)eventResponse;

/**
 * Deletes the current database object
 */
-(BOOL)deleteCurrentlyHeldObjectFromDatabase;
/**
 * Deletes the related object from database based on the contents from the dictionary
 */
-(BOOL)deleteDatabaseDictionaryObject:(NSDictionary*)object;

-(NSError*)setValueToDictionaryValues:(NSDictionary*)values;
-(NSMutableDictionary*)getDictionaryValuesFromManagedObject;
-(NSMutableDictionary*)getDictionaryValuesFromManagedObject:(NSManagedObject*)object;

@end