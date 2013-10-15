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
//  DatabaseDriver.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 2/1/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//
#define OBJECTID          @"objectId"
#import <Foundation/Foundation.h>
#import "Database.h"
#import "DatabaseDriverProtocol.h"

@interface DatabaseDriver : NSObject<DatabaseDriverProtocol>

@property(nonatomic, strong) id<DatabaseProtocol> database;

-(id)init;
-(NSManagedObject*)CreateANewObjectFromClass:(NSString *)name isTemporary:(BOOL)temporary;
-(void)SaveCurrentObjectToDatabase;
-(void)SaveAndRefreshObjectToDatabase:(NSManagedObject*)object;
-(NSArray *)FindObjectInTable:(NSString *)table withCustomPredicate:(NSPredicate *)predicateString andSortByAttribute:(NSString*)attribute;
-(NSArray*)FindObjectInTable:(NSString*)table withName:(id)name forAttribute:(NSString*)attribute;
@end