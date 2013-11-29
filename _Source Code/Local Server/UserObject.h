//
//  UserObject.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 1/27/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "BaseObject.h"
#import "Users.h"
#import "UserObjectProtocol.h"
#import "CloudService.h"

@interface UserObject : BaseObject<UserObjectProtocol,CommonObjectProtocol>
{
    Users* user;
}

@end