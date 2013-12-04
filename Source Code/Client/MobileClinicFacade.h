//
//  MobileClinicFacade.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 3/1/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

/**
 * Mobile Clinic Facade
 * The user will use dictionaries to create and modify any records
 * The primary key/ID of the object should not be used or tampered.
 * Description:
 * The Mobile Clinic Facade consolidates all the appropriate methods to complete the patient workflow
 * @see MobileClinicFacadeProtocol
 */

#import <Foundation/Foundation.h>
#import "StatusObject.h"
#import "MobileClinicFacadeProtocol.h"

@interface MobileClinicFacade : NSObject <MobileClinicFacadeProtocol>
-(id)init;
-(NSString*)GetCurrentUsername;
@end
