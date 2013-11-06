//
//  BaseObject+Protected.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 3/26/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//
#define ISDIRTY @"isDirty"

#import "BaseObject.h"
#import "StatusObject.h"
#import "CloudService.h"
@interface BaseObject (Protected)

/** This should only take in a dictionary that contains information
 * for the object that is unpackaging it.
 *
 * This means that the if a Class called Face is unpackaging the
 * dictionary, then the dictionary's type should be tested to see
 * if it is of type Face. This can be done by looking at the object
 * for key: OBJECTTYPE
 */
-(void) unpackageFileForUser:(NSDictionary*)data;

/** This needs to be implemented at all times. This is responsible for
 * carrying out the instructions that it was given.
 *
 * Instruction should be determined using switch statement on the
 * variable RemoteCommands commands (see properties at the bottom).
 * during the unpackageFileForUser:(NSDictionary*)data method, make
 * sure you save the method to the previously mentioned variable.
 * That way when CommonExecution method is called it knows what to
 * execute.
 *
 * If you want to add more methods that you think the server needs to
 * interpret add it to the RemoteCommands typedef above and add it
 * to the opposite systems typedef. (make sure you implement it in the
 * appropriate place in the both the Client & Server)
 */
-(void)CommonExecution;
/**
 * Use this to retrieve objects/values from the Patient object.
 *@param attribute the name of the attribute you want to retrieve.
 */
-(id)getObjectForAttribute:(NSString*)attribute;

/**
 * Use this to save attributes of the object. For instance, to the Patient's Firstname can be saved by passing the string of his name and the Attribute FIRSTNAME
 *@param object object that needs to be stored in the database
 *@param attribute the name of the attribute or the key to which the object needs to be saved
 */
-(void)setObject:(id)object withAttribute:(NSString*)attribute;

-(void)makeCloudCallWithCommand:(NSString *)command withObject:(id)object onComplete:(CloudCallback)onComplete;

-(void)sendInformation:(id)data toClientWithStatus:(int)kStatus andMessage:(NSString*)message;

//-(void)copyDictionaryValues:(NSDictionary*)dictionary intoManagedObject:(NSManagedObject*)mObject;

-(BOOL)loadObjectForID:(NSString *)objectID;

-(NSManagedObject*)loadObjectWithID:(NSString *)objectID;


-(BOOL)isObject:(id)obj UniqueForKey:(NSString*)key;

-(NSMutableArray*)convertListOfManagedObjectsToListOfDictionaries:(NSArray*)managedObjects;

-(void)sendSearchResults:(NSArray*)results;

-(void)UpdateObjectAndSendToClient;

-(NSArray*)SaveListOfObjectsFromDictionary:(NSArray*)List;

-(void)handleCloudCallback:(CloudCallback)callBack UsingData:(NSArray*)data WithPotentialError:(NSError*)error;


@end
