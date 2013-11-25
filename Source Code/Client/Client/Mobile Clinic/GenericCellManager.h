//
//  GenericCellManager.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 4/30/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GenericCellManager <NSObject>

-(UIViewController*)getView;
-(void)displayError:(NSError *)error Color:(AJNotificationType)color;
-(void)setBarColor:(UIColor*)color andTitle:(NSString*)title;
-(NSMutableDictionary*)getPatientData;
-(NSMutableDictionary*)getVisitationData;
-(NSMutableDictionary*)getPrescriptionData;
-(void)savePatientObject:(NSDictionary*)patient;
-(void)saveVisitationObject:(NSDictionary*)visit;
-(void)dismissViewNumber:(int)index withObject:(NSMutableDictionary*)object;
-(void)presentViewFromCurrentViewNumber:(int)index withObject:(NSMutableDictionary*)object;
@end
