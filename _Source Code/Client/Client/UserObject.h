//
//  UserObject.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 1/27/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

/*
 * Listeners That should be set:
 *
 *
 */


#define STATUS      @"status"
#define EMAIL       @"email"
#define FIRSTNAME   @"firstName"
#define LASTNAME    @"lastName"
#define USERNAME    @"userName"
#define PASSWORD    @"password"
#define USERTYPE    @"userType"
#define SECONDARYTYPE @"secondaryTypes"

#import <Foundation/Foundation.h>
#import "BaseObject.h"
#import "Users.h"
#import "UserObjectProtocol.h"
/* Users of the system */

@interface UserObject : BaseObject<UserObjectProtocol,CommonObjectProtocol>{
    Users* user;
}    


@end
