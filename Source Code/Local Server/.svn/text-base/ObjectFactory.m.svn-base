//
//  ObjectFactory.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 1/27/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import "ObjectFactory.h"
#import "UserObject.h"
#import "StatusObject.h"
@implementation ObjectFactory

+(id<BaseObjectProtocol>)createObjectForType:(NSDictionary*)data{
    // ObjectType: Used to generically determine what kind of information was passed
    ObjectTypes type = [[data objectForKey:OBJECTTYPE]intValue];
    
    switch (type) {
        case kUserType:
            return [[UserObject alloc]init];
        case kStatusType:
            return [[StatusObject alloc]init];
        default:
            return nil;
    }
}
@end
