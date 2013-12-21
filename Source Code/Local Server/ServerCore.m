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
//  ServerCore.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 1/30/13.
//  Modified by James Mendez on 12/2013
//
#define ARCHIVER    @"archiver"
#define SERVER_TYPE @"_MC-EMR._tcp."
#define LOCAL_DOMAIN      @"local."

#import "ServerCore.h"
#import "ObjectFactory.h"
#import "StatusObject.h"
#import "NSData+GZIP.h"

ServerCommand onComplete;
static int TIMEOUT;
NSMutableArray* dataBuffer;
NSMutableData* majorData;
NSNetServiceBrowser *netServiceBrowser;
NSTimer* searchTimer;
NSRunLoop* runLoop;
BOOL isSearchingForServers;
BOOL shouldRunServer;

@implementation ServerCore

@synthesize isServerRunning;

+(id)sharedInstance
{
    static ServerCore *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
        TIMEOUT = -1;
    });
    
    return sharedMyManager;
}

-(id)init
{
    if (self=[super init])
    {
        multiThread = dispatch_queue_create("mainScreen", NULL);
        netServiceBrowser = [[NSNetServiceBrowser alloc] init];
        [netServiceBrowser setDelegate:self];
        isServerRunning = NO;
    }
    return self;
}

-(void)start
{
    isSearchingForServers = YES;
    
    shouldRunServer = YES;
    NSLog(@"Searching for %@ servers on %@ domain",SERVER_TYPE,LOCAL_DOMAIN);
    
    //[netServiceBrowser searchForServicesOfType:@"" inDomain:LOCAL_DOMAIN];
    [netServiceBrowser searchForBrowsableDomains];
    searchTimer = [NSTimer timerWithTimeInterval:3 target:self selector:@selector(startServer:) userInfo:nil repeats:NO];
    runLoop = [NSRunLoop mainRunLoop];
    [runLoop addTimer:searchTimer forMode:NSDefaultRunLoopMode];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)sender didNotSearch:(NSDictionary *)errorInfo
{
	NSLog(@"DidNotSearch: %@\n\nWill not start server", errorInfo);
    isSearchingForServers = NO;
    shouldRunServer = NO;
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindDomain:(NSString *)domainString moreComing:(BOOL)moreComing
{
    NSLog(@"Found server %@ on domain %@\n\n ", [netService name],domainString);
    
    if ([[netService name] isEqualToString:SERVER_TYPE])
    {
        [NSApp presentError:[NSError errorWithDomain:@"ServerCore" code:-2 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Found a similar server on the same domain. To start this server, please locate and shutdown the other server",NSLocalizedFailureReasonErrorKey, nil]]];
        shouldRunServer = NO;
        isSearchingForServers = NO;
    }
}

-(void)startServer:(NSTimer*)theTimer
{
    if (isSearchingForServers)
    {
        [netServiceBrowser stop];
        isSearchingForServers = NO;
    }
    
    if (!isServerRunning && shouldRunServer)
    {
        asyncSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        // Create an array to hold accepted incoming connections.
        
        connectedSockets = [[NSMutableArray alloc] init];
        
        // Now we tell the socket to accept incoming connections.
        // We don't care what port it listens on, so we pass zero for the port number.
        // This allows the operating system to automatically assign us an available port.
        
        NSError *err = nil;
        if ([asyncSocket acceptOnPort:0 error:&err])
        {
            // So what port did the OS give us?
            
            UInt16 port = [asyncSocket localPort];
            
            // Create and publish the bonjour service.
            // Obviously you will be using your own custom service type.
            
            netService = [[NSNetService alloc] initWithDomain:@"local."
                                                         type:@"_MC-EMR._tcp."
                                                         name:@""
                                                         port:port];
            
            [netService setDelegate:self];
            [netService publish];
            
            // You can optionally add TXT record stuff
            
            NSMutableDictionary *txtDict = [NSMutableDictionary dictionaryWithCapacity:2];
            
            [txtDict setObject:@"moo" forKey:@"cow"];
            [txtDict setObject:@"quack" forKey:@"duck"];
            
            NSData *txtData = [NSNetService dataFromTXTRecordDictionary:txtDict];
            [netService setTXTRecordData:txtData];
        }
    }
}

-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"Connected with Client");
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
	NSLog(@"Accepted new socket from %@:%hu", [newSocket connectedHost], [newSocket connectedPort]);
	
	// The newSocket automatically inherits its delegate & delegateQueue from its parent.
    [newSocket readDataWithTimeout:-1 tag:0];
	[connectedSockets addObject:newSocket];
    [self fireObservation];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
	[connectedSockets removeObject:sock];
    [self fireObservation];
}

- (void)netServiceDidPublish:(NSNetService *)ns
{
    isServerRunning = YES;
	NSLog(@"Bonjour Service Published: domain(%@) type(%@) name(%@) port(%i)",
          [ns domain], [ns type], [ns name], (int)[ns port]);
    [self fireStatus:0];
}

- (void)netService:(NSNetService *)ns didNotPublish:(NSDictionary *)errorDict
{
	// Override me to do something here...
	// Note: This method in invoked on our bonjour thread.
	NSLog(@"Failed to Publish Service: domain(%@) type(%@) name(%@) - %@",
          [ns domain], [ns type], [ns name], errorDict);
}

-(NSDictionary*)unarchiveToDictionaryFromData:(NSData*)data
{
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDictionary* myDictionary = [unarchiver decodeObjectForKey:ARCHIVER];
    [unarchiver finishDecoding];
    return myDictionary;
}

-(NSData*)ArchiveDictionary:(NSDictionary*)dictionary
{
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

/** This will be called when the data is not flushing properly
 * This method will clear the data and send a message to the device that is
 * waiting on the information
 */
-(void)flushDataBuffer:(NSTimer*)theTimer
{
    // Get the offending client that 
    GCDAsyncSocket* sock = [theTimer.userInfo objectForKey:@"socket"];
    
    // Create a status to send back to client
    StatusObject* status = [[StatusObject alloc]init];
    
    // Setup Error message
    [status setErrorMessage:@"Please Retry. If this error persist please restart the server"];
    
    // set Error value code
    [status setStatus:kError];
    
    // Create a dictionary to send
    NSDictionary* dict = [status consolidateForTransmitting];
    
    // Send the information back to client
    [sock writeData:[self ArchiveDictionary:dict] withTimeout:TIMEOUT tag:kError];

    // Invalidate Timer
    [theTimer invalidate];
    
    // Clear the data Buffer
    majorData = nil;
    
    [sock disconnectAfterWriting];
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"Server did accept data %li",data.length);
    
    if (!majorData)
    {
        majorData = [[NSMutableData alloc]initWithData:data];
        searchTimer = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(flushDataBuffer:) userInfo:[NSDictionary dictionaryWithObjectsAndKeys:sock,@"socket", nil] repeats:NO];
        
        runLoop = [NSRunLoop mainRunLoop];
        [runLoop addTimer:searchTimer forMode:NSDefaultRunLoopMode];
    }
    else
    {
        [majorData appendData:data];
    }
    
    @try
    {
        NSDictionary* myDictionary = [[NSDictionary alloc]initWithDictionary:[self unarchiveToDictionaryFromData:majorData] copyItems:YES];
 
        NSLog(@"Server Recieved: %@",myDictionary.allKeys.description);
        
        if(myDictionary && myDictionary.allKeys.count > 0)
        {
            [searchTimer invalidate];
            // ObjectFactory: Used to instatiate the proper class but returns it generically
        
            id<BaseObjectProtocol> factoryObject = [ObjectFactory createObjectForType:myDictionary];
            
            [factoryObject ServerCommand:myDictionary withOnComplete:^(NSDictionary *dataToBeSent)
            {
                //send data
                NSLog(@"Server Will Send:%@ \n%li Bytes",dataToBeSent.allKeys.description,data.length);
                [sock writeData:[self ArchiveDictionary:dataToBeSent] withTimeout:TIMEOUT tag:10];
                majorData = nil;
            }];
        }
        else
        {
            majorData = nil;
        }
    }
    @catch (NSException *exception)
    {
        [sock readDataWithTimeout:TIMEOUT tag:tag];
    }
}

-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"Server is now Listening for Data");
    [sock readDataWithTimeout:TIMEOUT tag:tag];
}

-(NSString*)getHostNameForSocketAtIndex:(NSInteger)index
{
    GCDAsyncSocket* sock = [connectedSockets objectAtIndex:index];
    return [sock connectedHost];
}

-(NSString*)getPortForSocketAtIndex:(NSInteger)index
{
    GCDAsyncSocket* sock = [connectedSockets objectAtIndex:index];
    return [NSString stringWithFormat:@"%hu",sock.connectedPort];
}

-(void)stopServer
{
    if (isServerRunning)
    {
        for (GCDAsyncSocket* sock in connectedSockets)
        {
            [sock disconnect];
        }
        [netService stop];
    }
}

-(void)netServiceDidStop:(NSNetService *)sender
{
    NSLog(@"Server Has Been Turned Off");
    isServerRunning = NO;
    [self fireStatus:1];
}

-(NSInteger)numberOfConnections
{
    return connectedSockets.count;
}

-(void)fireObservation
{
    [[NSNotificationCenter defaultCenter]postNotificationName:SERVER_OBSERVER object:nil];
}

-(void)fireStatus:(int)status
{
    [[NSNotificationCenter defaultCenter]postNotificationName:SERVER_STATUS object:[NSNumber numberWithInt:status]];
}
@end