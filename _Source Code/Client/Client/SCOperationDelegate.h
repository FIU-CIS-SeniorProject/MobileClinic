//
//  SCOperationDelegate.h
//  StudentConnect
//
//  Created by Michael Montaque on 5/23/12.
//  Copyright (c) 2012 Florida International University. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SCOperationDelegate <NSObject>

-(void)operationFailedFrom:(id)hostClass withError:(NSError*)error;

-(void)operationDidSucceedFrom:(id)hostClass withObject:(id)object;

@end
