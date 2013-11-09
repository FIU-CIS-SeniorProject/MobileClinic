//
//  ServerCore.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 1/30/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//
#define ARCHIVER        @"archiver"
#define READING_TIMEOUT 10
#define CONNECT_TIMEOUT 5

#import "ServerCore.h"
#import "ObjectFactory.h"

ServerCallback onComplete;

@interface ServerCore (Private)
- (void)connectToNextAddress;
@end

static NSMutableData* majorData;
static ServerCore *sharedMyManager = nil;
static NSTimer* connectionTimer;
static BOOL isProcessing;
static BOOL connectionSuccessful;
static BOOL isShuttingDown;
static BOOL connected;

@implementation ServerCore

+(id)sharedInstance{
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    
    return sharedMyManager;
}

-(id)init{
    if (self=[super init]) {
        isProcessing = NO;
        isShuttingDown = NO;
        netServiceBrowser = [[NSNetServiceBrowser alloc] init];
        [netServiceBrowser setDelegate:self];

    }
    return self;
}

-(void)startClient{
   
    NSLog(@"Client Started Searching");
    
    // If client is not connected, try to connect
    if (!connected) {
        if (!connectionTimer.isValid) {
            [netServiceBrowser searchForServicesOfType:@"_MC-EMR._tcp." inDomain:@"local."];
            
            // Starts Timeout Timer
           [self StartConnectionTimeoutTimer];
        }
    }
    else if (connectionSuccessful) {
            [connectionTimer invalidate];
            [self activateCallBackWithBool:YES andWithError:nil];
    }
}

-(void)StartConnectionTimeoutTimer{
    // If the timer is instantiate it invalidate it just in case
    [connectionTimer invalidate];
    
    connectionTimer = [NSTimer timerWithTimeInterval:CONNECT_TIMEOUT target:self selector:@selector(terminateConnection:) userInfo:nil repeats:NO];
    NSRunLoop* run = [NSRunLoop mainRunLoop];
    
    [run addTimer:connectionTimer forMode:NSDefaultRunLoopMode];
}

-(void)startReadingTimeoutTimer{
    // Invalidate Any timer that could be running
    [connectionTimer invalidate];
    
    // Timeout Timer to prevent Client from hanging while Reading
    connectionTimer = [NSTimer timerWithTimeInterval:READING_TIMEOUT target:self selector:@selector(clearReadBuffer:) userInfo:nil repeats:NO];
    
    // get run loop
    NSRunLoop* run = [NSRunLoop mainRunLoop];
    
    //add timer to run loop
    [run addTimer:connectionTimer forMode:NSDefaultRunLoopMode];
}

-(void)terminateConnection:(NSTimer*)timer{
    // This method is called when the client cannot finish reading
    NSLog(@"Timer Terminated client");

    // By processing = NO, allows system to throw disconnected error if no connection was made
    isProcessing = NO;

    [self stopClient];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)sender didNotSearch:(NSDictionary *)errorInfo
{
    NSLog(@"DidNotSearch: %@", errorInfo);
    [self stopClient];
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindDomain:(NSString *)domainString moreComing:(BOOL)moreComing{
    
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)sender
           didFindService:(NSNetService *)netService
               moreComing:(BOOL)moreServicesComing
{
	NSLog(@"DidFindService: %@", [netService name]);
	
	// Connect to the first service we find
	
	if (serverService == nil)
	{
		NSLog(@"Resolving...");
		
		serverService = netService;
		
		[serverService setDelegate:self];
		[serverService resolveWithTimeout:5.0];
	}
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)sender
         didRemoveService:(NSNetService *)netService
               moreComing:(BOOL)moreServicesComing
{
	NSLog(@"Removing Service: %@", [netService name]);
    
    if ([serverService.name isEqualToString:netService.name]) {
        NSLog(@"Removed Current Service that was in use");
    }
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)sender
{
    NSLog(@"DidStopSearch");
    
    if (!connectionSuccessful && !isProcessing) {
        [self activateCallBackWithBool:NO andWithError:[self createErrorWithDescription:@"Could not connect to server. Please try again or contact your Administrator" andErrorCodeNumber:kErrorDisconnected inDomain:@"Server Core"]];   
    }else if(connectionSuccessful && isProcessing){
        [self activateCallBackWithBool:NO andWithError:[self createErrorWithDescription:@"Could not complete. Please try again or contact your Administrator" andErrorCodeNumber:kError inDomain:@"Server Core"]];
    }
    
    // update connected & Connection Status
    connected = NO;
    connectionSuccessful = NO;
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
	NSLog(@"Did Not Resolve: %@",errorDict.description);

}

- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
	NSLog(@"DidResolve: %@", [sender addresses]);
	
	if (serverAddresses == nil)
	{
		serverAddresses = [[sender addresses] mutableCopy];
	}
	
	if (asyncSocket == nil)
	{
		asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
		[self connectToNextAddress];
	}
}

- (void)connectToNextAddress
{
	BOOL done = NO;
	
	while (!done && ([serverAddresses count] > 0))
	{
		NSData *addr;
		
		// Note: The serverAddresses array probably contains both IPv4 and IPv6 addresses.
		//
		// If your server is also using GCDAsyncSocket then you don't have to worry about it,
		// as the socket automatically handles both protocols for you transparently.
		
		if (YES) // Iterate forwards
		{
			addr = [serverAddresses objectAtIndex:0];
			[serverAddresses removeObjectAtIndex:0];
		}
		else // Iterate backwards
		{
			addr = [serverAddresses lastObject];
			[serverAddresses removeLastObject];
		}
		
		NSLog(@"Attempting connection to %@", addr);
        // Starts Timeout Timer
        [self StartConnectionTimeoutTimer];
		NSError *err = nil;
		if ([asyncSocket connectToAddress:addr error:&err])
		{
			done = YES;
		}
		else
		{
			NSLog(@"Unable to connect: %@", err);
		}
		
	}
	
	if (!done)
	{
		NSLog(@"Unable to connect to any resolved address");
       
	}
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	// Stop the Connect Timeout timer
    [connectionTimer invalidate];
    
    NSLog(@"Socket:DidConnectToHost: %@ Port: %hu", host, port);
    
	[self grabURLInBackground:host];
    
    asyncSocket = sock;

    // Reset the processing status
	isProcessing = NO;
    
    // update connected & Connection status
    connected = YES;
    
    connectionSuccessful = YES;
    
    // Send proper update back to the caller
    [self activateCallBackWithBool:connected andWithError:nil];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
   
    // No Longer Connected
    connected = NO;
    
	NSLog(@"SocketDidDisconnect:WithError: %@", err);
    
    [self connectToNextAddress];
}

-(void)clearReadBuffer:(NSTimer*)timer{
    
    majorData = nil;
    // Pretend the Data on the server Failed. The Connection Was unsuccessfull
    connectionSuccessful = NO;
    // if Processing  = YES, allows the system to throw an error and prompts the user
    // to try again
    isProcessing = YES;
    
    [self stopClient];
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
    if (!majorData) {
        
        NSLog(@"Started Reading Data: %i",data.length);
        
        majorData = [[NSMutableData alloc]initWithData:data];
        
    }else{
        NSLog(@"Appending Data: %i",data.length);
        
        [majorData appendData:data];
    }
    
    @try {

        NSDictionary* myDictionary = [[NSDictionary alloc]initWithDictionary:[self unarchiveToDictionaryFromData:majorData] copyItems:YES];
        
        // Invalidate Reading Timeout timer
        [connectionTimer invalidate];
        
        NSLog(@"Client Recieved: %@",myDictionary.allKeys.description);
        
        // Finished Processing
        isProcessing = NO;
        
        if(myDictionary.allKeys.count > 0) {
            // ObjectFactory: Used to instatiate the proper class but returns it generically
            id<BaseObjectProtocol> obj = [ObjectFactory createObjectForType:myDictionary];
            
            // setup the object to use the dictionary values
            [obj unpackageFileForUser:myDictionary];

            onComplete(obj);    
            
        } else {
            onComplete(nil);
        }

         majorData = nil;
        
        [self StartConnectionTimeoutTimer];

    }
    @catch (NSException *exception) {
        NSLog(@"Restart Timer and Read Again");
        [self startReadingTimeoutTimer];
        [asyncSocket readDataWithTimeout:-1 tag:tag];
    }
}


-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
   
    isProcessing = YES;
   
    [asyncSocket readDataWithTimeout:-1 tag:tag];
    
}

-(NSDictionary*)unarchiveToDictionaryFromData:(NSData*)data{

    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    
    NSDictionary* myDictionary = [unarchiver decodeObjectForKey:ARCHIVER];
    
    [unarchiver finishDecoding];
    
    return myDictionary;
}

-(NSData*)ArchiveDictionary:(NSDictionary*)dictionary{
    
    
    //New mutable data object
    NSMutableData *data = [[NSMutableData alloc] init];
    
    //Created an archiver to serialize dictionary into data object
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
    //encodes the dataToBeSent into data object
    [archiver encodeObject:dictionary forKey:ARCHIVER];
    //finalize archiving
    [archiver finishEncoding];
    
    return data;
}

- (void)sendData:(NSDictionary*)dataToBeSent withOnComplete:(ServerCallback)response
{
    onComplete = response;

	[asyncSocket writeData:[self ArchiveDictionary:dataToBeSent] withTimeout:-1 tag:10];
	
}

-(void)activateCallBackWithBool:(BOOL)status andWithError:(NSError*)error{
    if (connectionStatus) {
        connectionStatus(status,error);
    }
}

-(void)stopClient{

    [netServiceBrowser stop];
    asyncSocket.delegate = nil;
    [asyncSocket disconnect];
    asyncSocket = nil;
    serverService = nil;
    serverAddresses = nil;
}

-(NSInteger)numberOfConnections{
    return serverAddresses.count;
}

-(BOOL)isClientConntectToServer{
    return connected;
}

-(NSString *)getCurrentConnectionName{
    return asyncSocket.connectedHost;
}

- (void)setConnectionStatusHandler:(ClientServerConnect)statusHandler{
    connectionStatus = statusHandler;
}

- (BOOL)isShuttingDown{
    return isShuttingDown;
}

- (BOOL)isProcessing{
    return isProcessing;
}
@end
