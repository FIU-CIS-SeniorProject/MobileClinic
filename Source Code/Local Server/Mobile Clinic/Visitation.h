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
//  Visitation.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 3/3/13.
//
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Prescription;

@interface Visitation : NSManagedObject

@property (nonatomic, retain) NSString * bloodPressure;
@property (nonatomic, retain) NSString * condition;
@property (nonatomic, retain) NSString * diagnosisTitle;
@property (nonatomic, retain) NSString * doctorId;
@property (nonatomic, retain) NSDate * doctorIn;
@property (nonatomic, retain) NSDate * doctorOut;
@property (nonatomic, retain) NSNumber * isGraphic;
@property (nonatomic, retain) NSString * isLockedBy;
@property (nonatomic, retain) NSNumber * isOpen;
@property (nonatomic, retain) NSString * nurseId;
@property (nonatomic, retain) NSString * observation;
@property (nonatomic, retain) NSString * patientId;
@property (nonatomic, retain) NSDate * triageIn;
@property (nonatomic, retain) NSDate * triageOut;
@property (nonatomic, retain) NSString * visitationId;
@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) NSSet *prescription;
@end

@interface Visitation (CoreDataGeneratedAccessors)

- (void)addPrescriptionObject:(Prescription *)value;
- (void)removePrescriptionObject:(Prescription *)value;
- (void)addPrescription:(NSSet *)values;
- (void)removePrescription:(NSSet *)values;

@end