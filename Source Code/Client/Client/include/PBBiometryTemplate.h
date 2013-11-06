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

/** The type of template. */
typedef enum {
    PBBiometryTemplateUnknown,
    
    /* Standardized template formats. */
    
    /** The ISO 19794-2 Record Format. */
    PBBiometryTemplateTypeISO,
    /** The ISO 19794-2 Compact Card Format. The default template type
      * used by the internal extractor and verifier. */
    PBBiometryTemplateTypeISOCompactCard,
    /** The ANSI-378 Record Format. */
    PBBiometryTemplateTypeANSI,
    
    /* Proprietary template formats. */
    
    /** The Precise BioMatch 3.0 Record Format. Use only if the verification
      * must be done on a smart card with the Precise BioMatch verifier. 
      * The BioMatch 3.0 Record Format consists of 3 formats, one for enrollment
      * , one for verification and one for the header. */
    PBBiometryTemplateTypeBioMatch3Enrollment,
    PBBiometryTemplateTypeBioMatch3Verification,
    PBBiometryTemplateTypeBioMatch3Header
} PBBiometryTemplateType;

/** A biometric (fingerprint) template. A template contains extracted
  * features from the fingerprint, e.g. minutiae points. */
@interface PBBiometryTemplate : NSObject {
	/** The binary data containing the template. */
	uint8_t* data;
	/** The size of the binary data, in bytes. */
	uint16_t dataSize;
    /** The type of template. */
    PBBiometryTemplateType templateType;
}

@property (nonatomic, readonly) uint8_t* data;
@property (nonatomic, readonly) uint16_t dataSize;
@property (nonatomic, readonly) PBBiometryTemplateType templateType;

/** Initiates the template object with template data. The template 
  * type will be set to PBBiometryTemplateTypeISOCompactCard. */
-(id) initWithData : (const uint8_t*)aData 
        andDataSize: (uint16_t)aDataSize; 

/** Initiates the template object with template data and type. */
-(id) initWithData : (const uint8_t*)aData 
        andDataSize: (uint16_t)aDataSize
    andTemplateType: (PBBiometryTemplateType)aTemplateType;

@end
