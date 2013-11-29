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

#import "PBSmartcardIDStore.h"

#define APDU_DATA_SIZE          250

#define ID_CLA		    		0xB0
#define ID_INS_GET_PROPERTIES   0x50
#define ID_INS_WRITE            0x52
#define ID_INS_READ             0x54
#define ID_INS_GET_INFO         0x56
#define ID_INS_RESET            0x58
#define ID_P2_INIT              0x00
#define ID_P2_UPDATE            0x01
#define ID_P2_FINAL             0x02

@implementation PBSmartcardIDStore

@synthesize dataContainers;

- (id)init
{
    self = [super init];
    if (self) {
        self->dataContainers = nil;
        self->updateIDStorePropertiesIsNeeded = YES;
    }
    return self;
}

/* Override smartcardInserted/Removed and accessoryConnected/Disconnected to be able 
 * to update properties correctly, e.g. if one card is replaced by another card. */
- (void)smartcardInserted:(NSNotification *)notification
{
    updateIDStorePropertiesIsNeeded = YES;
    
    [super smartcardInserted:notification];
}
- (void)smartcardRemoved:(NSNotification *)notification
{
    updateIDStorePropertiesIsNeeded = YES;
    
    [super smartcardRemoved:notification];
}
- (void)accessoryConnected:(NSNotification *)notification
{
    updateIDStorePropertiesIsNeeded = YES;
    
    [super accessoryConnected:notification];
}
- (void)accessoryDisconnected:(NSNotification *)notification
{
    updateIDStorePropertiesIsNeeded = YES;
    
    [super accessoryDisconnected:notification];
}

/* Select the ID Store application on the card. */
- (void)selectIDStore
{
    unsigned short SW;
    unsigned char idstore_AID[] = {0xA0, 0x00, 0x00, 0x00, 0x84, 0x03};
    
    [self selectApplicationID:idstore_AID ofLength:sizeof(idstore_AID) returnsStatusWord:&SW];
}

/* Calls the card to get updated properties. */
- (void)updateIDStoreProperties
{
    PBSmartcardStatus status;
    unsigned short statusWord;
    unsigned char* receiveBuffer;
    unsigned short receiveBufferLength;
    unsigned short expectedLength = 5;
    
    if (dataContainers != nil) {
        [dataContainers release];
        dataContainers = nil;
    }
    
    if (! [self isInserted]) {
        /* Smartcard is not inserted, no need to try and talk to it. Also no
         * need for further update attempts before a card has been inserted again. */
        updateIDStorePropertiesIsNeeded = NO;
        return;
    }
    
    [self selectIDStore];
    
    status = [self tranceiveAPDUwithClass:ID_CLA
                           andInstruction:ID_INS_GET_PROPERTIES
                            withParameter:0x00
                             andParameter:0x00
                           expectedLength:expectedLength
                             responseData:&receiveBuffer
                               withLength:&receiveBufferLength
                        returnsStatusWord:&statusWord];
    
    if ((status != PBSmartcardStatusSuccess) ||
        (statusWord != SW_NO_ERROR) ||
        (receiveBufferLength != expectedLength)) {
        if(receiveBufferLength > 0) {
            free(receiveBuffer);
        }
        return;
    }
    
    unsigned char nofContainers = receiveBuffer[0];
    NSMutableArray* tempContainers = [[NSMutableArray alloc]initWithCapacity:nofContainers];
    unsigned short containerLength = ((receiveBuffer[1] << 8) + receiveBuffer[2]);
    unsigned short containersInUse = ((receiveBuffer[3] << 8) + receiveBuffer[4]);
    
    free(receiveBuffer);
    
    for (int i = 0; i < nofContainers; i++) {      
        expectedLength = 3;        
        
        status = [self tranceiveAPDUwithClass:ID_CLA
                               andInstruction:ID_INS_GET_INFO
                                withParameter:i
                                 andParameter:0x00
                               expectedLength:expectedLength
                                 responseData:&receiveBuffer
                                   withLength:&receiveBufferLength
                            returnsStatusWord:&statusWord];
        
        if ((status != PBSmartcardStatusSuccess) ||
            (statusWord != SW_NO_ERROR) ||
            (receiveBufferLength != expectedLength)) {
            if (receiveBufferLength > 0) {
                free(receiveBuffer);
            }
            [tempContainers release];
            return;
        }

        PBSmartcardIDStoreContainer* container = [[PBSmartcardIDStoreContainer alloc] init];  
        
        container.inUse = (containersInUse & (1 << i));

        if((receiveBuffer[0] & 0xf0) == 0xf0) {
            container.writeAccess = PBSmartcardIDStoreAccessConditionAnyone;
        }
        else if ((receiveBuffer[0] & 0x30) == 0x30) {
            container.writeAccess = PBSmartcardIDStoreAccessConditionBiometryOrAdmin;
        }
        else if((receiveBuffer[0] & 0x20) == 0x20) {
            container.writeAccess = PBSmartcardIDStoreAccessConditionAdminOnly;
        }
        else if ((receiveBuffer[0] & 0x10) == 0x10) {
            container.writeAccess = PBSmartcardIDStoreAccessConditionBiometryOnly;
        }
        
        if((receiveBuffer[0] & 0x0f) == 0x0f) {
            container.readAccess = PBSmartcardIDStoreAccessConditionAnyone;
        }
        else if ((receiveBuffer[0] & 0x03) == 0x03) {
            container.readAccess = PBSmartcardIDStoreAccessConditionBiometryOrAdmin;
        }
        else if((receiveBuffer[0] & 0x02) == 0x02) {
            container.readAccess = PBSmartcardIDStoreAccessConditionAdminOnly;
        }
        else if ((receiveBuffer[0] & 0x01) == 0x01) {
            container.readAccess = PBSmartcardIDStoreAccessConditionBiometryOnly;
        }
        
        container.currentlyStored = ((receiveBuffer[1] << 8) + receiveBuffer[2]);
        
        container.capacity = containerLength;
        
        [tempContainers addObject:container];
        [container release];
        
        free(receiveBuffer);
    }
    dataContainers = tempContainers;
    
    updateIDStorePropertiesIsNeeded = NO;
}

/* Overrides of the getters for the card properties. If needed, they will
 * start by calling the card to get updated properties before returning
 * the info to the caller. */

- (NSArray*)dataContainers
{
    /* Use the same lock for both IDStore and BioManager to insure that e.g. IDStore
     * is able to finish its job, before BioManager is selected on the card. */
    @synchronized ([PBSmartcardBioManager class]) 
    {
        if (updateIDStorePropertiesIsNeeded) {
            [self updateIDStoreProperties];
        }
        return dataContainers;
    }
}

- (PBSmartcardIDStoreStatus)convertFromStatusWord: (unsigned short)statusWord
{
    switch (statusWord) {
        case SW_NO_ERROR: 
            return PBSmartcardIDStoreStatusSuccess;
        case SW_FILE_NOT_FOUND: 
            return PBSmartcardIDStoreStatusInvalidContainer;
        case SW_SECURITY_STATUS_NOT_SATISFIED: 
            return PBSmartcardIDStoreStatusAccessDenied;
        case SW_WRONG_LENGTH: 
            return PBSmartcardIDStoreStatusWrongLength;
        case SW_CONDITIONS_NOT_SATISFIED: 
            return PBSmartcardIDStoreStatusContainerNotInitialized;
        default: 
            return PBSmartcardIDStoreStatusUnexpected;
    }
}

-(PBSmartcardIDStoreStatus) writeData:(void*)data 
                             ofLength:(unsigned short)length 
                          toContainer:(unsigned char)container;
{
    /* Use the same lock for both IDStore and BioManager to insure that e.g. IDStore
     * is able to finish its job, before BioManager is selected on the card. */
    @synchronized ([PBSmartcardBioManager class]) 
    {
        PBSmartcardStatus status;
        uint8_t* pdata;
        int i;
        unsigned short statusWord;
        
        [self selectIDStore];
        
        updateIDStorePropertiesIsNeeded = YES;
        
        pdata = data;
        
        unsigned char P2 = ID_P2_INIT;
        
        // send reference data in chunks (UPDATE)
        for (i = 0; i < (length / APDU_DATA_SIZE); i ++)
        {        
            status = [self tranceiveAPDUwithClass:ID_CLA
                                   andInstruction:ID_INS_WRITE
                                    withParameter:container
                                     andParameter:P2
                                   andCommandData:pdata 
                                       withLength:APDU_DATA_SIZE
                                returnsStatusWord:&statusWord];
            
            if (status != PBSmartcardStatusSuccess) return (PBSmartcardIDStoreStatus)status;
            
            if (statusWord != SW_NO_ERROR) return [self convertFromStatusWord:statusWord];
            
            pdata += APDU_DATA_SIZE;
            P2 = ID_P2_UPDATE;
        }
        
        if ((length % APDU_DATA_SIZE) > 0)
        {
            status = [self tranceiveAPDUwithClass:ID_CLA
                                   andInstruction:ID_INS_WRITE
                                    withParameter:container
                                     andParameter:P2
                                   andCommandData:pdata
                                       withLength:(length % APDU_DATA_SIZE)
                                returnsStatusWord:&statusWord];
            
            if (status != PBSmartcardStatusSuccess) return (PBSmartcardIDStoreStatus)status;
            
            if (statusWord != SW_NO_ERROR) return [self convertFromStatusWord:statusWord];
        }
        
        status = [self tranceiveAPDUwithClass:ID_CLA
                               andInstruction:ID_INS_WRITE
                                withParameter:container
                                 andParameter:ID_P2_FINAL
                            returnsStatusWord:&statusWord];
        
        if (status != PBSmartcardStatusSuccess) return (PBSmartcardIDStoreStatus)status;
        
        return [self convertFromStatusWord:statusWord];
    }
}

#define IDSTORE_MAX_STRING_LENGTH   1000

-(PBSmartcardIDStoreStatus) writeString:(NSString*)string 
                            toContainer:(unsigned char)container
{
    char buffer[IDSTORE_MAX_STRING_LENGTH];
    unsigned short bufferLength;
    
    [string getCString:buffer maxLength:IDSTORE_MAX_STRING_LENGTH encoding:NSASCIIStringEncoding];
    bufferLength = MAX(IDSTORE_MAX_STRING_LENGTH, string.length+1);
    
    return [self writeData:buffer ofLength:bufferLength toContainer:container];
}

-(PBSmartcardIDStoreStatus) readData:(void**)data  // memory must be freed by the caller
                            ofLength:(unsigned short)length
                       fromContainer:(unsigned char)container;
{
    /* Use the same lock for both IDStore and BioManager to insure that e.g. IDStore
     * is able to finish its job, before BioManager is selected on the card. */
    @synchronized ([PBSmartcardBioManager class]) 
    {
        PBSmartcardStatus status;
        unsigned short statusWord;
        // apdu receive buffer
        unsigned char* receiveBuffer;
        unsigned short receiveBufferLength;
        
        unsigned char* pResultBuffer;
        unsigned char* resultBuffer;    
        unsigned short bytesRemaining = length;
        
        // allocate the buffer to hold the final result
        resultBuffer = malloc(bytesRemaining);
        if (resultBuffer == NULL) return PBSmartcardIDStoreStatusUnexpected;
        
        [self selectIDStore];
        
        unsigned char P2 = ID_P2_INIT;
        
        pResultBuffer = resultBuffer;
        
        /* Read data from container in chunks. */
        while (bytesRemaining > 0)
        {
            unsigned short expectedLength = bytesRemaining;
            
            if(expectedLength > APDU_DATA_SIZE)
            {
                expectedLength = APDU_DATA_SIZE;
            }
            
            status = [self tranceiveAPDUwithClass:ID_CLA
                                   andInstruction:ID_INS_READ
                                    withParameter:container
                                     andParameter:P2
                                   expectedLength:expectedLength 
                                     responseData:&receiveBuffer 
                                       withLength:&receiveBufferLength 
                                returnsStatusWord:&statusWord];
            
            if ((status != PBSmartcardStatusSuccess) ||
                (statusWord != SW_NO_ERROR) ||
                (receiveBufferLength != expectedLength)) {
                free (resultBuffer);
                if (receiveBufferLength > 0) {
                    free (receiveBuffer);
                }
            }
            
            if (status != PBSmartcardStatusSuccess) return (PBSmartcardIDStoreStatus)status;
            
            if (statusWord != SW_NO_ERROR) return [self convertFromStatusWord:statusWord];
            
            if (receiveBufferLength != expectedLength) return PBSmartcardIDStoreStatusUnexpected;
            
            memcpy(pResultBuffer, receiveBuffer, receiveBufferLength);
            pResultBuffer += receiveBufferLength;
            free(receiveBuffer);
            
            bytesRemaining -= receiveBufferLength;
            
            P2 = ID_P2_UPDATE;
        }
        
        status = [self tranceiveAPDUwithClass:ID_CLA
                               andInstruction:ID_INS_READ
                                withParameter:container
                                 andParameter:ID_P2_FINAL
                            returnsStatusWord:&statusWord];
        
        if (status != PBSmartcardStatusSuccess) return (PBSmartcardIDStoreStatus)status;
        
        if (statusWord == SW_NO_ERROR) {
            *data = resultBuffer;
        }
        
        return [self convertFromStatusWord:statusWord];
    }
}

-(PBSmartcardIDStoreStatus) readString:(NSString**)string
                         fromContainer:(unsigned char)container
{
    PBSmartcardIDStoreContainer* containerObject = [self.dataContainers objectAtIndex:container];
    
    if (containerObject && containerObject.currentlyStored > 0) {
        void* buffer;
        
        int status = [self readData:&buffer ofLength:containerObject.currentlyStored fromContainer:container];
        *string = [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
        free (buffer);
        
        return status;
    }
    else {
        return PBSmartcardIDStoreStatusInvalidContainer;
    }
}

-(PBSmartcardIDStoreStatus)resetContainer:(unsigned char)container
{ 
    /* Use the same lock for both IDStore and BioManager to insure that e.g. IDStore
     * is able to finish its job, before BioManager is selected on the card. */
    @synchronized ([PBSmartcardBioManager class]) 
    {
        unsigned short statusWord;
        PBSmartcardStatus status;
        
        [self selectIDStore];
        
        updateIDStorePropertiesIsNeeded = YES;
        
        status =  [self tranceiveAPDUwithClass:ID_CLA 
                                andInstruction:ID_INS_RESET 
                                 withParameter:container 
                                  andParameter:0 
                             returnsStatusWord:&statusWord];
        
        if (status != PBSmartcardStatusSuccess) return (PBSmartcardIDStoreStatus)status;
        
        return [self convertFromStatusWord:statusWord];
    }
}

+ (NSString*)stringFromStatus: (PBSmartcardStatus)status
{
    switch ((PBSmartcardIDStoreStatus)status) {
        case PBSmartcardIDStoreStatusSuccess:
            return @"PBSmartcardIDStoreStatusSuccess";
        case PBSmartcardIDStoreStatusInvalidParameter:
            return @"PBSmartcardIDStoreStatusInvalidParameter";
        case PBSmartcardIDStoreStatusSharingViolation:
            return @"PBSmartcardIDStoreStatusSharingViolation";
        case PBSmartcardIDStoreStatusNoSmartcard:
            return @"PBSmartcardIDStoreStatusNoSmartcard";
        case PBSmartcardIDStoreStatusProtocolMismatch:
            return @"PBSmartcardIDStoreStatusProtocolMismatch";
        case PBSmartcardIDStoreStatusNotReady:
            return @"PBSmartcardIDStoreStatusNotReady";
        case PBSmartcardIDStoreStatusInvalidValue:
            return @"PBSmartcardIDStoreStatusInvalidValue";
        case PBSmartcardIDStoreStatusReaderUnavailable:
            return @"PBSmartcardIDStoreStatusReaderUnavailable";
        case PBSmartcardIDStoreStatusUnexpected:
            return @"PBSmartcardIDStoreStatusUnexpected";
        case PBSmartcardIDStoreStatusUnsupportedCard:
            return @"PBSmartcardIDStoreStatusUnsupportedCard";
        case PBSmartcardIDStoreStatusUnresponsiveCard:
            return @"PBSmartcardIDStoreStatusUnresponsiveCard";
        case PBSmartcardIDStoreStatusUnpoweredCard:
            return @"PBSmartcardIDStoreStatusUnpoweredCard";
        case PBSmartcardIDStoreStatusResetCard:
            return @"PBSmartcardIDStoreStatusResetCard";
        case PBSmartcardIDStoreStatusRemovedCard:
            return @"PBSmartcardIDStoreStatusRemovedCard";
        case PBSmartcardIDStoreStatusProtocolNotIncluded:
            return @"PBSmartcardIDStoreStatusProtocolNotIncluded";
        case PBSmartcardIDStoreStatusNotFound:
            return @"PBSmartcardIDStoreStatusNotFound";
        case PBSmartcardIDStoreStatusInvalidContainer:
            return @"PBSmartcardIDStoreStatusInvalidContainer";
        case PBSmartcardIDStoreStatusContainerNotInitialized:
            return @"PBSmartcardIDStoreStatusContainerNotInitialized";
        case PBSmartcardIDStoreStatusAccessDenied:
            return @"PBSmartcardIDStoreStatusAccessDenied";
        case PBSmartcardIDStoreStatusWrongLength:
            return @"PBSmartcardIDStoreStatusWrongLength";
            
        default:
            return @"PBSmartcardStatusUNKNOWN";
    }
}


/* Methods for strict singleton implementation. */

static PBSmartcardIDStore* _sharedSmartcardIDStore = nil;

+ (PBSmartcardIDStore*) sharedIDStore
{
    @synchronized ([PBSmartcardIDStore class]) 
    {
        if (_sharedSmartcardIDStore == nil) {
            _sharedSmartcardIDStore = [[super allocWithZone:NULL] init];
        }
        return _sharedSmartcardIDStore;
    }
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized ([PBSmartcardIDStore class]) 
    {
        return [[self sharedIDStore] retain];
    }    
}

@end
