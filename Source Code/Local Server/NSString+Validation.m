//
//  NSString+Validation.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 2/3/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import "NSString+Validation.h"

@implementation NSString (Validation)

- (BOOL) isAlphaNumeric
{
    NSCharacterSet *unwantedCharacters =
    [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    
    return ([self rangeOfCharacterFromSet:unwantedCharacters].location == NSNotFound) ? YES : NO;
}
-(BOOL)contains:(NSString *)string{

    if ([self rangeOfString:string].location == NSNotFound) {
        return NO;
    } else {
        return YES;
    }
}
@end
