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
 * $Date: 2012-04-20 11:18:03 +0200 (fr, 20 apr 2012) $ $Rev: 14630 $ 
 *
 */
#import "PBBiomatch3Verifier.h"

#import "PBSmartcardBioManager.h"

@implementation PBBiomatch3Verifier

- (id)init {
    self = [super init];
    
    if (self) {
    }
    
    return self;
}

- (BOOL)verifyTemplate:(PBBiometryTemplate *)probe forFinger:(PBBiometryFinger*)finger atFalseAcceptRate:(PBFalseAcceptRate)falseAcceptRate
{
    if (probe.templateType != PBBiometryTemplateTypeBioMatch3Verification) {
        /* Incorrect template type. */
        return NO;
    }
    
    BOOL match;
    
    [[PBSmartcardBioManager sharedBioManager] verifyFinger:finger.position withVerificationData:probe.data ofLength:probe.dataSize didMatch:&match];

    return match;
}


/* Methods for strict singleton implementation. */

static PBBiomatch3Verifier* _sharedReferenceDatabase = nil;

+ (PBBiomatch3Verifier*) sharedClass
{
    @synchronized ([PBBiomatch3Verifier class]) 
    {
        if (_sharedReferenceDatabase == nil) {
            _sharedReferenceDatabase = [[super allocWithZone:NULL] init];
        }
        return _sharedReferenceDatabase;
    }
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized ([PBBiomatch3Verifier class]) 
    {
        return [[self sharedClass] retain];
    }    
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    return NSUIntegerMax; 
}

- (oneway void)release
{
    /* Do nothing. */
}

- (id)autorelease
{
    return self;
}

@end
