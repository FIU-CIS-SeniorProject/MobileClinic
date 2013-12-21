// The MIT License (MIT)
//
// Copyright (c) 2013 Florida International University
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//  ObjectFactory.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 1/27/13.
//
#import "ObjectFactory.h"
#import "UserObject.h"
#import "PatientObject.h"
#import "StatusObject.h"
#import "VisitationObject.h"
#import "PrescriptionObject.h"
#import "MedicationObject.h"
#import "FaceObject.h"
#import "Recognition.h"

@implementation ObjectFactory

+(id<BaseObjectProtocol>)createObjectForType:(NSDictionary*)data
{
    // ObjectType: Used to generically determine what kind of information was passed
    ObjectTypes type = [[data objectForKey:OBJECTTYPE]intValue];
    
    switch (type)
    {
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
        case kFaceRType:
            return [[Recognition alloc]init];
        case kFaceType:
            return [[FaceObject alloc ]init];
        default:
            return nil;
    }
}

+(id<BaseObjectProtocol>)createObjectForInteger:(NSString*)data
{
    // ObjectType: Used to generically determine what kind of information was passed
    ObjectTypes type = [data intValue];
    
    switch (type)
    {
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