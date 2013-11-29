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

#import "PBSmartcard7816.h"

#define APDU_HEADER_SIZE 5

@implementation PBSmartcard7816

- (PBSmartcardStatus)selectApplicationID:(unsigned char*)applicationID 
                                ofLength:(unsigned char)applicationIDLength
                       returnsStatusWord:(unsigned short*)statusWord;
{
    @synchronized ([PBSmartcard7816 class]) 
    {
        //unsigned char cmd[5+5+11]; /* CLA,INS,P1,P2,Lc + max RID 5 bytes + max PIX 11 bytes */
        if (applicationIDLength > 16) {
            return PBSmartcardStatusInvalidParameter;
        }
        
        return [self tranceiveAPDUwithClass:0x00
                             andInstruction:0xA4
                              withParameter:0x04
                               andParameter:0x00 
                             andCommandData:applicationID
                                 withLength:applicationIDLength
                          returnsStatusWord:statusWord];
    }
}

- (PBSmartcardStatus)connect
{
    @synchronized ([PBSmartcard7816 class]) 
    {
        return [self connect:PBSmartcardProtocolTx];
    }
}

- (PBSmartcardStatus)disconnect
{
    @synchronized ([PBSmartcard7816 class]) 
    {
        return [self disconnect:PBSmartcardDispositionResetCard];
    }
}

- (BOOL)isInserted
{
    @synchronized ([PBSmartcard7816 class]) 
    {
        PBSmartcardSlotStatus slotStatus = [self getSlotStatus];
        
        return (slotStatus == PBSmartcardSlotStatusPresent) || (slotStatus == PBSmartcardSlotStatusPresentConnected);
    }
}

// Generic commands to send case 1,2 and 3 APDUs and parse the status word and data (if any)

//Case 1 short APDU 
-(PBSmartcardStatus) tranceiveAPDUwithClass:(unsigned char)class_
                             andInstruction:(unsigned char)instruction
                              withParameter:(unsigned char)parameter1
                               andParameter:(unsigned char)parameter2
                          returnsStatusWord:(unsigned short*)statusWord;
{
    return [self tranceiveAPDUwithClass:class_
                         andInstruction:instruction
                          withParameter:parameter1
                           andParameter:parameter2
                         andCommandData:NULL 
                             withLength:0
                      returnsStatusWord:statusWord];
}

// Case 2 short APDU
-(PBSmartcardStatus) tranceiveAPDUwithClass:(unsigned char)class_
                             andInstruction:(unsigned char)instruction
                              withParameter:(unsigned char)parameter1
                               andParameter:(unsigned char)parameter2
                             expectedLength:(unsigned char)length
                               responseData:(unsigned char**)response // memory must be freed by the caller
                                 withLength:(unsigned short*)responseLength
                          returnsStatusWord:(unsigned short*)statusWord;
{
    @synchronized ([PBSmartcard7816 class]) 
    {
        PBSmartcardStatus status;
        unsigned char sendBuffer[APDU_HEADER_SIZE];
        unsigned char receiveBuffer[256]; // TBD size
        unsigned short receiveLength;
        
        if (response == NULL || responseLength == NULL) return PBSmartcardStatusInvalidParameter;
        
        *responseLength = 0;
        
        sendBuffer[0] = class_; 
        sendBuffer[1] = instruction;
        sendBuffer[2] = parameter1;
        sendBuffer[3] = parameter2;
        sendBuffer[4] = length;
        
        receiveLength = sizeof(receiveBuffer);
        
        status = [self transmit:sendBuffer
              withCommandLength:sizeof(sendBuffer)
              andResponseBuffer:receiveBuffer
              andResponseLength:&receiveLength];
        
        if (status != PBSmartcardStatusSuccess) return status;
        
        if (receiveLength > 2)
        {
            *response = malloc(receiveLength-2);
            if (*response == NULL) return PBSmartcardStatusUnexpected;
            
            memcpy(*response, receiveBuffer, receiveLength-2);
            *responseLength = receiveLength-2;
        }
        
        *statusWord =((receiveBuffer[receiveLength-2] << 8) | (receiveBuffer[receiveLength-1]));
        
        return PBSmartcardStatusSuccess;
    }
}

//Case 3 short APDU 
-(PBSmartcardStatus) tranceiveAPDUwithClass:(unsigned char)class_
                             andInstruction:(unsigned char)instruction
                              withParameter:(unsigned char)parameter1
                               andParameter:(unsigned char)parameter2
                             andCommandData:(const unsigned char*)data 
                                 withLength:(unsigned char)dataLength // used as Lc
                          returnsStatusWord:(unsigned short*)statusWord;
{
    @synchronized ([PBSmartcard7816 class]) 
    {
        PBSmartcardStatus status;
        unsigned char receiveBuffer[256]; // TBD size
        unsigned short receiveLength;
        unsigned char* sendBuffer;
        unsigned short commandLength;
        
        if (data == NULL && dataLength != 0) return PBSmartcardStatusInvalidParameter;
        
        commandLength = APDU_HEADER_SIZE + dataLength;
        
        sendBuffer = malloc(commandLength);
        if (sendBuffer == NULL) return PBSmartcardStatusUnexpected;
        
        sendBuffer[0] = class_; 
        sendBuffer[1] = instruction;
        sendBuffer[2] = parameter1;
        sendBuffer[3] = parameter2;
        sendBuffer[4] = dataLength;
        memcpy(&sendBuffer[5], data, dataLength);
        
        receiveLength = sizeof(receiveBuffer);
        
        status = [self transmit:sendBuffer
              withCommandLength:commandLength
              andResponseBuffer:receiveBuffer
              andResponseLength:&receiveLength];
        
        free(sendBuffer);
        
        if (status != PBSmartcardStatusSuccess) return status;
        
        *statusWord =((receiveBuffer[receiveLength-2] << 8) | (receiveBuffer[receiveLength-1]));
        
        return PBSmartcardStatusSuccess;
    }
}

/* Methods for strict singleton implementation. */

static PBSmartcard7816* _sharedSmartcard7816 = nil;

+ (PBSmartcard7816*) shared7816
{
    @synchronized ([PBSmartcard7816 class]) 
    {
        if (_sharedSmartcard7816 == nil) {
            _sharedSmartcard7816 = [[super allocWithZone:NULL] init];
        }
        return _sharedSmartcard7816;
    }
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized ([PBSmartcard7816 class]) 
    {
        return [[self shared7816] retain];
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
