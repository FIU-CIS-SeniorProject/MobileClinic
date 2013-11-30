//
//  ServerWrapper.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 1/27/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//


#define UPDATE_NUMBER_OF_CONNECTIONS    @"update Connections"
#define MSG_SEND    @"messageSent"

#import <Foundation/Foundation.h>
#import "Server.h"
#import "HTTPCore.h"
// Object that hold the necessary data for the classes to use
typedef void (^ServerObject)(NSDictionary* data, NSString* error);

@interface ServerWrapper : HTTPCore<ServerDelegate>{
    Server* server;
    ServerObject dataToBeTransmitted;
    
    
}
@property(nonatomic, strong)NSMutableArray* devices;
@property(nonatomic, assign)int currentConnectionIndex;
//Singleton
+ (id)sharedServerManager;
-(id)init;

-(NSString*)getCurrentConnectionName;


-(void)stopServer;

// Starts the server
// Fires the event UPDATE_NUMBER_OF_CONNECTIONS
-(void)startServer;

- (void)connectToServiceAtSelectedIndex:(NSInteger)selectedRow;
- (void)sendData:(NSDictionary*)dataToBeSent;
@end
