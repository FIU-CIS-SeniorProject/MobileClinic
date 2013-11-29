//
//  CloudServiceProtocol.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 3/15/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CloudServiceProtocol <NSObject>

-(void)query:(NSString *)stringQuery parameters: (NSDictionary *)params completion:(void(^)(NSError *error, NSDictionary *result)) completion;

-(void)queryWithPartialURL:(NSString *)partialURL parameters: (NSDictionary *)params imageData:(NSData *)imageData completion:(void(^)(NSError *error, NSDictionary *result)) completion;

-(void)getAccessToken:(void(^)(BOOL success)) completion;
@end
