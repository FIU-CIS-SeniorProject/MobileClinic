//
//  FIUAppDelegate.h
//  Mobile Clinic
//
//  Created by Steven Berlanga on 2/2/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "ServerProtocol.h"
#import "AJNotificationView.h"
#import "RNBlurModalView.h"
#import "UIViewControllerExt.h"

@interface FIUAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) id<ServerProtocol> ServerManager;
@property (strong, nonatomic) UIWindow *window;
@property (weak, nonatomic) NSString* currentUserName;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

+(AJNotificationView*)getNotificationWithColor:(int)color Animation:(int)animate WithMessage:(NSString*)msg;
+(AJNotificationView*)getNotificationWithColor:(int)color Animation:(int)animate WithMessage:(NSString*)msg inView:(UIView*)view;

@end
