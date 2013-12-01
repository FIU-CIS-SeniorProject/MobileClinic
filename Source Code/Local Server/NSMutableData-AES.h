//
//  NSMutableData-AES.h
//  Mobile Clinic
//
//  Created by James Mendez on 11/30/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableData(AES)

- (NSMutableData*) EncryptAES: (NSString*) key;
- (NSMutableData*) DecryptAES: (NSString*) key andForData:(NSMutableData*)objEncryptedData;

@end
