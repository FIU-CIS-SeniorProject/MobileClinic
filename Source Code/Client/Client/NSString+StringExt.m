//
//  NSString+StringExt.m
//  StudentConnect
//
//  Created by Michael Montaque on 5/20/12.
//  Copyright (c) 2012 Florida International University. All rights reserved.
//

#import "NSString+StringExt.h"

@implementation NSString (StringExt)

-(BOOL)isMinimumLength{
    return (self.length > 7);
}
-(BOOL)isNotEmpty{
    return (self.length > 0); 
}
-(BOOL)isValidEmailAddress{
  
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
   
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
   
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];

    return [emailTest evaluateWithObject:self];
}

-(BOOL)isValidURL{
    return YES;
}

-(NSString *)StringWithNoIllegalCharacters{
    
    NSString* noSpaceOrEnter = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString* noIllegalCharacter = [noSpaceOrEnter stringByTrimmingCharactersInSet:[NSCharacterSet symbolCharacterSet]];
    
    return noIllegalCharacter;
}

-(NSString *)capitalizeFirstLetterOfEachWord{
   //Remove White Space and new lines from both ends
    NSString* trimmed = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    //Turn string into an array of words
    NSArray *stringArray = [trimmed componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSMutableArray* words = [[NSMutableArray alloc]initWithCapacity:stringArray.count];
    
    //iterate, Capitalizing first letter
    for (NSString* word in stringArray) {
    [words addObject: [word stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[word substringToIndex:1] uppercaseString]]];
    }
    //Past string together and return
    return [words componentsJoinedByString:@" "];
                           
}
-(NSString*)getFileTypeFromPath{
    //Split Name by "." to isolate the end
    NSArray* fileComponents = [self componentsSeparatedByString:@"."];
    //get the end (the Type)
    return [fileComponents lastObject];
}

+(NSString*)getDownloadPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return  [paths lastObject];
}

+(NSString *)createFilepathInDocumentsDirectoryWithName:(NSString *)name{
    
    return [[self getDocumentPath] stringByAppendingPathComponent:name];
}

+(NSString *)getDocumentPath{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return  [paths objectAtIndex:0];
}

-(BOOL)contains:(NSString *)string{
    
    if ([self rangeOfString:string].location == NSNotFound) {
        return NO;
    } else {
        return YES;
    }
}
@end
