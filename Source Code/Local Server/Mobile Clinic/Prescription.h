//
//  Prescription.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 3/14/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Prescription : NSManagedObject

@property (nonatomic, retain) NSString * instructions;
@property (nonatomic, retain) NSString * isLockedBy;
@property (nonatomic, retain) NSString * medicationId;
@property (nonatomic, retain) NSString * prescribedTime;
@property (nonatomic, retain) NSString * prescriptionId;
@property (nonatomic, retain) NSNumber * tabletPerDay;
@property (nonatomic, retain) NSNumber * timeOfDay;
@property (nonatomic, retain) NSString * visitationId;

@end
