//
//  Queue.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 4/21/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Queue : NSManagedObject

@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * pId;

@end
