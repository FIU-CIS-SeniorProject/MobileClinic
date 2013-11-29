//
//  StatusObject.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 1/27/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//
#define ERRORMSG    @"errormsg"
#import "StatusObject.h"

@implementation StatusObject


-(void)unpackageFileForUser:(NSDictionary *)data{
    _errorMessage = [data objectForKey:ERRORMSG];
    _data = [data objectForKey:DATA];
    self.objectType = [[data objectForKey:OBJECTTYPE]intValue];
    _status = [[data objectForKey:STATUS]intValue];
    _commands = [[data objectForKey:OBJECTCOMMAND]intValue];
}

@end
