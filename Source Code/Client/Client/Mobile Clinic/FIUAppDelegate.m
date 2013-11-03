// The MIT License (MIT)
//
// Copyright (c) 2013 Florida International University
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//  FIUAppDelegate.m
//  Mobile Clinic
//
//  Created by Steven Berlanga on 2/2/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//
#import "FIUAppDelegate.h"
#import "ServerCore.h"

@implementation FIUAppDelegate
@synthesize ServerManager;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (UIViewController*) topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController)
    {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

+(AJNotificationView *)getNotificationWithColor:(int)color Animation:(int)animate WithMessage:(NSString *)msg
{
    UIView *topMostView = [[FIUAppDelegate topMostController]view];
    return [AJNotificationView showNoticeInView:topMostView type:color title:msg linedBackground:animate hideAfter:10];
}

+(AJNotificationView *)getNotificationWithColor:(int)color Animation:(int)animate WithMessage:(NSString *)msg inView:(UIView *)view
{
    return [AJNotificationView showNoticeInView:view type:color title:msg linedBackground:animate hideAfter:3];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    #define TESTING 1
        #ifdef TESTING
            [TestFlight setDeviceIdentifier:[[NSUUID UUID]UUIDString]];
        #endif
        [TestFlight takeOff:@"afc6ff4013b9e807e5a97743e2a8d270_MTg2NjAwMjAxMy0wMi0xMiAxODozOTozOS41NzU1OTk"];
    
    // Override point for customization after application launch.
    return YES;
}

- (void)RigoMethod
{
    //RIGO - FOR TESTING PURPOSES ONLY
    //MANUALLY ENTERS DATA INTO THE DATABASE
    //    NSError *error;
    //    NSManagedObjectContext *context = [self managedObjectContext];
    
    //    // ADD MEDICATION MANUALLY
    //    NSManagedObject *medication = [NSEntityDescription
    //                                       insertNewObjectForEntityForName:@"Medication"
    //                                       inManagedObjectContext:context];
    //
    //    [medication setValue:@"200" forKey:@"dosage"];
    //    [medication setValue:@"" forKey:@"expiration"];
    //    [medication setValue:@"" forKey:@"isLockedBy"];
    //    [medication setValue:@"advil.200" forKey:@"medicationId"];
    //    [medication setValue:@"Advil" forKey:@"medName"];
    //    [medication setValue:[NSNumber numberWithInt:5] forKey:@"numContainers"];
    //    [medication setValue:[NSNumber numberWithInt:50] forKey:@"tabletsContainer"];
    //    [medication setValue:[NSNumber numberWithInt:250] forKey:@"total"];
    //
    //    if (![context save:&error]) {
    //        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    //    }
    
    /*
     // Delete all entries in the Core Data table (ex. Patients)
     NSFetchRequest *fetchRecords = [[NSFetchRequest alloc] init];
     [fetchRecords setEntity:[NSEntityDescription entityForName:@"Patients" inManagedObjectContext:context]];
     
     NSArray *currentRecords = [context executeFetchRequest:fetchRecords error:&error];
     
     for(NSManagedObject *entries in currentRecords) {
     [context deleteObject:entries];
     }
     */
    
    // Print (to NSLog) content of table (ex. Patients)
    //    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    //    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Patients" inManagedObjectContext:context]];
    //
    //    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    //    [self saveContext];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
    [ServerManager stopClient];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Mobile_Clinic.sqlite"];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    NSError *error = nil;
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
    {
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
@end