//
//  DataProcessor.h
//  OmniOrganize
//
//  Created by Michael Montaque on 9/26/11.
//  Copyright (c) 2011 Florida International University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (DataProcessor) 

-(NSString*)convertNSDateToString;
-(NSNumber *)convertNSDateToSeconds;
-(NSString*)convertNSDateToMonthNumDayString;
-(NSString*)convertNSDateFullBirthdayString;
-(NSString*)convertNSDateToTimeString;
-(NSString*)convertNSDateToMonthDayYearTimeString;
+(NSDate*)convertStringToNSDate:(NSString*)string;
+(NSDate*)convertSecondsToNSDate:(NSNumber*)time;
-(NSInteger)getNumberOfYearsElapseFromDate;
@end
