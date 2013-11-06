//
//  Medication.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 2/26/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Medication : NSManagedObject

@property (nonatomic, retain) NSString * dosage;
@property (nonatomic, retain) NSString * expiration;
@property (nonatomic, retain) NSString * medId;
@property (nonatomic, retain) NSString * medName;
@property (nonatomic, retain) NSNumber * numContainers;
@property (nonatomic, retain) NSNumber * tabletsContainer;

@end
