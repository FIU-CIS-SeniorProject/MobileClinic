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
//  ConnectListContent.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 1/28/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import "ConnectListContent.h"

@implementation ConnectListContent
@synthesize user;
/*
-(void)viewWillDraw
{
    if (!appDelegate)
    {
        NSString* username;
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(displayUserInformation:) name:SAVE_USER object:username];
        
        // Called when the user taps a user Row
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayUserInformation:) name:SELECTED_A_USER object:username];
        
        appDelegate = (FIUAppDelegate*)[[NSApplication sharedApplication]delegate];
    }
}

-(void)displayUserInformation:(NSNotification*)note
{
    user = [[UserObject alloc]initWithCachedObjectWithUpdatedObject:note.object];
    
    [_username setStringValue:[user getObjectForAttribute:USERNAME]];
    [_email setStringValue:[user getObjectForAttribute:EMAIL]];
    [_Password setStringValue:[user getObjectForAttribute:PASSWORD]];
    [_userTypeBox selectItemAtIndex:[[user getObjectForAttribute:USERNAME]integerValue]];
    [_isActiveSegment setSelectedSegment:([[user getObjectForAttribute:STATUS]boolValue])?1:0];
}
 
-(void)AuthorizeUser:(id)sender
{
    NSSegmentedControl* seg = sender;
    [user setObject:[NSNumber numberWithBool:(seg.selectedSegment == 1)?YES:NO] withAttribute:STATUS ];
}

-(void)CommitNewUserInfo:(id)sender
{
    [user saveObject:^(id<BaseObjectProtocol> data, NSError* error)
    {
#warning Create an error;
        if (error)
        {
           NSLog(@"ERROR: %@",error.localizedDescription);
        }
        else
        {
           NSLog(@"SaveComplete: %@",[data description]);
           [[NSNotificationCenter defaultCenter]postNotificationName:SAVE_USER object:[data getObjectForAttribute:USERNAME]];
        }
    }];
}*/
@end