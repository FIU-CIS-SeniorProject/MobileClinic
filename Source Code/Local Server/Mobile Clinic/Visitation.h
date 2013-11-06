//
//  Visitation.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 3/3/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Prescription;

@interface Visitation : NSManagedObject

@property (nonatomic, retain) NSString * bloodPressure;
@property (nonatomic, retain) NSString * condition;
@property (nonatomic, retain) NSString * diagnosisTitle;
@property (nonatomic, retain) NSString * doctorId;
@property (nonatomic, retain) NSDate * doctorIn;
@property (nonatomic, retain) NSDate * doctorOut;
@property (nonatomic, retain) NSNumber * isGraphic;
@property (nonatomic, retain) NSString * isLockedBy;
@property (nonatomic, retain) NSNumber * isOpen;
@property (nonatomic, retain) NSString * nurseId;
@property (nonatomic, retain) NSString * observation;
@property (nonatomic, retain) NSString * patientId;
@property (nonatomic, retain) NSDate * triageIn;
@property (nonatomic, retain) NSDate * triageOut;
@property (nonatomic, retain) NSString * visitationId;
@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) NSSet *prescription;
@end

@interface Visitation (CoreDataGeneratedAccessors)

- (void)addPrescriptionObject:(Prescription *)value;
- (void)removePrescriptionObject:(Prescription *)value;
- (void)addPrescription:(NSSet *)values;
- (void)removePrescription:(NSSet *)values;

@end
