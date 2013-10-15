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
//  MobileClinicFacade.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 3/1/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

// Mobile Clinic Facade
// The user will use dictionaries to create and modify any records
// The primary key/ID of the object should not be used or tampered.
// Description:
// The Mobile Clinic Facade consolidates all the appropriate methods to complete the patient workflow
// @see MobileClinicFacadeProtocol

#import <Foundation/Foundation.h>
#import "StatusObject.h"
#import "MobileClinicFacadeProtocol.h"

@interface MobileClinicFacade : NSObject <MobileClinicFacadeProtocol>
-(id)init;
-(NSString*)GetCurrentUsername;
@end