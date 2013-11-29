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
 *
 * $Date: 2012-04-20 11:36:52 +0200 (fr, 20 apr 2012) $ $Rev: 14637 $ 
 *
 */

#import <Foundation/Foundation.h>

#import "PBBiometryTemplate.h"

/** Configuration properties for an enrollment process. */
@interface PBBiometryEnrollConfig : NSObject {
    /** The minimum quality required for a fingerprint image to be used for 
      * enrollment, default 20. The quality value ranges from 0 (worst quality)
      * to 100 (best quality). */
    uint8_t minimumQuality; 
    
    /** The minimum fingerprint area, in mm^2, required for a fingerprint image 
      * to be used for enrollment, default (11 * 11). */
    uint32_t minimumArea;
    
    /** The timeout for the image capture, in ms. If no image has been captured
      * with the required quality and area within this time, the enrollment 
      * function will return, default 10000. */
    uint16_t timeout;
    
    /** The template type for the template to be enrolled, default 
      * PBBiometryTemplateTypeISOCompactCard. The template type will 
      * decide which extractor that will be used when extracting the 
      * template from the fingerprint image. */
    PBBiometryTemplateType templateType;
}
     
-(id) init;
     
@property (nonatomic) uint8_t minimumQuality;
@property (nonatomic) uint32_t minimumArea;
@property (nonatomic) uint16_t timeout;
@property (nonatomic) PBBiometryTemplateType templateType;
     
@end
