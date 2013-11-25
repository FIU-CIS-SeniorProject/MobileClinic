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
//  DatabaseDriverProtocol.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 2/25/13.
//
#import <Foundation/Foundation.h>

@protocol DatabaseDriverProtocol <NSObject>

// Use this to retrieve objects/values from the Patient object.
// @param attribute the name of the attribute you want to retrieve.
// @param DBObject the object to get the value from
-(id)getObjectForAttribute:(NSString*)attribute inDatabaseObject:(NSManagedObject*)DBObject;

// Use this to save attributes of the object. For instance, to the Patient's Firstname can be saved by passing the string of his name and the Attribute FIRSTNAME
// @param object object that needs to be stored in the database
// @param attribute the name of the attribute or the key to which the object needs to be saved
// @param DBObject the Core data object to modify its attribute
-(void)setObject:(id)object withAttribute:(NSString*)attribute inDatabaseObject:(NSManagedObject*)DBObject;
-(BOOL)deleteObjectFromDatabase:(NSString*)table withDefiningAttribute:(NSString*)attrib forKey:(NSString*)key;
-(BOOL)deleteNSManagedObject:(NSManagedObject*)object;
@end