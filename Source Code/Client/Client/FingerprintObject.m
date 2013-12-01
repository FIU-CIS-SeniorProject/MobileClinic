//
//  FingerprintObject.m
//  Mobile Clinic
//
//  Created by sebastian a zanlongo on 4/7/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import "FingerprintObject.h"
#import "PatientObjectProtocol.h"


@implementation FingerprintObject

+(id)sharedClass{
  
    return [[FingerprintObject alloc]init];
}
- (id)init
{
    self = [super init];
    
    if (self) {
        enrolledFingers = [[NSMutableArray alloc]init];
    }
    
    return self;
}

- (id)initWithEnrolledFingers:(NSArray *)enrolled {
    self = [super init];
    if (self) {
    if (enrolled) {
         enrolledFingers = [NSArray arrayWithArray:enrolled];
    }else{
        enrolledFingers = [[NSMutableArray alloc]init];
    }
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



-(BOOL) insertTemplate: (PBBiometryTemplate*) template_
             forFinger: (PBBiometryFinger*) finger
{
    NSMutableDictionary* attributes = [[NSMutableDictionary alloc] init];
    
    NSData* templateData = [[NSData alloc] initWithBytes:template_.data length:template_.dataSize];
    
    //[attributes setObject:[self serializeFinger:finger] forKey:SERIALIZEDFINGER];
    
    [attributes setObject:[NSNumber numberWithInt:template_.templateType] forKey:TEMPLATETYPE];
    [attributes setObject:templateData forKey:FINGERDATA];
    [attributes setObject:[NSNumber numberWithInt:template_.dataSize] forKey:DATASIZE];
    [attributes setObject:[NSNumber numberWithInt:finger.user.id_] forKey:USERID];
    [attributes setObject:[NSNumber numberWithInt:finger.position] forKey:FINGERPOSITION];
    
    if (!enrolledFingers) {
        enrolledFingers = [[NSMutableArray alloc]initWithObjects:attributes, nil];
    }else{
    [enrolledFingers addObject:attributes];
    }
    
     [self performSelectorOnMainThread:@selector(SendNotification) withObject:nil waitUntilDone:NO];

    return YES;
}

-(void)SendNotification{
     [[NSNotificationCenter defaultCenter]postNotificationName:@"fingerprintRegistered" object:enrolledFingers.lastObject];
}

-(PBBiometryTemplateType) getTemplateTypeFromString: (NSString*)templateTypeString
{
    if ((templateTypeString == nil) || [templateTypeString isEqualToString:@""]) {
        /* Undefined template type, use default. */
        return PBBiometryTemplateTypeISOCompactCard;
    }
    else {
        return [templateTypeString integerValue];
    }
}

-(PBBiometryTemplate*) getTemplateForFinger: (PBBiometryFinger*) finger
{
    BOOL fingerIsRegistered = [self templateIsEnrolledForFinger:finger];
    
    if (fingerIsRegistered) {
        
        NSArray * array = [enrolledFingers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K == %@ && %K == %@", USERID, [NSNumber numberWithInt:finger.user.id_],FINGERPOSITION,[NSNumber numberWithInt:finger.position]]];
        

            NSDictionary * theFinger = array.lastObject;
        
            return [[PBBiometryTemplate alloc] initWithData:(uint8_t*)[[theFinger objectForKey:FINGERDATA] bytes] andDataSize:[[theFinger objectForKey:DATASIZE]intValue] andTemplateType:[[theFinger objectForKey:TEMPLATETYPE] intValue]];
   
    } else {
            return nil;
        }
        
}

-(BOOL) deleteTemplateForFinger: (PBBiometryFinger*) finger
{
    return YES;
}

+(NSMutableDictionary *)findPatientFromArrayOfPatients:(NSArray *)allPatients withFinger:(PBBiometryFinger *)finger{
    
    NSArray * array = [allPatients filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K==%@ && %K == %@", USERID, [NSNumber numberWithInt:finger.user.id_],FINGERPOSITION,[NSNumber numberWithInt:finger.position]]];
    
    if (array.count  == 1 ) {
        return array.lastObject;
    }
    
    return nil;

}

-(BOOL) templateIsEnrolledForFinger:(PBBiometryFinger *)finger
{

    NSArray * array = [enrolledFingers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K==%@ && %K == %@", USERID, [NSNumber numberWithInt:finger.user.id_],FINGERPOSITION,[NSNumber numberWithInt:finger.position]]];
  
        if (array.count  == 1 ) {
            return YES;
        }
    
    return NO;
}

-(NSArray*) getEnrolledFingers
{
    NSMutableArray* allFingers = [[NSMutableArray alloc]initWithCapacity:enrolledFingers.count];
   
    for (NSDictionary* finger in enrolledFingers) {
        if ([finger objectForKey:USERID] == nil) {
            continue;
        }
        PBBiometryFinger* theFinger = [[PBBiometryFinger alloc]initWithPosition:[[finger objectForKey:FINGERPOSITION]intValue] andUserId:(uint32_t)[[finger objectForKey:USERID]intValue]];
        
        [allFingers addObject:theFinger];
    }
    
    return allFingers;
}

@end
