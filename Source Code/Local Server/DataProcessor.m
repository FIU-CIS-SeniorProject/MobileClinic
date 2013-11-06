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
+(NSDate *)convertSecondsToNSDate:(NSNumber *)time{
    NSTimeZone* timeZone = [NSTimeZone defaultTimeZone];
    return [NSDate dateWithTimeIntervalSince1970:time.integerValue - timeZone.secondsFromGMT] ;
}
-(NSNumber *)convertNSDateToSeconds{
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    [components setYear:1970];
    [components setMonth:1];
    [components setDay:1];
    
    NSDate* date = [calendar dateFromComponents:components];
   
    return [NSNumber numberWithInteger:[self timeIntervalSinceDate:date]];
}

+(NSDate*)convertStringToNSDate:(NSString*)string{
    
    NSDateFormatter *format =[[NSDateFormatter alloc]init];
    
    [format setDateFormat:@"MMM dd, h:mm aa"];
    
    return [format dateFromString:string];
    
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
-(NSString*)convertNSDateToMonthDayYearTimeString{
    
    NSDateFormatter *format =[[NSDateFormatter alloc]init];
    [format setDateFormat:@"MMMM dd, yyyy h:mm aa"];
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
