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
//  StatusObject.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 1/27/13.
//
#define ERRORMSG    @"errormsg"
#import "StatusObject.h"

@implementation StatusObject

#pragma mark - BaseObjectProtocol Method
#pragma mark -
-(NSDictionary *)consolidateForTransmitting
{
    NSMutableDictionary* consolidate = [[NSMutableDictionary alloc]initWithCapacity:5];
   
    [consolidate setValue:_errorMessage forKey:ERRORMSG];
    if (_data)
    {
        [consolidate setValue:_data forKey:DATA];
    }
    [consolidate setValue:[NSNumber numberWithInt:_status] forKey:STATUS];
    [consolidate setValue:[NSNumber numberWithInt:kStatusType] forKey:OBJECTTYPE];
    [consolidate setValue:[NSNumber numberWithInt:kStatusClientWillRecieve] forKey:OBJECTCOMMAND];
    
    return consolidate;
}

-(void)unpackageFileForUser:(NSDictionary *)data
{
    _errorMessage = [data objectForKey:ERRORMSG];
    _data = [data objectForKey:DATA];
    self.objectType = [[data objectForKey:OBJECTTYPE]intValue];
    _status = [[data objectForKey:STATUS]intValue];
    _commands = [[data objectForKey:OBJECTCOMMAND]intValue];
}

/* Does not need to be implemented  on the client side */
-(void)saveObject:(ObjectResponse)eventResponse{
    NSLog(@"SaveObject Method has not been implemented");
}

-(void)CommonExecution
{

}

#pragma mark - Private Methods
#pragma mark -

@end