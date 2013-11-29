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
 * $Date: 2012-04-20 13:33:40 +0200 (fr, 20 apr 2012) $ $Rev: 14646 $ 
 *
 */

#import <Foundation/Foundation.h>
#import "PBSmartcard.h"

//7816 SW error codes - to be further specified
#define SW_NO_ERROR                         0x9000
#define SW_BYTES_REMAINING_00               0x6100
#define SW_CLA_NOT_SUPPORTED                0x6E00
#define SW_SECURITY_STATUS_NOT_SATISFIED    0x6982
#define SW_FILE_INVALID                     0x6983
#define SW_DATA_INVALID                     0x6984
#define SW_CONDITIONS_NOT_SATISFIED         0x6985
#define SW_COMMAND_NOT_ALLOWED              0x6986
#define SW_CORRECT_LENGTH_00                0x6C00
#define SW_INCORRECT_P1P2                   0x6A86
#define SW_INS_NOT_SUPPORTED                0x6D00
#define SW_LOGICAL_CHANNEL_NOT_SUPPORTED    0x6881
#define SW_FUNC_NOT_SUPPORTED               0x6A81
#define SW_FILE_NOT_FOUND                   0x6A82
#define SW_RECORD_NOT_FOUND                 0x6A83
#define SW_FILE_FULL                        0x6A84
#define SW_SECURE_MESSAGING_NOT_SUPPORTED   0x6882
#define SW_UNKNOWN                          0x6F00
#define SW_WARNING_STATE_UNCHANGED          0x6200
#define SW_WRONG_DATA                       0x6A80
#define SW_WRONG_LENGTH                     0x6700
#define SW_WRONG_P1P2                       0x6B00


@interface PBSmartcard7816 : PBSmartcard

// singleton receiver
+ (PBSmartcard7816*) shared7816;

// selection of ISO7816-4 commands
- (PBSmartcardStatus)selectApplicationID:(unsigned char*)applicationID 
                                ofLength:(unsigned char)applicationIDLength
                       returnsStatusWord:(unsigned short*)statusWord;


// connects to an inserted smart card with the first offered protocol
- (PBSmartcardStatus)connect;

// disconnects and resets the smart card
- (PBSmartcardStatus)disconnect;

- (BOOL)isInserted;

// Generic commands to send case 1,2 and 3 APDUs and parse the status word and data (if any)
// transmits a Case 1 short APDU to the card
-(PBSmartcardStatus) tranceiveAPDUwithClass:(unsigned char)class_
                             andInstruction:(unsigned char)instruction
                              withParameter:(unsigned char)parameter1
                               andParameter:(unsigned char)parameter2
                          returnsStatusWord:(unsigned short*)statusWord;

// transmits a Case 2 short APDU to the card
-(PBSmartcardStatus) tranceiveAPDUwithClass:(unsigned char)class_
                             andInstruction:(unsigned char)instruction
                              withParameter:(unsigned char)parameter1
                               andParameter:(unsigned char)parameter2
                             expectedLength:(unsigned char)length
                               responseData:(unsigned char**)response // memory must be freed by the caller
                                 withLength:(unsigned short*)responseLength
                          returnsStatusWord:(unsigned short*)statusWord;

// transmits a Case 3 short APDU to the card
-(PBSmartcardStatus) tranceiveAPDUwithClass:(unsigned char)class_
                             andInstruction:(unsigned char)instruction
                              withParameter:(unsigned char)parameter1
                               andParameter:(unsigned char)parameter2
                             andCommandData:(const unsigned char*)data 
                                 withLength:(unsigned char)dataLength // used as Lc
                          returnsStatusWord:(unsigned short*)statusWord;

//Case 4 short APDU not yet implemented (not supported by PCSC) use a Case 3 + Case 2 for this functionality

@end