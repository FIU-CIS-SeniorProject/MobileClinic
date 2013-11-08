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
#import "PatientObject.h"

@implementation ObjectFactory

+(id)createObjectForType:(NSDictionary*)data{
    
    // gets the object type
    ObjectTypes type = [[data objectForKey:OBJECTTYPE]integerValue];
    
    // Volatile Code:
    // Returns the instatiation of the correct class depending on the ObjectType
    switch (type) {
        case kUserType:
            return [[UserObject alloc]init];
        case kStatusType:
            return [[StatusObject alloc]init];
        case kPatientType:
            return [[PatientObject alloc]init];
        default:
            return nil;
    }
}
@end
