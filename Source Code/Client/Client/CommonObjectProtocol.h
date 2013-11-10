//
//  CommonObjectProtocol.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 3/11/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//


#import "BaseObjectProtocol.h"
#import <Foundation/Foundation.h>

@protocol CommonObjectProtocol <NSObject>

/* This interface is used by all Data Model objects that shares a common schema */

+(NSString*)DatabaseName;

@optional
/** Attaches the current object too the parent */
-(void)associateObjectToItsSuperParent:(NSDictionary *)parent;

/** Creates a new object */
-(void)createNewObject:(NSDictionary*) object onCompletion:(ObjectResponse)onSuccessHandler;

-(NSArray *)FindAllObjectsLocallyFromParentObject:(NSDictionary*)parentObject;

-(void)FindAllObjectsOnServerFromParentObject:(NSDictionary*)parentObject OnCompletion:(ObjectResponse)eventResponse;

/**
 * Updates the given object and executes the given instruction on the server side
 */
-(void)UpdateObjectAndShouldLock:(BOOL)shouldLock witData:(NSMutableDictionary*)dataToSend AndInstructions:(NSInteger)instruction onCompletion:(ObjectResponse)response;

-(NSArray *)covertAllSavedObjectsToJSON;
@end
