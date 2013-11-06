//
//  NSObject+CustomTools.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 2/5/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import "NSObject+CustomTools.h"

@implementation NSObject (CustomTools)

-(NSError *)createErrorWithDescription:(NSString *)description andErrorCodeNumber:(int)code inDomain:(NSString*)domain{
    
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    
    [details setValue:description forKey:NSLocalizedDescriptionKey];
    
    return [[NSError alloc]initWithDomain:domain code:code userInfo:details];
}
@end
