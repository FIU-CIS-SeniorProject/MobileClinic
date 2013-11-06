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
#import "PBBiometryFinger.h"
#import "PBBiometryVerifyConfig.h"

@protocol PBBiometryVerifier <NSObject>

/* The implementation decides which of the verifyTemplate methods to
 * implement, based on which type of verifier it is. The caller should use
 * respondsToSelector to determine which method that is supported. */
@optional

/** Verifies the probe template against a reference template
  * at a given false accept rate.
  *
  * @param probe is the probe (verification) template to be verified.
  * @param reference is the reference (enrolled) template to which the 
  *        probe template shall be verified against.
  * @param falseAcceptRate is the requested false accept rate for 
  *        the verification.
  *
  * @return YES if the two templates matched, otherwise NO.
  */
- (BOOL) verifyTemplate: (PBBiometryTemplate*)probe
        againstTemplate: (PBBiometryTemplate*)reference
      atFalseAcceptRate: (PBFalseAcceptRate)falseAcceptRate;

/** Verifies the probe template against a reference template
  * stored on a smart card.
  *
  * @param probe is the probe (verification) template to be verified.
  * @param finger is the finger to be verified, which identifies the
  *     correct template enrolled on the card (in case several templates
  *     has been enrolled).
  * @param falseAcceptRate is the requested false accept rate for 
  *        the verification.
  *
  * @return YES if the two templates matched, otherwise NO.
  */
- (BOOL) verifyTemplate: (PBBiometryTemplate*)probe
              forFinger: (PBBiometryFinger*)finger
      atFalseAcceptRate: (PBFalseAcceptRate)falseAcceptRate;

@end
