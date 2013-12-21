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
//  ServerWrapper.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 1/27/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//
#define ARCHIVER    @"archiver"
#define CONNECTID   @"_MC-EMR._tcp."

#import "ServerWrapper.h"
#import "ObjectFactory.h"

BOOL isServerRunning;
@implementation ServerWrapper
@synthesize currentConnectionIndex;

+(id)sharedServerManager
{
    static ServerWrapper *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    
    return sharedMyManager;
}

-(id)init
{
    if (self = [super init])
    {
        isServerRunning = NO;
        _devices = [[NSMutableArray alloc]initWithCapacity:5];

        server = [[Server alloc] initWithProtocol:@"MC-EMR"];
        
        [server setDelegate:self];
        
        NSError *error = nil;
        
        NSLog(@"ServerWrapper init: Change Implementation to show Error Globally ad solution");
        
        if(![server start:&error])
        {
            NSLog(@"error = %@", error);
        }
    }
    return self;
}

#pragma mark-
#pragma mark Getter's & Setter's

-(NSString*)getCurrentConnectionName
{
    return [[_devices objectAtIndex:currentConnectionIndex] name];
}

#pragma mark-
#pragma mark Intermediating Methods
-(NSDictionary*)unarchiveToDictionaryFromData:(NSData*)data
{
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    
    NSDictionary* myDictionary = [unarchiver decodeObjectForKey:ARCHIVER];
    
    [unarchiver finishDecoding];
    
    return myDictionary;
}

-(void)startServer
{
    NSError *error = nil;
    
    NSLog(@"ServerWrapper StartServer: Change Implementation to show Error Globally ad solution");
    if(![server start:&error])
    {
        NSLog(@"error = %@", error);
    }
}

-(void)stopServer
{
    [server stop];
    [server stopBrowser];
}

- (void)sendData:(NSDictionary*)dataToBeSent;
{
    //New mutable data object
    NSMutableData *data = [[NSMutableData alloc] init];
    
    //Created an archiver to serialize dictionary into data object
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    //encodes the dataToBeSent into data object
    [archiver encodeObject:dataToBeSent forKey:@"Some Key Value"];
    //finalize archiving
    [archiver finishEncoding];
    //send data
	NSError *error = nil;
    
	[server sendData:data error:&error];
}

- (void)connectToServiceAtSelectedIndex:(NSInteger)selectedRow
{
	[server connectToRemoteService:[_devices objectAtIndex:selectedRow]];
}

#pragma mark Server Delegate Methods

- (void)serverRemoteConnectionComplete:(Server *)server
{
    NSLog(@"Connected to service");
    
    //	self.isConnectedToService = YES;
    
	//currentConnectionIndex = selectedRow;
    
}

-(void)serverStopped:(Server *)server
{
    NSLog(@"Disconnected from service");
    
	//self.isConnectedToService = NO;
    
	//connectedRow = -1;
	//[tableView reloadData];
}

- (void)serviceAdded:(NSNetService *)service moreComing:(BOOL)more
{
	 NSLog(@"Incoming Service Type: %@", [service type]);

        NSLog(@"Added a Device: %@", [service name]);
    
        [_devices addObject:service];

}

- (void)server:(Server *)server didNotStart:(NSDictionary *)errorDict
{
    NSLog(@"Server did not start %@", errorDict);
}

//Once information is recieved, If Valid server will send a success response to the client. Otherwise an error message is sent.
- (void)server:(Server *)server didAcceptData:(NSData *)data
{
    NSLog(@"Server did accept data %li",data.length);
  
    NSDictionary* myDictionary = [[NSDictionary alloc]initWithDictionary:[self unarchiveToDictionaryFromData:data] copyItems:YES];

    id obj;
    
    if(data) {
        // ObjectFactory: Used to instatiate the proper class but returns it generically
        obj = [ObjectFactory createObjectForType:myDictionary];
    
        // setup the object to use the dictionary values
      //  [obj unpackageFileForUser:myDictionary];
        
        NSLog(@"Dictionary: %@",[obj description]);


    }
    else
    {
        NSLog(@"Write Error in Log: Recieved No data");
    }
}

- (void)server:(Server *)server lostConnection:(NSDictionary *)errorDict
{
	NSLog(@"Lost connection");
//	self.isConnectedToService = NO;
//	connectedRow = -1;
//	[tableView reloadData];
}

- (void)serviceRemoved:(NSNetService *)service moreComing:(BOOL)more
{
	NSLog(@"Removed a service: %@", [service name]);
    [_devices removeObject:service];
//    if(!more)
//   {
//        [tableView reloadData];
//    }
}
@end