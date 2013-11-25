//
//  Face.m
//  Mobile Clinic
//
//  Created by Humberto Suarez on 11/1/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import "Face.h"

@implementation Face

@dynamic familyName;
@dynamic firstName;
@dynamic patientId;
@dynamic photo;
@dynamic label;

/*@synthesize familyName;
@synthesize firstName;
@synthesize  patientId;
@synthesize  photo;
-(id)init
{
    [self setupObject];
    self = [super init];
    if(self)
    {
        familyName =@"";
        firstName =@"";
        patientId =0;
    }
    return self;
}
-(void)setupObject{
    
    self->COMMONID =  @"patientId";
    self->CLASSTYPE = kFaceType;
    self->COMMONDATABASE = @"Faces";
    self->commands = kRegisterFace;
    
}*/
@end
