//
//  Recognition.h
//  Mobile Clinic
//
//  Created by Humberto Suarez on 11/20/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "BaseObject.h"
#import "FaceObjectProtocol.h"

@interface Recognition : BaseObject <FaceObjectProtocol,CommonObjectProtocol>
@property (nonatomic) BOOL modelAvailable;
@end
