//
//  ServerProtocol.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 2/3/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//
#define SERVER_OBSERVER     @"Server Observer Pattern"
#define SERVER_STATUS     @"Server Status"
#import <Foundation/Foundation.h>

@protocol ServerProtocol <NSObject>
@required
@property(assign) BOOL isServerRunning;
+(id)sharedInstance;
- (void) start;
- (void) stopServer;
-(NSString*)getHostNameForSocketAtIndex:(NSInteger)index;
-(NSString*)getPortForSocketAtIndex:(NSInteger)index;
- (NSInteger)numberOfConnections;
@end
