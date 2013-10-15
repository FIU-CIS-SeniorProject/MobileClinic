/*
 * Copyright (c) 2011 - 2012, Precise Biometrics AB
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the Precise Biometrics AB nor the names of its
 *    contributors may be used to endorse or promote products derived from
 *    this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
 * AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
 * THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 *
 * $Date: 2012-04-20 11:36:52 +0200 (fr, 20 apr 2012) $ $Rev: 14637 $
 */
#import <Foundation/Foundation.h>
#import "PBBiometryTemplate.h"

/** False Acceptance Rates (FARs). The FAR is a measure of the likelihood that 
  * the access system will wrongly accept an access attempt; that is, will allow 
  * the access attempt from an unauthorized user. */
typedef enum
{
	PBFalseAcceptRate5,			/* FAR 1/5 */
	PBFalseAcceptRate10,		/* FAR 1/10 */
	PBFalseAcceptRate50,		/* ... */
	PBFalseAcceptRate100,
	PBFalseAcceptRate500,
	PBFalseAcceptRate1000,
	PBFalseAcceptRate5000,
	PBFalseAcceptRate10000,
	PBFalseAcceptRate50000,
	PBFalseAcceptRate100000,
	PBFalseAcceptRate500000,
	PBFalseAcceptRate1000000
} PBFalseAcceptRate;

// Configuration properties for a verification process.
@interface PBBiometryVerifyConfig : NSObject {
    /** The minimum quality required for a fingerprint image to be used for 
      * verification, default 15. The quality value ranges from 0 (worst 
      * quality) to 100 (best quality). 
      */
    uint8_t minimumQuality;
    
    /** The minimum fingerprint area, in mm^2 required for a fingerprint image 
      * to be used for verification, default (10 * 10). */
    uint32_t minimumArea;
    
    /** The timeout for the image capture, in ms. If no image has been captured
      * with the required quality and area within this time, the verification 
      * function will return, default 7500. 
      */
    uint16_t timeout;
    
    // The requested false accept rate, default PBFalseAcceptRate10000.
    PBFalseAcceptRate falseAcceptRate;
    
    /** Tells if brute force checks shall be used or not, default YES. If YES,
      * multiple subsequent rejects of the same finger, will cause that finger
      * to be blocked for a given time. */
    BOOL defendAgainstBruteForce;
    
    /** The template type for the template to be enrolled, default 
      * PBBiometryTemplateTypeISOCompactCard. The template type will 
      * decide which extractor that will be used when extracting the 
      * template from the fingerprint image.. */
     PBBiometryTemplateType templateType;
}
-(id) init;
@property (nonatomic) uint8_t minimumQuality;
@property (nonatomic) uint32_t minimumArea;
@property (nonatomic) uint16_t timeout;
@property (nonatomic) PBFalseAcceptRate falseAcceptRate;
@property (nonatomic) BOOL defendAgainstBruteForce;
@property (nonatomic) PBBiometryTemplateType templateType;

@end