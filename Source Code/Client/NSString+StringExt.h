//
//  NSString+StringExt.h
//  StudentConnect
//
//  Created by Michael Montaque on 5/20/12.
//  Copyright (c) 2012 Florida International University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (StringExt)

-(BOOL)isMinimumLength;
-(BOOL)isNotEmpty;
-(BOOL)isValidEmailAddress;
-(BOOL)isValidURL;

-(NSString*)getFileTypeFromPath;
-(NSString*)StringWithNoIllegalCharacters;
-(NSString*)capitalizeFirstLetterOfEachWord;
+(NSString *)createFilepathInDocumentsDirectoryWithName:(NSString *)name;
-(BOOL)contains:(NSString*)string;
+(NSString*)getDocumentPath;
+(NSString*)getDownloadPath;
@end
