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

#import "PBBioMatch3Database.h"

#import "PBSmartcardBioManager.h"

@implementation PBBioMatch3Database

- (id)init {
    self = [super init];
    
    if (self) {
    }
    
    return self;
}

- (BOOL)insertTemplate:(PBBiometryTemplate *)template_ forFinger:(PBBiometryFinger *)finger
{    
    if (template_.templateType != PBBiometryTemplateTypeBioMatch3Enrollment) {
        /* Incorrect template type. */
        return NO;
    }
    
    PBSmartcardBioManagerStatus status = [[PBSmartcardBioManager sharedBioManager] enrollFinger:finger.position withTemplate:template_];
    if (status != PBSmartcardBioManagerStatusSuccess) {
        NSLog(@"enrollFinger failed with status %@", [PBSmartcardBioManager stringFromStatus:status]);
    }
    
    return (status == PBSmartcardBioManagerStatusSuccess);
}

- (PBBiometryTemplate*)getTemplateForFinger:(PBBiometryFinger *)finger
{
    /* Return the header as the template. The header will be used by the extractor to
     * produce a valid verification template. */
    unsigned char* header_data;
    unsigned char header_data_size;
    
    PBSmartcardBioManagerStatus status = [[PBSmartcardBioManager sharedBioManager] getHeaderForFinger:finger.position bioHeader:&header_data withLength:&header_data_size];
    if (status == PBSmartcardBioManagerStatusSuccess) {
        PBBiometryTemplate* header = [[PBBiometryTemplate alloc] initWithData:header_data andDataSize:header_data_size andTemplateType:PBBiometryTemplateTypeBioMatch3Header];
        
        return [header autorelease];
    }
    else {
        return nil;
    }
}

- (BOOL)deleteTemplateForFinger:(PBBiometryFinger *)finger
{
    PBSmartcardBioManagerStatus status = [[PBSmartcardBioManager sharedBioManager] deleteTemplate:finger.position];
    
    return (status == PBSmartcardBioManagerStatusSuccess);
}

- (NSArray*)getEnrolledFingers
{
    NSArray* bioManagerContainers = [PBSmartcardBioManager sharedBioManager].biometryContainers;
    NSMutableArray* enrolledFingers = [[NSMutableArray alloc] init];
    
    for (PBSmartcardBioManagerContainer* container in bioManagerContainers) {
        if (container.isUsed) {
            PBBiometryFinger* finger = [[PBBiometryFinger alloc] initWithPosition:container.fingerPosition andUserId:1];
            [enrolledFingers addObject:finger];
            [finger release];
        }
    }
    return [enrolledFingers autorelease];
}

- (BOOL)templateIsEnrolledForFinger:(PBBiometryFinger *)finger
{
    NSArray* bioManagerContainers = [PBSmartcardBioManager sharedBioManager].biometryContainers;
    
    for (PBSmartcardBioManagerContainer* container in bioManagerContainers) {
        /* Ignoring user, since biomanager can only handle one user. */
        if (container.isUsed) {
            if (finger.position == container.fingerPosition) {
                return YES;
            }
        }
    }
    return NO;
}


/* Methods for strict singleton implementation. */

static PBBioMatch3Database* _sharedReferenceDatabase = nil;

+ (PBBioMatch3Database*) sharedClass
{
    @synchronized ([PBBioMatch3Database class]) 
    {
        if (_sharedReferenceDatabase == nil) {
            _sharedReferenceDatabase = [[super allocWithZone:NULL] init];
        }
        return _sharedReferenceDatabase;
    }
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized ([PBBioMatch3Database class]) 
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
