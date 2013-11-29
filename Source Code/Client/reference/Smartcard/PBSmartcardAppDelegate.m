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

#import "PBSmartcardAppDelegate.h"

#import <ExternalAccessory/ExternalAccessory.h>

#import "PBAccessory.h"
#import "PBSmartcardIDStore.h"
#import "PBBiomatch3Verifier.h"

#import "PBPracticeController.h"

#ifdef DEBUG
#define PBSmartcardAppDelegateLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define PBSmartcardAppDelegateLog(...)
#endif

@implementation PBSmartcardAppDelegate

@synthesize window = _window;
@synthesize useDisconnectionView;

- (void)dealloc
{
    [notificationQueue release];
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    notificationQueue = [[NSMutableArray alloc] init];
    backgroundTask = UIBackgroundTaskInvalid;
    
    disconnectionViewController = [[PBDisconnectionViewController alloc] initWithNibName:@"PBDisconnectionViewController" bundle:[NSBundle mainBundle]];
    useDisconnectionView = YES;
    
    // init EAManager on main thread
    EAAccessoryManager* am = [EAAccessoryManager sharedAccessoryManager];
    am = am; // suppress warning
    
    /* Start thread for processing notifications. */
    [NSThread detachNewThreadSelector:@selector(processNotificationQueue) toTarget:self withObject:nil];
    
    return YES;
}

- (void)connectToSmartcard
{    
    PBSmartcardStatus status = [[PBSmartcardIDStore sharedIDStore] connect];
    
    if (status != PBSmartcardStatusSuccess) {
        PBSmartcardAppDelegateLog(@"Connect failed with status %d!", status);
    }
    else {
        PBSmartcardAppDelegateLog(@"Connect suceeded!");
    }
}

- (void)disconnectFromSmartcard
{
    PBSmartcardStatus status = [[PBSmartcardIDStore sharedIDStore] disconnect];    
    
    if (status != PBSmartcardStatusSuccess) {
        PBSmartcardAppDelegateLog(@"Disconnect failed with status %d!", status);
    }
    else {
        PBSmartcardAppDelegateLog(@"Disconnect suceeded!");
    }
}

- (void)openSmartcardConnection
{
    PBSmartcardStatus status = [[PBSmartcardIDStore sharedIDStore] openWithDisabledBackgroundManagement];
    if (status != PBSmartcardStatusSuccess) {
        PBSmartcardAppDelegateLog(@"Open failed with status %d!", status);
    }
    else {
        PBSmartcardAppDelegateLog(@"Open suceeded!");
    }
}

- (void)closeSmartcardConnection
{
    PBSmartcardStatus status;
    
    /* Disconnect from smartcard. */
    [self disconnectFromSmartcard];
    
    /* Close connection to smartcard reader. */
    status = [[PBSmartcardIDStore sharedIDStore] close];
    if (status != PBSmartcardStatusSuccess) {
        PBSmartcardAppDelegateLog(@"Close failed with status %d!", status);
    }
    else {
        PBSmartcardAppDelegateLog(@"Close suceeded!");
    }
}

/** Method checking for new notification on the notification queue. When new
 *  notifications arrive, they will be handled FIFO-wise. */
- (void)processNotificationQueue
{
    BOOL processedAccessoryDisconnectedInBackground = FALSE;
    
    while (YES) {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        
        /* Check if new notifications has arrived. */
        while ([notificationQueue count] > 0) {
            NSString* notification;
            @synchronized (notificationQueue) {
                notification = [notificationQueue objectAtIndex:0];
            }
            
            if ([notification isEqualToString:@"AccessoryConnected"]) {
                [self openSmartcardConnection];
            }
            else if ([notification isEqualToString:@"AccessoryDisconnected"]) {
                if (backgroundTask != UIBackgroundTaskInvalid) {
                    /* Application has entered background, flag that we will close the
                     * smartcard connection in background. */
                    processedAccessoryDisconnectedInBackground = YES;
                    PBSmartcardAppDelegateLog(@"Processing accessoryDisconnected in background!");
                }
                [self closeSmartcardConnection];
            }
            else if ([notification isEqualToString:@"SmartcardInserted"]) {
                [self connectToSmartcard];
            }
            else if ([notification isEqualToString:@"SmartcardRemoved"]) {
                [self disconnectFromSmartcard];
            }
            
            @synchronized (notificationQueue) {
                [notificationQueue removeObjectAtIndex:0];
            }
        }
        
        if (processedAccessoryDisconnectedInBackground && (backgroundTask != UIBackgroundTaskInvalid)) {
            /* Application has entered background and was waiting for this thread to finish 
             * it's job. Notify application that we are done! */
            PBSmartcardAppDelegateLog(@"Ending background task!");
            [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
            processedAccessoryDisconnectedInBackground = NO;
            backgroundTask = UIBackgroundTaskInvalid;
        }
        /* Queue empty, sleep 50 ms before checking for new notifications. */
        [NSThread sleepForTimeInterval:0.050];
        
        [pool release];
    }
}

/** Adds a notification to the notification queue. */
- (void)addNotification: (NSString*)notification
{
    @synchronized (notificationQueue) {
        if ([notification isEqualToString:@"AccessoryConnected"]) {
            /* Look for earlier accessory connected notifications and if found, remove
             * all notifications from that and until end of queue. */
            for (NSInteger i = 0; i < [notificationQueue count]; i++) {
                NSString* oldNotification = [notificationQueue objectAtIndex:i];
                
                if ([oldNotification isEqualToString:notification]) {
                    /* Found older accessory connected. */
                    while ([notificationQueue count] > i) {
                        [notificationQueue removeLastObject];
                    }
                    break;
                }
            }
        }
        else if ([notification isEqualToString:@"AccessoryDisconnected"]) {
            /* Look for earlier accessory disconnected notifications and if found, remove
             * all notifications from that and until end of queue. */
            for (NSInteger i = 0; i < [notificationQueue count]; i++) {
                NSString* oldNotification = [notificationQueue objectAtIndex:i];
                
                if ([oldNotification isEqualToString:notification]) {
                    /* Found older accessory disconnected. */
                    while ([notificationQueue count] > i) {
                        [notificationQueue removeLastObject];
                    }
                    break;
                }
            }
        }
        else if ([notification isEqualToString:@"SmartcardInserted"]) {
            /* Do nothing. */
        }
        else if ([notification isEqualToString:@"SmartcardRemoved"]) {
            /* Do nothing. */
        }
        else {
            PBSmartcardAppDelegateLog(@"Unrecognized notification '%@' received!", notification);
            return;
        }
        
        [notificationQueue addObject:notification];
    }
}

- (void)showDisconnectionViewInMainThread
{
    if (useDisconnectionView) {
        [disconnectionViewController viewWillAppear:YES];
        disconnectionViewController.view.center = self.window.center;
        [self.window addSubview: disconnectionViewController.view];
        [disconnectionViewController viewDidAppear:YES];
    }
}

- (void)hideDisconnectionViewInMainThread
{
    /* Always hide it, in case useDisconnectionView was set to NO while it was showing. */
    [disconnectionViewController viewWillDisappear:YES];
    [disconnectionViewController.view removeFromSuperview];
    [disconnectionViewController viewDidDisappear:YES];    
}

- (void)accessoryConnected: (NSNotification*)notification
{
    PBSmartcardAppDelegateLog(@"Accessory connected!");
    [self addNotification:@"AccessoryConnected"];
    [self performSelectorOnMainThread:@selector(hideDisconnectionViewInMainThread) withObject:nil waitUntilDone:NO];
}

- (void)accessoryDisconnected: (NSNotification*)notification
{
    PBSmartcardAppDelegateLog(@"Accessory disconnected!");
    [self addNotification:@"AccessoryDisconnected"];
    [self performSelectorOnMainThread:@selector(showDisconnectionViewInMainThread) withObject:nil waitUntilDone:NO];
}

- (void)smartcardInserted: (NSNotification*)notification
{
    PBSmartcardAppDelegateLog(@"Smartcard inserted!");
    [self addNotification:@"SmartcardInserted"];
}

- (void)smartcardRemoved: (NSNotification*)notification
{
    PBSmartcardAppDelegateLog(@"Smartcard removed!");
    [self addNotification:@"SmartcardRemoved"];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    PBSmartcardAppDelegateLog(@"ApplicationDidEnterBackground!");
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    backgroundTask = [application beginBackgroundTaskWithExpirationHandler:nil];
    [self addNotification:@"AccessoryDisconnected"];
    
    /* Unregister as observer. */
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    PBSmartcardAppDelegateLog(@"ApplicationDidBecomeActive!");
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    if ([[PBAccessory sharedClass] isConnected]) {
        [self addNotification:@"AccessoryConnected"];
    }  
    else {
        /* Display disconnection view. */
        [self performSelectorOnMainThread:@selector(showDisconnectionViewInMainThread) withObject:nil waitUntilDone:NO];
    }
    
    /* Register as observer for accessory connect/disconnect notifications. */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryConnected:) name:@"PBAccessoryDidConnectNotification" object:[PBAccessory sharedClass]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryDisconnected:) name:@"PBAccessoryDidDisconnectNotification" object:[PBAccessory sharedClass]];
    /* Register as observer for smartcard inserted/removed notifications. */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(smartcardInserted:) name:@"PB_CARD_INSERTED" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(smartcardRemoved:) name:@"PB_CARD_REMOVED" object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
