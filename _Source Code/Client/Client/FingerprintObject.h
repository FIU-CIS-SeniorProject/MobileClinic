//
//  FingerprintObject.h
//  Mobile Clinic
//
//  Created by sebastian a zanlongo on 4/7/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FingerprintObjectProtocol.h"


@interface FingerprintObject : NSObject <FingerprintObjectProtocol, PBBiometryDatabase> {
    /** List of enrolled fingers. */
    NSMutableArray* enrolledFingers;
}

/** The class is a singleton. This method returns the single object for this class. */
+ (id) sharedClass;

@end
