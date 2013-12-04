//
//  DataProcessor.m
//  OmniOrganize
//
//  Created by Michael Montaque on 9/26/11.
//  Copyright (c) 2011 Florida International University. All rights reserved.
//

#import "DataProcessor.h"

@implementation NSDate (DataProcessor)

-(NSString*)convertNSDateToString{
    NSDateFormatter *format =[[NSDateFormatter alloc]init];
    [format setDateFormat:@"MMM dd, h:mm aa"];
    return [format stringFromDate:self];
}

+(NSDate*)convertStringToNSDate:(NSString*)string{
    NSDateFormatter *format =[[NSDateFormatter alloc]init];
    [format setDateFormat:@"MMM dd, h:mm aa"];
    return [format dateFromString:string];
}

+(NSDate *)convertSecondsToNSDate:(NSNumber *)time{
    // Accounting for the user's time zone
    NSTimeZone* timeZone = [NSTimeZone localTimeZone];
    
    return [NSDate dateWithTimeIntervalSince1970:time.integerValue - timeZone.secondsFromGMT];
}
-(NSString*)convertNSDateToMonthDayYearTimeString{
    
    NSDateFormatter *format =[[NSDateFormatter alloc]init];
    [format setDateFormat:@"MMMM dd, yyyy h:mm aa"];
    return [format stringFromDate:self];
}

-(NSNumber *)convertNSDateToSeconds{
    // We do not want ot account for timezones here because if the system is used in a different area the calculations will be off.
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    [components setYear:1970];
    [components setMonth:1];
    [components setDay:1];
    [components setHour:0]; // Default Standard, Not accounting for user's Time zones
    NSDate* date = [calendar dateFromComponents:components];
    
    return [NSNumber numberWithInteger:[self timeIntervalSinceDate:date]];
}

-(NSString*)convertNSDateFullBirthdayString{
    NSDateFormatter *format =[[NSDateFormatter alloc]init];
    [format setDateFormat:@"MMMM dd, yyyy"];
    return [format stringFromDate:self];
}

-(NSString*)convertNSDateToTimeString{
    NSDateFormatter *format =[[NSDateFormatter alloc]init];
    [format setDateFormat:@"h:mm aa"];
    return [format stringFromDate:self];
}

-(NSInteger)getNumberOfYearsElapseFromDate{

    NSDate* now = [NSDate date];
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                       components:NSYearCalendarUnit
                                       fromDate:self
                                       toDate:now
                                       options:0];
   return [ageComponents year];
}

-(NSString*)convertNSDateToMonthNumDayString{
    NSDateFormatter *format =[[NSDateFormatter alloc]init];
    [format setDateFormat:@"MMM dd"];
    return [format stringFromDate:self];
}

@end
