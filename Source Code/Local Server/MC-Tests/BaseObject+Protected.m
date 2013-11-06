//
//  BaseObject+Protected.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 4/5/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import "BaseObject.h"

#import <GHUnit/GHUnit.h>

@interface BaseObject_Protected : GHTestCase {
    id<BaseObjectProtocol> underTest;
    NSMutableDictionary* testObject;
}
@end

@implementation BaseObject_Protected

/** @test 
 */
-(void)testSavingTheCommandSentFromClient{
    [underTest ServerCommand:testObject withOnComplete:^(NSDictionary *dataToBeSent) {
        
    }];
}



@end
