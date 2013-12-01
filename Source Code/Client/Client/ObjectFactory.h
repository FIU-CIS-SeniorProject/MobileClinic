//
//  ObjectFactory.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 1/27/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

/* This class follows the factory pattern
    It is used by the Server API to construct the proper class when information is recieved. This is may not be used in the client much but it is highly used in the Server Source Code 
 */

#import <Foundation/Foundation.h>
#import "BaseObjectProtocol.h"
@interface ObjectFactory : NSObject
+(id)createObjectForType:(NSDictionary*)data;
+(id<BaseObjectProtocol>)createObjectForInteger:(NSString*)data;
@end
