//
//  ObjectFactory.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 1/27/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseObjectProtocol.h"
@interface ObjectFactory : NSObject
+(id)createObjectForType:(NSDictionary*)data;
@end
