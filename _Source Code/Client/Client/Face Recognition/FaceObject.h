//
//  FaceObject.h
//  Mobile Clinic
//
//  Created by Humberto Suarez on 11/1/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseObject.h"
#import "FaceObjectProtocol.h"
#import "Face.h"
@interface FaceObject : BaseObject<FaceObjectProtocol,CommonObjectProtocol>{
    Face *face;


}

+(NSString*)getCurrenUserName;
-(void)deleteAllfFromDatabase;
@end
