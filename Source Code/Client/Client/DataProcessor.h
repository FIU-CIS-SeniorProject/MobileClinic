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

-(NSString*)convertNSDateToMonthNumDayString;
-(NSString*)convertNSDateFullBirthdayString;
-(NSString*)convertNSDateToTimeString;
+(NSDate *)convertSecondsToNSDate:(NSNumber *)time;
-(NSNumber *)convertNSDateToSeconds;
+(NSDate*)convertStringToNSDate:(NSString*)string;
-(NSString*)convertNSDateToMonthDayYearTimeString;
-(NSInteger)getNumberOfYearsElapseFromDate;
@end
