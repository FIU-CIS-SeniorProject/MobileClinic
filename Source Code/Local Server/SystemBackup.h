//
//  SystemBackup.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 4/15/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SystemBackup : NSObject

-(id)init;
+(void)installFromBackup:(NSDictionary*)allObjects;
+(NSError*)exportObject:(NSDictionary*)object toFilePath:(NSString*)path;
+(NSDictionary*)GetAllValuesFromBackUp;
-(NSError*)BackupEverything;
@end
