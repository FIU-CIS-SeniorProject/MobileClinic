//
//  ServerCore.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 1/30/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@interface ServerCore : NSObject <GCDAsyncSocketDelegate,NSNetServiceDelegate> {
    NSNetService *netService;
	GCDAsyncSocket *asyncSocket;
    NSMutableData* globalData;
	NSMutableArray *connectedSockets;
    dispatch_queue_t multiThread;
}
@property(assign) BOOL isServerRunning;
+(id)sharedInstance;
-(void)stopServer;
-(void)startServer;
-(NSString*)getCurrentConnectionName;
- (void)sendData:(NSDictionary*)dataToBeSent toClient:(GCDAsyncSocket*)sock;
- (NSInteger)numberOfConnections;
@end
