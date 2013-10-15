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
//  DataProcessor.m
//  OmniOrganize
//
//  Created by Michael Montaque on 9/26/11.
//  Copyright (c) 2011 Florida International University. All rights reserved.
//

#import "DataProcessor.h"

@implementation NSDate (DataProcessor)

-(NSString*)convertNSDateToString
{
    NSDateFormatter *format =[[NSDateFormatter alloc]init];
    [format setDateFormat:@"MMM dd, h:mm aa"];
    return [format stringFromDate:self];
}

+(NSDate*)convertStringToNSDate:(NSString*)string
{
    NSDateFormatter *format =[[NSDateFormatter alloc]init];
    [format setDateFormat:@"MMM dd, h:mm aa"];
    return [format dateFromString:string];
}

+(NSDate *)convertSecondsToNSDate:(NSNumber *)time
{
    return [NSDate dateWithTimeIntervalSince1970:time.integerValue];
}

-(NSNumber *)convertNSDateToSeconds
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:1970];
    [components setMonth:1];
    [components setDay:1];
    [components setHour:-5];
    NSDate* date = [calendar dateFromComponents:components];
    
    return [NSNumber numberWithInteger:[self timeIntervalSinceDate:date]];
}

-(NSString*)convertNSDateFullBirthdayString
{
    NSDateFormatter *format =[[NSDateFormatter alloc]init];
    [format setDateFormat:@"MMMM dd, yyyy"];
    return [format stringFromDate:self];
}

-(NSString*)convertNSDateToTimeString
{
    NSDateFormatter *format =[[NSDateFormatter alloc]init];
    [format setDateFormat:@"h:mm aa"];
    return [format stringFromDate:self];
}

-(NSInteger)getNumberOfYearsElapseFromDate
{
    NSDate* now = [NSDate date];
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                       components:NSYearCalendarUnit
                                       fromDate:self
                                       toDate:now
                                       options:0];
   return [ageComponents year];
}

-(NSString*)convertNSDateToMonthNumDayString
{
    NSDateFormatter *format =[[NSDateFormatter alloc]init];
    [format setDateFormat:@"MMM dd"];
    return [format stringFromDate:self];
}
@end