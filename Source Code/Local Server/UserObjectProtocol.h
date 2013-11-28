// The MIT License (MIT)
//
// Copyright (c) 2013 Florida International University
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//  UserObjectProtocol.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 3/5/13.
//  Modified by Kevin Diaz on 11/23/13.
//
#define STATUS      @"status"
#define EMAIL       @"email"
#define FIRSTNAME   @"firstName"
#define LASTNAME    @"lastName"
#define USERNAME    @"userName"
#define PASSWORD    @"password"
#define USERTYPE    @"userType" //The different user types (look at enum)
#define CHARITYID   @"charityId"
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

typedef enum
{
    kTriageNurse    = 0,
    kDoctor         = 1,
    kPharmacists    = 2,
    kAdministrator  = 3,
}UserTypes;

@protocol UserObjectProtocol <NSObject>

-(NSArray *)FindAllCharityObjects;

/* call to send this object to be verified by the server */
-(void)loginWithUsername:(NSString*)username andPassword:(NSString*)password onCompletion:(void(^)(id <BaseObjectProtocol> data, NSError* error, Users* userA))onSuccessHandler;
@end