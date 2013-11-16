//
//  MenuViewController.h
//  Mobile Clinic
//
//  Created by Steven Berlanga on 3/26/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScreenNavigationDelegate.h"

@interface MenuViewController : UITableViewController
{
    ScreenHandler handler;
}

- (void)setScreenHandler:(ScreenHandler)screenDelegate;

@end