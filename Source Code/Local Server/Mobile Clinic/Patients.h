//
//  Patients.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 2/27/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Visitation;

@interface Patients : NSManagedObject

@property (nonatomic, retain) NSDate * age;
@property (nonatomic, retain) NSString * familyName;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * patientId;
@property (nonatomic, retain) NSData * photo;
@property (nonatomic, retain) NSNumber * sex;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSString * villageName;
@property (nonatomic, retain) NSString * isLockedBy;
@property (nonatomic, retain) NSSet *visit;
@end

@interface Patients (CoreDataGeneratedAccessors)

- (void)addVisitObject:(Visitation *)value;
- (void)removeVisitObject:(Visitation *)value;
- (void)addVisit:(NSSet *)values;
- (void)removeVisit:(NSSet *)values;

@end
