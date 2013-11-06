//
//  ObjectFactory.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 1/27/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import "ObjectFactory.h"
#import "UserObject.h"
#import "PatientObject.h"
#import "StatusObject.h"
#import "VisitationObject.h"
#import "PrescriptionObject.h"
#import "MedicationObject.h"
#import "FaceObject.h"

@implementation ObjectFactory

+(id<BaseObjectProtocol>)createObjectForType:(NSDictionary*)data{
    // ObjectType: Used to generically determine what kind of information was passed
    ObjectTypes type = [[data objectForKey:OBJECTTYPE]intValue];
    
    switch (type) {
        case kUserType:
            return [[UserObject alloc]init];
        case kStatusType:
            return [[StatusObject alloc]init];
        case kPatientType:
            return [[PatientObject alloc]init];
        case kVisitationType:
            return [[VisitationObject alloc]init];
        case kPrescriptionType:
            return [[PrescriptionObject alloc]init];
        case kMedicationType:
            return [[MedicationObject alloc]init];
        case kFaceType:
            return [[FaceObject alloc ]init];//NSLog(@"LLEGUEeeeeEEEEEEEEEEEEEeeeeeee");
        default:
            return nil;
    }
}

+(id<BaseObjectProtocol>)createObjectForInteger:(NSString*)data{
    // ObjectType: Used to generically determine what kind of information was passed
    ObjectTypes type = [data intValue];
    
    switch (type) {
        case kUserType:
            return [[UserObject alloc]init];
        case kStatusType:
            return [[StatusObject alloc]init];
        case kPatientType:
            return [[PatientObject alloc]init];
        case kVisitationType:
            return [[VisitationObject alloc]init];
        case kPrescriptionType:
            return [[PrescriptionObject alloc]init];
        case kMedicationType:
            return [[MedicationObject alloc]init];
        default:
            return nil;
    }
}
@end
