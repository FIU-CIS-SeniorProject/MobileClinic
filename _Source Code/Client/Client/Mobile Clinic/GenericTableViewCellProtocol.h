//
//  GenericTableViewCellProtocol.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 4/30/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GenericCellProtocol.h"
@protocol GenericTableViewCellProtocol <NSObject>

@property(nonatomic, strong)id<GenericCellProtocol> viewController;

@end
