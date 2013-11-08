//
//  ScreenNavigationDelegate.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 2/10/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ScreenNavigationDelegate <NSObject>

typedef void(^ScreenHandler)(id object, NSError* error);

-(void)setScreenHandler:(ScreenHandler)myHandler;
@end
