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
//  BaseObject+Protected.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 3/21/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//
#define ISDIRTY @"isDirty"
#import "BaseObject.h"
#import "StatusObject.h"

@interface BaseObject (Protected)

// Directly Pushes the information into the ServerCore but checks to see if connection is available
-(void)tryAndSendData:(NSDictionary*)data withErrorToFire:(ObjectResponse)negativeResponse andWithPositiveResponse:(ServerCallback)posResponse;


// Updates the given object and executes the given instruction on the server side
-(void)UpdateObject:(ObjectResponse)response shouldLock:(BOOL)shouldLock andSendObjects:(NSMutableDictionary*)dataToSend withInstruction:(NSInteger)instruction;
// Sends data to the ServerCore to be sent to the Server
-(void)SendData:(NSDictionary*)data toServerWithErrorMessage:(NSString*)msg andResponse:(ObjectResponse)Response;

// Common Method for for all classes that extends the BaseObject to use for searching
-(void)startSearchWithData:(NSDictionary*)data withsearchType:(RemoteCommands)rCommand andOnComplete:(ObjectResponse)response;

// Given an array of NSManagedObjects, it will create an array of dictionaries from it
-(NSMutableArray*)convertListOfManagedObjectsToListOfDictionaries:(NSArray*)managedObjects;

// Given a dictionary, the object it represents will be created/updated in the database
-(void)SaveListOfObjectsFromDictionary:(NSDictionary*)patientList;

- (BOOL) isConnectedToServer;

-(NSMutableDictionary*)getDictionaryValuesFromManagedObject:(NSManagedObject*)object;
@end