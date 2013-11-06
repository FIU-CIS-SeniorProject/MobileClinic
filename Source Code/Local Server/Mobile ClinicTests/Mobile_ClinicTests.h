//
//  Mobile_ClinicTests.h
//  Mobile ClinicTests
//
//  Created by Michael Montaque on 1/23/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "ConnectListContent.h"
@interface Mobile_ClinicTests : SenTestCase{
    ConnectListContent* connectionList;
    UserObject* user;
    BaseObject*obj;
    dispatch_semaphore_t semaphore;
}

@end
