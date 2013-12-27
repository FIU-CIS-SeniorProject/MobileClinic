//
//  NSMutableData-AES.m
//  Mobile Clinic
//
//  Created by James Mendez on 11/30/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import "NSMutableData-AES.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation NSMutableData(AES)

- (NSMutableData*) EncryptAES:(NSString *)key
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero( keyPtr, sizeof(keyPtr) );
    
    [key getCString: keyPtr maxLength: sizeof(keyPtr) encoding: NSUTF16StringEncoding];
    size_t numBytesEncrypted = 0;
    
    NSUInteger dataLength = [self length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    NSMutableData *output = [[NSData alloc] init];
    
    CCCryptorStatus result = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding, keyPtr, kCCKeySizeAES256, NULL, [self mutableBytes], [self length], buffer, bufferSize, &numBytesEncrypted);
    
    output = [NSMutableData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    
    if(result == kCCSuccess) {
        return output;
    } else {
        return NULL;
    }
}

- (NSMutableData*)DecryptAES: (NSString*)key andForData:(NSMutableData*)objEncryptedData
{
    
    char  keyPtr[kCCKeySizeAES256+1];
    bzero( keyPtr, sizeof(keyPtr) );
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF16StringEncoding];
    
    size_t numBytesEncrypted = 0;
    
    NSUInteger dataLength = [self length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer_decrypt = malloc(bufferSize);
    NSMutableData *output_decrypt = [[NSData alloc] init];
    CCCryptorStatus result = CCCrypt(kCCDecrypt , kCCAlgorithmAES128, kCCOptionPKCS7Padding, keyPtr, kCCKeySizeAES256, NULL, [self mutableBytes], [self length], buffer_decrypt, bufferSize, &numBytesEncrypted);
    
    output_decrypt = [NSMutableData dataWithBytesNoCopy:buffer_decrypt length:numBytesEncrypted];
    
    if(result == kCCSuccess) {
        return output_decrypt;
    } else {
        return NULL;
    }
}

@end
