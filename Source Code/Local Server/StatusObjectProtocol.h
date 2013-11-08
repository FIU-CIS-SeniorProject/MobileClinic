//
//  StatusObjectProtocol.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 3/15/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//
#define DATA      @"data to transfer"
#define STATUS     @"status"

#import <Foundation/Foundation.h>
#import "BaseObjectProtocol.h"
typedef enum {
    kSuccess                        = 0,
    kError                          = 1,
    kErrorDisconnected              = 3,
    kErrorObjectMisconfiguration    = 4,
    kErrorUserDoesNotExist          = 5,
    kErrorIncorrectLogin            = 6,
    kErrorPermissionDenied          = 7,
    kErrorIncompleteSearch          = 8,
    kErrorBadCommand                = 9,
} ServerStatus;

@protocol StatusObjectProtocol <NSObject>

@end
