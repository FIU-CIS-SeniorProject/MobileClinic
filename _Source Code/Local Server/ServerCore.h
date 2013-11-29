//
//  ServerCore.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 1/30/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "ServerProtocol.h"
@interface ServerCore : NSObject <ServerProtocol,GCDAsyncSocketDelegate,NSNetServiceDelegate, NSNetServiceBrowserDelegate> {
    NSNetService *netService;
	GCDAsyncSocket *asyncSocket;
    NSMutableData* globalData;
	NSMutableArray *connectedSockets;
    dispatch_queue_t multiThread;
    BOOL isServerRunning;
}
@end
