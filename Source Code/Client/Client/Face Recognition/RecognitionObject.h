//
//  RecognitionObject.h
//  Mobile Clinic
//
//  Created by Humberto Suarez on 11/20/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseObject.h"
#import "RecognitionProtocol.h"
#import "Face.h"
@interface RecognitionObject : BaseObject<RecognitionProtocol,CommonObjectProtocol>{
    Face *face;
    
    
}

+(NSString*)getCurrentUserName;
@end

