//
//  GenericCellProtocol.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 4/30/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GenericCellManager.h"
@protocol GenericCellProtocol <NSObject>

@required
@property(nonatomic, weak) id<GenericCellManager> delegate;

@end
