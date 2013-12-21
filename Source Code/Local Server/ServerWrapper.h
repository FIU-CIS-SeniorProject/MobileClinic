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
//  ServerWrapper.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 1/27/13.
//
#define UPDATE_NUMBER_OF_CONNECTIONS    @"update Connections"
#import <Foundation/Foundation.h>
#import "Server.h"
// Object that hold the necessary data for the classes to use
typedef void (^ServerObject)(NSDictionary* data, NSString* error);

@interface ServerWrapper : NSObject<ServerDelegate>
{
    Server* server; 
}
@property(nonatomic, strong)NSMutableArray* devices;
@property(nonatomic, assign)int currentConnectionIndex;
//Singleton
+ (id)sharedServerManager;
-(id)init;
-(NSString*)getCurrentConnectionName;
-(void)stopServer;
-(void)startServer;
- (void)connectToServiceAtSelectedIndex:(NSInteger)selectedRow;
- (void)sendData:(NSDictionary*)dataToBeSent;
@end