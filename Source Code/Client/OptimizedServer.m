//
//  OptimizedServer.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 5/8/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import "OptimizedServer.h"
static OptimizedServer *sharedMyManager = nil;
@implementation OptimizedServer

+(id)sharedInstance{
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    
    return sharedMyManager;
}


@end
