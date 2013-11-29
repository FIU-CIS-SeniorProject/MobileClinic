//
//  HTTPCore.m
//  MobileClinic
//
//  Created by Michael Montaque on 1/31/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import "HTTPCore.h"
#import "ASIHTTPRequest.h"
@implementation HTTPCore

- (void)grabURLInBackground:(id)sender
{
    NSURL *url = [NSURL URLWithString:sender];
    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setCompletionBlock:^{
        // Use when fetching text data
        NSString *responseString = [request responseString];
        
        // Use when fetching binary data
        NSData *responseData = [request responseData];
        NSLog(@"ResponseFromURL: %@",responseString);
    }];
    [request setFailedBlock:^{
        NSError *error = [request error];
    }];
    [request startAsynchronous];
}
@end
