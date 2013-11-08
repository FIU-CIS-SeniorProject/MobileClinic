//
//  UserObjectProtocol.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 3/5/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//
#define STATUS      @"status"
#define EMAIL       @"email"
#define FIRSTNAME   @"firstName"
#define LASTNAME    @"lastName"
#define USERNAME    @"userName"
#define PASSWORD    @"password"
#define USERTYPE    @"userType" //The different user types (look at enum)
#define SAVE_USER @"savedUser"

/** Secondary type examples
 * 0001 -> Triage
 * 0010 -> Doctor
 * 0100 -> Pharmacist
 * 1000 -> Administrator
 * 0101 -> Pharmacist and Triage
 */
#define SECONDARYTYPE @"secondaryTypes"

#import <Foundation/Foundation.h>
#import "BaseObjectProtocol.h"
#import "CommonObjectProtocol.h"

typedef enum {
    kTriageNurse    = 0,
    kDoctor         = 1,
    kPharmacists    = 2,
    kAdministrator  = 3,
}UserTypes;

@protocol UserObjectProtocol <NSObject>

@end
