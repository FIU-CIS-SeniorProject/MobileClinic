//
//  CloudManager.h
//  Mobile Clinic
//
//  Created by James Mendez on 11/28/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CloudManager : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * cloudURL;
@property (nonatomic, retain) NSNumber * isActive;
@property (nonatomic, retain) NSNumber * isDirty;
@property (nonatomic, retain) NSDate * lastPullTime;

@end
