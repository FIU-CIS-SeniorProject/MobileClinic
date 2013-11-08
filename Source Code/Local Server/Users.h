//
//  Users.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 2/26/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Patients;

@interface Users : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSNumber * userType;
@property (nonatomic, retain) NSSet *patient;
@end

@interface Users (CoreDataGeneratedAccessors)

- (void)addPatientObject:(Patients *)value;
- (void)removePatientObject:(Patients *)value;
- (void)addPatient:(NSSet *)values;
- (void)removePatient:(NSSet *)values;

@end
