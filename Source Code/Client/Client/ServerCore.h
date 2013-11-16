//
//  ServerCore.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 1/30/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "HTTPCore.h"
#import "ServerProtocol.h"

@interface ServerCore : HTTPCore <GCDAsyncSocketDelegate,NSNetServiceBrowserDelegate,NSNetServiceDelegate,ServerProtocol>
{
    NSNetServiceBrowser *netServiceBrowser;
	NSNetService *serverService;
	NSMutableArray *serverAddresses;
	GCDAsyncSocket *asyncSocket;
    NSMutableData* globalData;
    ClientServerConnect connectionStatus;
}

-(BOOL)isClientConntectToServer;
-(NSString*)getCurrentConnectionName;
-(NSInteger)numberOfConnections;

@end