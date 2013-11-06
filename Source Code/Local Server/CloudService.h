//
//  CloudService.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 3/15/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CloudServiceProtocol.h"
@interface CloudService : NSObject<CloudServiceProtocol>
+(CloudService *) cloud;

@end
