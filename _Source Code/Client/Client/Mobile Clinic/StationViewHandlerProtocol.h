//
//  StationViewHandlerProtocol.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 2/20/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ScreenNavigationDelegate.h"
@protocol StationViewHandlerProtocol <NSObject>
- (void)setScreenHandler:(ScreenHandler)myHandler;
@end
