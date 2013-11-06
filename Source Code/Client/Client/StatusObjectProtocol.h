//
//  StatusObjectProtocol.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 4/4/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//


#define DATA      @"data to transfer"
#define STATUS    @"status"

#import "NSObject+CustomTools.h"
#import "BaseObjectProtocol.h"

typedef enum {
    kSuccess                        = 0,
    kErrorDisconnected              = 1,
    kError                          = 2,
    kErrorObjectMisconfiguration    = 4,
    kErrorUserDoesNotExist          = 5,
    kErrorIncorrectLogin            = 6,
    kErrorPermissionDenied          = 7,
    kErrorIncompleteSearch          = 8,
    kErrorBadCommand                = 9,
} ServerStatus;

#import <Foundation/Foundation.h>

@protocol StatusObjectProtocol <NSObject>

@end
