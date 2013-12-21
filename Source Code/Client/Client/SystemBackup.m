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
//  SystemBackup.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 4/15/13.
//
#import "SystemBackup.h"
#import "PatientObject.h"
#import "NSDataAdditions.h"
#import "UserObject.h"
#import "VisitationObject.h"
#import "PrescriptionObject.h"
#import "MedicationObject.h"
#import "ObjectFactory.h"

#define BACK_UP         @"MC-EMR BACKUP"
#define FILE            @"backup.json"

NSTimer* saveTimer;

@implementation SystemBackup

-(NSError*)BackupEverything{
    
    PatientObject* patient = [[PatientObject alloc]init];
   // UserObject* user = [[UserObject alloc]init];
    VisitationObject* visit = [[VisitationObject alloc]init];
    PrescriptionObject* prescript = [[PrescriptionObject alloc]init];
    MedicationObject* medic = [[MedicationObject alloc]init];

    NSMutableDictionary* Container = [[NSMutableDictionary alloc]initWithCapacity:5];
    
    [Container setObject:[patient covertAllSavedObjectsToJSON] forKey:[NSString stringWithFormat:@"%i",kPatientType]];
    //[Container setObject:[user covertAllSavedObjectsToJSON] forKey:[NSString stringWithFormat:@"%i",kUserType]];
    [Container setObject:[visit covertAllSavedObjectsToJSON] forKey:[NSString stringWithFormat:@"%i",kVisitationType]];
    [Container setObject:[prescript covertAllSavedObjectsToJSON] forKey:[NSString stringWithFormat:@"%i",kPrescriptionType]];
    [Container setObject:[medic covertAllSavedObjectsToJSON] forKey:[NSString stringWithFormat:@"%i",kMedicationType]];
    
    return [self overWritePList:Container];
}

-(NSError*)overWritePList:(NSDictionary*)file{
    
    NSString* fileName = [[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:FILE];
    
    NSLog(@"Trying to find: %@",fileName);
    
    NSFileManager* fm = [NSFileManager defaultManager];
    
   BOOL doesExists = [fm fileExistsAtPath:fileName];
    
    if (!doesExists) {
        NSLog(@"Created New File: %@",fileName);
        
        [fm createFileAtPath:fileName contents:nil attributes:nil];
    }
    
    BOOL canBeConverted = [NSJSONSerialization isValidJSONObject:file];
  
    NSError* error = nil;

    if (canBeConverted) {
       // Need Proper File location
        NSOutputStream* stream = [NSOutputStream outputStreamToFileAtPath:FILE append:NO];
        [stream open];
        [NSJSONSerialization writeJSONObject:file toStream:stream options:NSJSONWritingPrettyPrinted error:&error];
        [stream close];
    }

    return error;
}

+(void)installFromBackup:(NSDictionary*)allObjects{
    // Get all the objects from backupFile
    if (!allObjects) {
        allObjects= [SystemBackup GetAllValuesFromBackUp];
    }
    
    // for all the keys
    for (NSString* key in allObjects.allKeys) {
     
        // create the object that is associated with it
        id<BaseObjectProtocol> base =  [ObjectFactory createObjectForInteger:key];
        
        // if there is no object, skip
        if (!base)
            continue;
        
        // Get the array of dictionaries for that key
        NSArray* internalObjects = [allObjects objectForKey:key];
       
        // for each dictionary in the array
        for (NSDictionary* object in internalObjects) {
            
            // make data changeable
            NSMutableDictionary* changeObject = [NSDictionary dictionaryWithDictionary:object];
            // get the picture  (which is in string form)
            NSString* picture = [changeObject objectForKey:PICTURE];
            
            // convert Picture String to NSData
            [changeObject setValue:[NSData dataWithBase64EncodedString:picture] forKey:PICTURE];
            
            // convert FingerData String to NSData
            [changeObject setValue:[NSData dataWithBase64EncodedString:[changeObject objectForKey:FINGERDATA]] forKey:FINGERDATA];
            
            // Store the value to the object
            [base setValueToDictionaryValues:object];
            
            // And save
            [base saveObject:^(id<BaseObjectProtocol> data, NSError *error) {
                NSLog(@"Saved %@ \n\n",object);
            }];
        }
       
    }

}

+(NSDictionary*)GetAllValuesFromBackUp{
    
    NSString* fileName = [[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:FILE];
    
    NSFileManager* fm = [NSFileManager defaultManager];
    
    BOOL canBeConverted = [fm fileExistsAtPath:fileName];
    
    NSError* error = nil;
    
    if (canBeConverted) {
        // Need Proper File location
        NSInputStream* stream = [NSInputStream inputStreamWithFileAtPath:fileName];
        
       return [NSJSONSerialization JSONObjectWithStream:stream options:0 error:&error];
    }
    
    return nil;
}
+(NSError*)exportObject:(NSDictionary*)object toFilePath:(NSString*)path{
    
    NSFileManager* fm = [NSFileManager defaultManager];
    
    BOOL doesExists = [fm fileExistsAtPath:path];
    
    if (!doesExists) {
        NSLog(@"Created New File: %@",path);
        
        [fm createFileAtPath:path contents:nil attributes:nil];
    }
    
    BOOL canBeConverted = [NSJSONSerialization isValidJSONObject:object];
    
    NSError* error = nil;
    
    if (canBeConverted) {
        // Need Proper File location
        NSOutputStream* stream = [NSOutputStream outputStreamToFileAtPath:FILE append:NO];
        [stream open];
        [NSJSONSerialization writeJSONObject:object toStream:stream options:NSJSONWritingPrettyPrinted error:&error];
        [stream close];
    }
    
    return error;
}
@end
