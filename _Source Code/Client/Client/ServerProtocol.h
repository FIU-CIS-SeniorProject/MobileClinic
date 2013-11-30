//
//  ServerProtocol.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 2/3/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StatusObject.h"

typedef void (^ClientServerConnect) (BOOL isConnected, NSError* errorMessage);

typedef void (^ServerCallback)(id data);

@protocol ServerProtocol <NSObject>

@required
+ (id)sharedInstance;
- (void) startClient;
- (void) stopClient;
- (BOOL) isShuttingDown;
- (BOOL) isProcessing;
- (void) sendData:(NSDictionary*)dataToBeSent withOnComplete:(ServerCallback)response;
- (BOOL) isClientConntectToServer;
- (void) setConnectionStatusHandler:(ClientServerConnect)statusHandler;
@end
