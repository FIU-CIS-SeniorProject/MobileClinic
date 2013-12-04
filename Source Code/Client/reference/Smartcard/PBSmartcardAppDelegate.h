/*
 * Copyright (c) 2011 - 2012, Precise Biometrics AB
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the Precise Biometrics AB nor the names of its
 *    contributors may be used to endorse or promote products derived from
 *    this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
 * AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
 * THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 *
 *
 * $Date: 2012-04-20 11:18:03 +0200 (fr, 20 apr 2012) $ $Rev: 14630 $ 
 *
 */

#import <UIKit/UIKit.h>

#import "PBDisconnectionViewController.h"

/** Helper class for smartcard applications. */
@interface PBSmartcardAppDelegate : UIResponder <UIApplicationDelegate> {    
    /** Queue for received notifications (accessory connected/disconnected, 
     *  smartcard inserted/removed). */
    NSMutableArray* notificationQueue;
    /** Identifier for the current background task responsible of closing 
     *  down the connection to the accessory. Will be UIBackgroundTaskInvalid
     *  if no background task is currently ongoing. */
    UIBackgroundTaskIdentifier backgroundTask;

    /** View controller for view indicating when the accessory is not connected 
     *  to the device. */
    PBDisconnectionViewController* disconnectionViewController;
    /** Tells if the disconnection view shall be displayed or not when the 
     *  accessory is not connected to the device, default YES. */
    BOOL useDisconnectionView;
}

/** Called when the accessory is connected to the device. */
- (void)accessoryConnected: (NSNotification*)notification;

/** Called when the accessory is disconnected from the device. */
- (void)accessoryDisconnected: (NSNotification*)notification;

/** Called when a smartcard is inserted in the reader. */
- (void)smartcardInserted: (NSNotification*)notification;

/** Called when a smartcard is removed from the reader. */
- (void)smartcardRemoved: (NSNotification*)notification;


@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) BOOL useDisconnectionView;

@end
