//
//  FIUAppDelegate.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 1/23/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//
#define APPDELEGATE_STARTED @"slow appdelegate"
#import <Cocoa/Cocoa.h>
#import "ServerCore.h"

@interface FIUAppDelegate : NSObject <NSApplicationDelegate>{
}

@property (nonatomic, strong) ServerCore *server;
@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

@end
