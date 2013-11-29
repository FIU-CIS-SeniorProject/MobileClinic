//
//  StatusObject.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 1/27/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import "StatusObjectProtocol.h"

@interface StatusObject : NSObject<BaseObjectProtocol>

- (id)init;

@property(nonatomic, weak)      NSString* errorMessage;
@property(nonatomic, weak)      NSDictionary* data;
@property(nonatomic, assign)    ServerStatus status;


#pragma mark - BaseObjectProtocol Variables
#pragma mark

@property(nonatomic, weak)      id client;
@property(nonatomic, assign)    ObjectTypes objectType;
@property(nonatomic, assign)    RemoteCommands commands;
@end
