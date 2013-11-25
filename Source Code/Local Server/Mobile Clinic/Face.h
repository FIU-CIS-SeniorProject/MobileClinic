//
//  Face.h
//  Mobile Clinic
//
//  Created by Humberto Suarez on 11/10/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Face: NSManagedObject


@property (nonatomic, retain) NSString * familyName;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * patientId;
@property (nonatomic, retain) NSData * photo;
@property (nonatomic, retain) NSString * isLockedBy;
@property (nonatomic, retain) NSNumber * label;

@end

