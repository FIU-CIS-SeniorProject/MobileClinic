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
//  CommonObjectProtocol.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 3/11/13.
//
#import "BaseObjectProtocol.h"
#import <Foundation/Foundation.h>

@protocol CommonObjectProtocol <NSObject>

+(NSString*)DatabaseName;

-(void)associateObjectToItsSuperParent:(NSDictionary *)parent;
-(void)createNewObject:(NSDictionary*) object onCompletion:(ObjectResponse)onSuccessHandler;
-(NSArray *)FindAllObjectsLocallyFromParentObject:(NSDictionary*)parentObject;
-(void)FindAllObjectsOnServerFromParentObject:(NSDictionary*)parentObject OnCompletion:(ObjectResponse)eventResponse;

//Updates the given object and executes the given instruction on the server side
-(void)UpdateObjectAndShouldLock:(BOOL)shouldLock witData:(NSMutableDictionary*)dataToSend AndInstructions:(NSInteger)instruction onCompletion:(ObjectResponse)response;
@end