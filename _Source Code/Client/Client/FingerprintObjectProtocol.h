//
//  FingerprintObjectProtocol.h
//  Mobile Clinic
//
//  Created by sebastian a zanlongo on 4/7/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBBiometryDatabase.h"

@protocol FingerprintObjectProtocol <NSObject>

- (id) initWithEnrolledFingers:(NSArray*)enrolled;
+ (NSMutableDictionary*)findPatientFromArrayOfPatients:(NSArray*)allPatients withFinger:(PBBiometryFinger*)finger;

@end
