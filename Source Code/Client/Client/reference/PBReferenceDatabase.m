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
 * $Date: 2012-04-20 13:38:30 +0200 (fr, 20 apr 2012) $ $Rev: 14651 $
 */
#import "PBReferenceDatabase.h"
#import "PBBiometryTemplate.h"
#import "PBBiometryFinger.h"

@implementation PBReferenceDatabase

- (id)init
{
    self = [super init];
    
    NSArray *libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *filePath = [NSString stringWithFormat:@"%@/enrolledFingers.plist", [libraryPaths objectAtIndex:0]];    
    self->enrolledFingers = [NSKeyedUnarchiver unarchiveObjectWithFile: filePath];
    
    if (self->enrolledFingers == nil)
    {
        NSLog (@"Unable to unarchive the enrolled fingers!\n");
        self->enrolledFingers = [[NSMutableArray alloc] init];
    }
    else
    {
        [self->enrolledFingers retain];
    }
    
    return self;
}

/** Serializes a PBBiometryFinger object to a string. */
-(NSString*) serializeFinger: (PBBiometryFinger*) finger
{
    NSString* serializedFinger = [NSString stringWithFormat:@"%09d_%02d", finger.user.id_, finger.position];
    return serializedFinger;
}

/** Serializes a PBBiometryTemplateType value to a string. */
-(NSString*) serializeTemplateType: (PBBiometryTemplateType) templateType  
{
    NSString* serializedTemplateType = [NSString stringWithFormat:@"%09d", templateType];
    
    return serializedTemplateType;
}

- (void)writeEnrolledFingers
{
    NSArray *libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *filePath = [NSString stringWithFormat:@"%@/enrolledFingers.plist", [libraryPaths objectAtIndex:0]];    
    
    [NSKeyedArchiver archiveRootObject:enrolledFingers toFile:filePath];
}

-(BOOL) insertTemplate: (PBBiometryTemplate*) template_
             forFinger: (PBBiometryFinger*) finger
{
    NSMutableDictionary* attributes = [[NSMutableDictionary alloc] init];
    NSData* templateData = [[NSData alloc] initWithBytes:template_.data length:template_.dataSize];
    
    /* Delete already stored finger, if any. */
    [self deleteTemplateForFinger: finger];
    
    /* Set attributes, using kSecAttrAccount for the finger and kSecAttrGeneric
     * for the template. */
    [attributes setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    [attributes setObject:(id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly forKey:(id)kSecAttrAccessible];
    [attributes setObject:[self serializeFinger:finger] forKey:(id)kSecAttrAccount];
    [attributes setObject:[self serializeTemplateType:template_.templateType] forKey:(id)kSecAttrService];
    [attributes setObject:templateData forKey:(id)kSecAttrGeneric];
    
    /* Add the attributes to the keychain. */
    OSStatus osStatus = SecItemAdd ((CFDictionaryRef)attributes, NULL);
    
    [templateData release];
    [attributes release];
    
    if (osStatus == errSecSuccess)
    {
        /* Add finger to list of enrolled fingers. */
        [enrolledFingers addObject:finger];
        [self writeEnrolledFingers];
    
        return YES;
    }
    else
    {
        return NO;
    }
}

-(PBBiometryTemplateType) getTemplateTypeFromString: (NSString*)templateTypeString
{
    if ((templateTypeString == nil) || [templateTypeString isEqualToString:@""])
    {
        /* Undefined template type, use default. */
        return PBBiometryTemplateTypeISOCompactCard;
    }
    else
    {
        return [templateTypeString integerValue];
    }
}

-(PBBiometryTemplate*) getTemplateForFinger: (PBBiometryFinger*) finger
{
    BOOL fingerIsRegistered = [self templateIsEnrolledForFinger:finger];
    
    if (fingerIsRegistered)
    {
        NSMutableDictionary* query = [[NSMutableDictionary alloc] init];
        NSMutableDictionary* outDictionary = nil;
        
        /* Set query attributes. */
        [query setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
        [query setObject:[self serializeFinger:finger] forKey:(id)kSecAttrAccount];
        [query setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnAttributes];

        /* Return the keychain item matching the query. */
        SecItemCopyMatching((CFDictionaryRef)query, (CFTypeRef*)&outDictionary);
        [query release];
        
        if (outDictionary != nil)
        {
            /* Convert keychain item to PBBiometryTemplate. */
            NSData* templateData = [outDictionary objectForKey:(id)kSecAttrGeneric];
            PBBiometryTemplateType templateType = [self getTemplateTypeFromString: [outDictionary objectForKey:(id)kSecAttrService]];
            
            PBBiometryTemplate* template_ = [[PBBiometryTemplate alloc] initWithData:(uint8_t*)[templateData bytes] andDataSize:[templateData length] andTemplateType:templateType];
            [template_ autorelease];
            
            return template_;
        }
        else
        {
            return nil;
        }
    }
    else
    {
        return nil;
    }
}

-(BOOL) deleteTemplateForFinger: (PBBiometryFinger*) finger
{
    NSMutableDictionary* query = [[NSMutableDictionary alloc] init];
    
    /* Set query attributes. */
    [query setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    [query setObject:[self serializeFinger:finger] forKey:(id)kSecAttrAccount];
    [query setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnAttributes];
    
    /* Delete the keychain item matching the query. */
    SecItemDelete ((CFDictionaryRef)query);
    [query release];
    
    for (NSInteger i = 0; i < [enrolledFingers count]; i++)
    {
        PBBiometryFinger* enrolledFinger = (PBBiometryFinger*)[enrolledFingers objectAtIndex:i];
        
        if ([finger isEqualToFinger:enrolledFinger])
        {
            [enrolledFingers removeObjectAtIndex:i];
            [self writeEnrolledFingers];
            break;
        }
    }
    
    return YES;
}

-(BOOL) templateIsEnrolledForFinger:(PBBiometryFinger *)finger
{
    PBBiometryFinger* enrolledFinger;
    
    for (enrolledFinger in enrolledFingers)
    {
        if ([enrolledFinger isEqualToFinger:finger])
        {
            return YES;
        }
    }
    
    return NO;
}

-(NSArray*) getEnrolledFingers
{
    return enrolledFingers;
}

- (void)dealloc
{
    [enrolledFingers release];
    [super dealloc];
}

/* Methods for strict singleton implementation. */

static PBReferenceDatabase* _sharedReferenceDatabase = nil;

+ (PBReferenceDatabase*) sharedClass
{
    @synchronized ([PBReferenceDatabase class]) 
    {
        if (_sharedReferenceDatabase == nil)
        {
            _sharedReferenceDatabase = [[super allocWithZone:NULL] init];
        }
        return _sharedReferenceDatabase;
    }
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized ([PBReferenceDatabase class]) 
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