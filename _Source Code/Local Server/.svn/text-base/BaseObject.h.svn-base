//
//  BaseObject.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 1/27/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "DatabaseDriver.h"
#import "BaseObjectProtocol.h"




@interface BaseObject : DatabaseDriver <BaseObjectProtocol>{
    ObjectResponse respondToEvent;
}
@property(nonatomic, weak)      id client;
@property(nonatomic, assign)    ObjectTypes objectType;
@property(nonatomic, assign)    RemoteCommands commands;

@end
