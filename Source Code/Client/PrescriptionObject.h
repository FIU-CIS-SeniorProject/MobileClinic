//
//  PrescriptionObject.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 2/25/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "BaseObject.h"
#import "PrescriptionObject.h"
#import "Prescription.h"
#import "PrescriptionObjectProtocol.h"

@interface PrescriptionObject : BaseObject<PrescriptionObjectProtocol,CommonObjectProtocol>{
    Prescription* prescription;
}


@end
