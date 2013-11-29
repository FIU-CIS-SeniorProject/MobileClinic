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

#import "PBSmartcardBioManager.h"

#define APDU_DATA_SIZE          250

#define BM_CLA		    		0xB0
#define BM_INS_ENROLL			0x30
#define BM_INS_VERIFY			0x32
#define BM_INS_GET_BIO_HEADER   0x34
#define BM_INS_DELETE			0x36
#define BM_INS_UNBLOCK			0x38
#define BM_INS_RESET_STATUS     0x3A
#define BM_INS_GET_PROPERTIES	0x40
#define BM_INS_STATE_CONTROL	0x42
#define BM_INS_CHANGE_KEY		0x44
#define BM_INS_VERIFY_KEY		0x46
#define BM_INS_LEAVE_VIRGIN	    0x48
#define BM_P2_INIT              0x00
#define BM_P2_UPDATE            0x01
#define BM_P2_FINAL             0x02

@implementation PBSmartcardBioManager

@synthesize bioManagerVersion;
@synthesize onCardMatchingAlgorithmVersion;
@synthesize currentState;
@synthesize startKeyProperties;
@synthesize adminKeyProperties;
@synthesize biometryContainers;

- (id)init
{
    self = [super init];
    if (self) {
        self->currentySelectedApplicationID = nil;
        
        self->bioManagerVersion = @"";
        self->onCardMatchingAlgorithmVersion = @"";
        self->currentState = PBBioManagerLifeCycleStateLocked;
        self->startKeyProperties.isAuthenticated = NO;
        self->startKeyProperties.retryCounter = 0;
        self->adminKeyProperties.isAuthenticated = NO;
        self->adminKeyProperties.retryCounter = 0;
        self->biometryContainers = nil;
        
        self->updateBioManagerPropertiesIsNeeded = YES;
    }
    return self;
}

- (void)resetUpdateParameters
{
    updateBioManagerPropertiesIsNeeded = YES;
    if (currentySelectedApplicationID != nil) {
        [currentySelectedApplicationID release];
        currentySelectedApplicationID = nil;
    }    
}

/* Override open/close to be able to update properties correctly, since we may
 * miss the notifications below in some circumstances. */
- (PBSmartcardStatus)open
{
    [self resetUpdateParameters];
    return [super open];
}
- (PBSmartcardStatus)openWithDisabledBackgroundManagement
{
    [self resetUpdateParameters];
    return [super openWithDisabledBackgroundManagement];
}
- (PBSmartcardStatus)close
{
    [self resetUpdateParameters];
    return [super close];
}

/* Override smartcardInserted/Removed and accessoryConnected/Disconnected 
 * to be able to update properties correctly, e.g. if one card is replaced 
 * by another card. */
- (void)smartcardInserted:(NSNotification *)notification
{
    [self resetUpdateParameters];
    
    [super smartcardInserted:notification];
}
- (void)smartcardRemoved:(NSNotification *)notification
{
    [self resetUpdateParameters];
    
    [super smartcardRemoved:notification];
}
- (void)accessoryConnected:(NSNotification *)notification
{
    [self resetUpdateParameters];
    
    [super accessoryConnected:notification];
}
- (void)accessoryDisconnected:(NSNotification *)notification
{
    [self resetUpdateParameters];
    
    [super accessoryDisconnected:notification];
}

/* Select the BioManager application on the card. */
- (void)selectBioManager
{
    unsigned short SW;
    unsigned char biomanager_AID[] = {0xA0, 0x00, 0x00, 0x00, 0x84, 0x00};
    
    [self selectApplicationID:biomanager_AID ofLength:sizeof(biomanager_AID) returnsStatusWord:&SW];
}

- (unsigned char)templateContainerFromFingerPosition:(PBFingerPosition)position
{
    switch (position) {
        case PBFingerPositionRightIndex:
            return 0;
        case PBFingerPositionRightMiddle:
            return 2;
        case PBFingerPositionRightRing:
            return 4;
        case PBFingerPositionRightLittle:
            return 6;
        case PBFingerPositionRightThumb:
            return 8;
        case PBFingerPositionLeftIndex:
            return 1;
        case PBFingerPositionLeftMiddle:
            return 3;
        case PBFingerPositionLeftRing:
            return 5;
        case PBFingerPositionLeftLittle:
            return 7;
        case PBFingerPositionLeftThumb:
            return 9;
        case PBFingerPositionUnknown:
        default:
            return 0xff;
    } 
}

- (PBFingerPosition)fingerPositionFromTemplateContainer: (unsigned char)container
{
    switch (container) {
        case 0:
            return PBFingerPositionRightIndex;
        case 1:
            return PBFingerPositionLeftIndex;
        case 2:
            return PBFingerPositionRightMiddle;
        case 3:
            return PBFingerPositionLeftMiddle;
        case 4:
            return PBFingerPositionRightRing;
        case 5:
            return PBFingerPositionLeftRing;
        case 6:
            return PBFingerPositionRightLittle;
        case 7:
            return PBFingerPositionLeftLittle;
        case 8:
            return PBFingerPositionRightThumb;
        case 9:
            return PBFingerPositionLeftThumb;
        default:
            return PBFingerPositionUnknown;
    } 
}

/* Calls the card to get updated properties. */
- (void)updateBioManagerProperties
{    
    PBSmartcardStatus status;
    unsigned short statusWord;
    unsigned char* receivedData;
    unsigned short receivedDataLength;
    unsigned char expectedLength = 25;
    
    /* Set default values. */
    bioManagerVersion = @"";
    onCardMatchingAlgorithmVersion = @"";
    currentState = PBBioManagerLifeCycleStateLocked;
    startKeyProperties.isAuthenticated = NO;
    startKeyProperties.retryCounter = 0;
    adminKeyProperties.isAuthenticated = NO;
    adminKeyProperties.retryCounter = 0;
    if (biometryContainers != nil) {
        [biometryContainers release];
        biometryContainers = nil;
    }
    
    if (! [self isInserted]) {
        /* Smartcard is not inserted, no need to try and talk to it. Also no
         * need for further update attempts before a card has been inserted again. */
        updateBioManagerPropertiesIsNeeded = NO;
        return;
    }
    
    [self selectBioManager];
    
    status = [self tranceiveAPDUwithClass:BM_CLA
                        andInstruction:BM_INS_GET_PROPERTIES
                         withParameter:0
                          andParameter:0
                        expectedLength:expectedLength
                          responseData:&receivedData
                            withLength:&receivedDataLength
                     returnsStatusWord:&statusWord];
    
    if ((status != PBSmartcardStatusSuccess) ||
        (statusWord != SW_NO_ERROR) ||
        (receivedDataLength != expectedLength)) {
        if(receivedDataLength > 0) {
            free(receivedData);
        }
        return;
    }
    
    bioManagerVersion = [[NSMutableString alloc]initWithString:[NSString stringWithFormat:@"%d.%d", receivedData[0], receivedData[1]]];
    
    onCardMatchingAlgorithmVersion = [[NSMutableString alloc]initWithString:[NSString stringWithFormat:@"%d.%d", receivedData[2], receivedData[3]]];
    
    currentState = (PBBioManagerLifeCycleState)receivedData[4];
    
    adminKeyProperties.retryCounter = receivedData[5];
    startKeyProperties.retryCounter = receivedData[6];
    
    adminKeyProperties.isAuthenticated = (receivedData[7] & 1);
    startKeyProperties.isAuthenticated = receivedData[7] & 2;
    
    NSMutableArray* tempContainers = [[NSMutableArray alloc]initWithCapacity:receivedData[8]];
    
    unsigned short authenticated_containers = ((receivedData[19] << 8) + receivedData[20]);
    unsigned short locked_containers = ((receivedData[21] << 8) + receivedData[22]);
    unsigned short used_containers = ((receivedData[23] << 8) + receivedData[24]);
        
    for(int i = 0; i < receivedData[8]; i++)
    {
        PBSmartcardBioManagerContainer* container = [[PBSmartcardBioManagerContainer alloc] init];
        
        container.retryCounter = receivedData[9+i];
        container.isAuthenticated = (authenticated_containers & (1 << i));
        container.isLocked = (locked_containers & (1 << i));
        container.isUsed = (used_containers & (1 << i));
        container.fingerPosition = [self fingerPositionFromTemplateContainer:i];
        [tempContainers addObject:container];
        [container release];
    }
    biometryContainers = tempContainers;
    
    free(receivedData);
    
    updateBioManagerPropertiesIsNeeded = NO;
}

/* Overrides of the getters for the card properties. If needed, they will
 * start by calling the card to get updated properties before returning
 * the info to the caller. */

- (NSString*)bioManagerVersion
{
    @synchronized ([PBSmartcardBioManager class]) 
    {
        if (updateBioManagerPropertiesIsNeeded) {
            [self updateBioManagerProperties];
        }
        return bioManagerVersion;
    }    
}

- (NSString*)onCardMatchingAlgorithmVersion
{
    @synchronized ([PBSmartcardBioManager class]) 
    {
        if (updateBioManagerPropertiesIsNeeded) {
            [self updateBioManagerProperties];
        }
        return onCardMatchingAlgorithmVersion;    
    }    
}

- (PBBioManagerLifeCycleState)currentState
{
    @synchronized ([PBSmartcardBioManager class]) 
    {
        if (updateBioManagerPropertiesIsNeeded) {
            [self updateBioManagerProperties];
        }
        return currentState;
    }    
}

- (PBBioManagerKeyProperties)startKeyProperties
{
    @synchronized ([PBSmartcardBioManager class]) 
    {
        if (updateBioManagerPropertiesIsNeeded) {
            [self updateBioManagerProperties];
        }
        return startKeyProperties;    
    }    
}

- (PBBioManagerKeyProperties)adminKeyProperties
{
    @synchronized ([PBSmartcardBioManager class]) 
    {
        if (updateBioManagerPropertiesIsNeeded) {
            [self updateBioManagerProperties];
        }
        return adminKeyProperties;    
    }    
}

- (NSArray*)biometryContainers
{
    @synchronized ([PBSmartcardBioManager class]) 
    {
        if (updateBioManagerPropertiesIsNeeded) {
            [self updateBioManagerProperties];
        }
        return biometryContainers;        
    }    
}

- (PBSmartcardStatus)selectApplicationID:(unsigned char *)applicationID 
                                ofLength:(unsigned char)applicationIDLength 
                       returnsStatusWord:(unsigned short *)statusWord
{
    if ((currentySelectedApplicationID != nil) && (currentySelectedApplicationID.length == applicationIDLength)) {
        unsigned char* tempApplicationID = (unsigned char*)currentySelectedApplicationID.bytes;
        
        if (memcmp(applicationID, tempApplicationID, applicationIDLength) == 0) {
            /* Already selected. */
            return PBSmartcardStatusSuccess;
        }
    }
    
    PBSmartcardStatus status = [super selectApplicationID:applicationID ofLength:applicationIDLength returnsStatusWord:statusWord];
    if (status == PBSmartcardStatusSuccess) {
        if (currentySelectedApplicationID != nil) {
            [currentySelectedApplicationID release];        
        }
        currentySelectedApplicationID = [[NSData alloc] initWithBytes:applicationID length:applicationIDLength];
    }
    
    return status;
}

- (PBSmartcardBioManagerStatus)convertFromStatusWord: (unsigned short)statusWord
{
    switch (statusWord) {
        case SW_NO_ERROR: 
            return PBSmartcardBioManagerStatusSuccess;
        case SW_FILE_NOT_FOUND: 
            return PBSmartcardBioManagerStatusInvalidTemplate;
        case 0x6300: 
            return PBSmartcardBioManagerStatusWrongPIN;
        case SW_COMMAND_NOT_ALLOWED: 
        case SW_CONDITIONS_NOT_SATISFIED:
            return PBSmartcardBioManagerStatusWrongState;
        case SW_SECURITY_STATUS_NOT_SATISFIED:
            return PBSmartcardBioManagerStatusSecurityCondition;
        case SW_DATA_INVALID:
            return PBSmartcardBioManagerStatusInvalidData;
        default: 
            return PBSmartcardBioManagerStatusUnexpected;
    }    
}

-(PBSmartcardBioManagerStatus) verifyAnyKey:(unsigned char*)key
                                 withLength:(unsigned char)keyLength
                                      andID:(unsigned char)ID
{
    @synchronized ([PBSmartcardBioManager class]) 
    {
        unsigned short statusWord;
        
        updateBioManagerPropertiesIsNeeded = YES;
        
        PBSmartcardStatus status = [self tranceiveAPDUwithClass:BM_CLA
                                                 andInstruction:BM_INS_VERIFY_KEY
                                                  withParameter:ID 
                                                   andParameter:0 
                                                 andCommandData:key 
                                                     withLength:keyLength
                                              returnsStatusWord:&statusWord];
        
        if (status != PBSmartcardStatusSuccess) return (PBSmartcardBioManagerStatus)status;
        
        return [self convertFromStatusWord:statusWord];
    }    
}

-(PBSmartcardBioManagerStatus) unlockTemplate:(PBFingerPosition) position
{
    @synchronized ([PBSmartcardBioManager class]) 
    {
        unsigned short statusWord;
        
        [self selectBioManager];
        
        updateBioManagerPropertiesIsNeeded = YES;
        
        PBSmartcardStatus status = [self tranceiveAPDUwithClass:BM_CLA 
                                                 andInstruction:BM_INS_UNBLOCK 
                                                  withParameter:[self templateContainerFromFingerPosition:position] 
                                                   andParameter:0 
                                              returnsStatusWord:&statusWord];
        
        if (status != PBSmartcardStatusSuccess) return (PBSmartcardBioManagerStatus)status;
        
        return [self convertFromStatusWord:statusWord];
    }    
}

-(PBSmartcardBioManagerStatus) deleteTemplate:(PBFingerPosition) position
{   
    @synchronized ([PBSmartcardBioManager class]) 
    {
        unsigned short statusWord;
        
        [self selectBioManager];
        
        updateBioManagerPropertiesIsNeeded = YES;
        
        PBSmartcardStatus status = [self tranceiveAPDUwithClass:BM_CLA 
                                                 andInstruction:BM_INS_DELETE 
                                                  withParameter:[self templateContainerFromFingerPosition:position] 
                                                   andParameter:0 
                                              returnsStatusWord:&statusWord];
        
        if (status != PBSmartcardStatusSuccess) return (PBSmartcardBioManagerStatus)status;
        
        return [self convertFromStatusWord:statusWord];
    }    
}

-(PBSmartcardBioManagerStatus) verifyStartKey:(unsigned char*)key 
                                   withLength:(unsigned char)keyLength
{
    @synchronized ([PBSmartcardBioManager class]) 
    {
        [self selectBioManager];
        
        updateBioManagerPropertiesIsNeeded = YES;
        
        return [self verifyAnyKey:key withLength:keyLength andID:2];
    }    
}

-(PBSmartcardBioManagerStatus) verifyAdminKey:(unsigned char*)key 
                                   withLength:(unsigned char)keyLength
{
    @synchronized ([PBSmartcardBioManager class]) 
    {
        [self selectBioManager];
        
        updateBioManagerPropertiesIsNeeded = YES;
        
        return [self verifyAnyKey:key withLength:keyLength andID:1];
    }    
}


-(PBSmartcardBioManagerStatus) resetAuthenticationStatus:(PBFingerPosition) position;
{
    @synchronized ([PBSmartcardBioManager class]) 
    {
        unsigned short statusWord;
        
        [self selectBioManager];
        
        updateBioManagerPropertiesIsNeeded = YES;
        
        PBSmartcardStatus status = [self tranceiveAPDUwithClass:BM_CLA 
                                                 andInstruction:BM_INS_RESET_STATUS 
                                                  withParameter:[self templateContainerFromFingerPosition:position] 
                                                   andParameter:0 
                                              returnsStatusWord:&statusWord];
        
        if (status != PBSmartcardStatusSuccess) return (PBSmartcardBioManagerStatus)status;
        
        return [self convertFromStatusWord:statusWord];
    }    
}

-(PBSmartcardBioManagerStatus) leaveVirginState:(unsigned char**)randomKey 
                                      keyLength:(unsigned char*)keyLength
{
    @synchronized ([PBSmartcardBioManager class]) 
    {
        unsigned short statusWord;
        unsigned short receivedKeyLength;
        unsigned char expectedLength = 8;
        
        [self selectBioManager];
        
        updateBioManagerPropertiesIsNeeded = YES;
        
        PBSmartcardStatus status = [self tranceiveAPDUwithClass:BM_CLA
                                                 andInstruction:BM_INS_LEAVE_VIRGIN
                                                  withParameter:0
                                                   andParameter:0
                                                 expectedLength:expectedLength
                                                   responseData:randomKey
                                                     withLength:&receivedKeyLength
                                              returnsStatusWord:&statusWord];
        
        if (status != PBSmartcardStatusSuccess) return (PBSmartcardBioManagerStatus)status;
        
        if (statusWord == SW_NO_ERROR) {
            *keyLength = receivedKeyLength;
            currentState = PBBioManagerLifeCycleStateInitialization;         
        }
        
        return [self convertFromStatusWord:statusWord];
    }    
}

-(PBSmartcardBioManagerStatus) changeState:(PBBioManagerLifeCycleState)newState
{
    @synchronized ([PBSmartcardBioManager class]) 
    {
        unsigned short statusWord;
        
        [self selectBioManager];
        
        PBSmartcardStatus status = [self tranceiveAPDUwithClass:BM_CLA 
                                                 andInstruction:BM_INS_STATE_CONTROL 
                                                  withParameter:newState 
                                                   andParameter:0 
                                              returnsStatusWord:&statusWord];
        
        if (status != PBSmartcardStatusSuccess) return (PBSmartcardBioManagerStatus)status;
        
        if (statusWord == SW_NO_ERROR) {
            currentState = newState;
        }
        
        return [self convertFromStatusWord:statusWord];
    }    
}

-(PBSmartcardBioManagerStatus) enrollFinger:(PBFingerPosition) position
                               withTemplate:(PBBiometryTemplate*)template_;
{
    const unsigned char* header;
    unsigned int headerLength;
    const unsigned char* reference;
    unsigned int referenceLength;
    
    [self selectBioManager];
    
    updateBioManagerPropertiesIsNeeded = YES;
    
    /* Parse header & reference from combined template. 
     * The combined template consists of 2 bytes specifying the length of the
     * reference data, followed by the reference data, followed by 2 bytes specifying
     * the length of the header data followed by the header data. */
    if (template_.templateType == PBBiometryTemplateTypeBioMatch3Enrollment) {
        uint8_t* p = template_.data;
        
        referenceLength = (p[0] << 8) | p[1];
        reference = &p[2];
        p += 2 + referenceLength;
        headerLength = (p[0] << 8) | p[1];
        header = &p[2];
        
        return [self enrollFinger:position usingHeader:header withLength:headerLength andReferenceData:reference withLength:referenceLength];
    }
    
    return PBSmartcardBioManagerStatusInvalidTemplate;
}

-(PBSmartcardBioManagerStatus) enrollFinger:(PBFingerPosition) position
                                usingHeader:(const unsigned char*) biometricHeader
                                 withLength:(unsigned char)  biometricHeaderLength
                           andReferenceData:(const unsigned char*) referenceData
                                 withLength:(unsigned short) referenceDataLength
{
    @synchronized ([PBSmartcardBioManager class]) 
    {
        PBSmartcardStatus status;
        unsigned char container = [self templateContainerFromFingerPosition:position];
        int i;
        unsigned short statusWord;
        
        if (biometricHeaderLength > APDU_DATA_SIZE) {
            return PBSmartcardBioManagerStatusInvalidTemplate;
        }
        
        [self selectBioManager];
        
        updateBioManagerPropertiesIsNeeded = YES;
        
        /* Enroll biometric header. */
        status = [self tranceiveAPDUwithClass:BM_CLA
                               andInstruction:BM_INS_ENROLL
                                withParameter:container
                                 andParameter:BM_P2_INIT
                               andCommandData:biometricHeader 
                                   withLength:biometricHeaderLength
                            returnsStatusWord:&statusWord];
        
        if (status != PBSmartcardStatusSuccess) return (PBSmartcardBioManagerStatus)status;
        
        if (statusWord != SW_NO_ERROR) return [self convertFromStatusWord:statusWord];
        
        /* Enroll reference template. */
        
        /* Send reference data in chunks (UPDATE). */
        const unsigned char* pReferenceData = referenceData;    
        for(i = 0; i < (referenceDataLength / APDU_DATA_SIZE); i++) {
            status = [self tranceiveAPDUwithClass:BM_CLA
                                   andInstruction:BM_INS_ENROLL
                                    withParameter:container
                                     andParameter:BM_P2_UPDATE
                                   andCommandData:pReferenceData 
                                       withLength:APDU_DATA_SIZE
                                returnsStatusWord:&statusWord];
            
            if (status != PBSmartcardStatusSuccess) return (PBSmartcardBioManagerStatus)status;
            
            if (statusWord != SW_NO_ERROR) return [self convertFromStatusWord:statusWord];
            
            pReferenceData += APDU_DATA_SIZE;
        }
        /* Send the remaining data. */
        if ((referenceDataLength % APDU_DATA_SIZE) > 0) {
            status = [self tranceiveAPDUwithClass:BM_CLA
                                   andInstruction:BM_INS_ENROLL
                                    withParameter:container
                                     andParameter:BM_P2_FINAL
                                   andCommandData:pReferenceData 
                                       withLength:(referenceDataLength % APDU_DATA_SIZE)
                                returnsStatusWord:&statusWord];
            
            if (status != PBSmartcardStatusSuccess) return (PBSmartcardBioManagerStatus)status;
            
            return [self convertFromStatusWord:statusWord];
        }
        return PBSmartcardBioManagerStatusSuccess;
    }        
}

-(PBSmartcardBioManagerStatus) getHeaderForFinger:(PBFingerPosition)position
                                        bioHeader:(unsigned char**)header  // must be freed by caller
                                       withLength:(unsigned char*)headerLength
{
    @synchronized ([PBSmartcardBioManager class]) 
    {
        PBSmartcardStatus status;
        unsigned short statusWord;
        unsigned char expectedLength = 118;
        
        [self selectBioManager];
        
        unsigned char* receiveBuffer;
        unsigned short receiveBufferLength;
        
        status = [self tranceiveAPDUwithClass:BM_CLA
                               andInstruction:BM_INS_GET_BIO_HEADER
                                withParameter:[self templateContainerFromFingerPosition:position]
                                 andParameter:0
                               expectedLength:expectedLength 
                                 responseData:&receiveBuffer
                                   withLength:&receiveBufferLength
                            returnsStatusWord:&statusWord];
        
        if (status != PBSmartcardStatusSuccess) return (PBSmartcardBioManagerStatus)status;
        
        if (statusWord == SW_NO_ERROR) {
            if (receiveBufferLength == expectedLength) {
                *header = receiveBuffer;
                *headerLength = receiveBufferLength;
            }
            else {
                if (receiveBufferLength > 0) {
                    free (receiveBuffer);
                }
                return PBSmartcardBioManagerStatusInvalidData;
            }        
        }
        
        return [self convertFromStatusWord:statusWord];
    }    
}

-(PBSmartcardBioManagerStatus) verifyFinger:(PBFingerPosition)position
                       withVerificationData:(unsigned char*)verificationData
                                   ofLength:(unsigned short)verificationDataLength
                                   didMatch:(BOOL*)match
{
    @synchronized ([PBSmartcardBioManager class]) 
    {
        PBSmartcardStatus status;
        uint8_t* pVerificationData;
        unsigned char container = [self templateContainerFromFingerPosition:position];
        int i;
        unsigned short statusWord;
        
        *match = NO;
        
        [self selectBioManager];
        
        updateBioManagerPropertiesIsNeeded = YES;
        
        pVerificationData = verificationData;
        
        unsigned char P2 = BM_P2_INIT;
        
        /* Send reference data in chunks (UPDATE). */
        for(i = 0; i < (verificationDataLength / APDU_DATA_SIZE); i++) {
            status = [self tranceiveAPDUwithClass:BM_CLA
                                   andInstruction:BM_INS_VERIFY
                                    withParameter:container
                                     andParameter:P2
                                   andCommandData:pVerificationData
                                       withLength:APDU_DATA_SIZE
                                returnsStatusWord:&statusWord];
            
            if (status != PBSmartcardStatusSuccess) return (PBSmartcardBioManagerStatus)status;
            
            if (statusWord != SW_NO_ERROR) {
                goto done;
            }
            
            pVerificationData += APDU_DATA_SIZE;
            P2 = BM_P2_UPDATE;
        }
        /* Send the remaining data. */
        if ((verificationDataLength % APDU_DATA_SIZE) > 0) {
            status = [self tranceiveAPDUwithClass:BM_CLA
                                   andInstruction:BM_INS_VERIFY
                                    withParameter:container
                                     andParameter:P2
                                   andCommandData:pVerificationData
                                       withLength:(verificationDataLength % APDU_DATA_SIZE)
                                returnsStatusWord:&statusWord];
            
            if (status != PBSmartcardStatusSuccess) return (PBSmartcardBioManagerStatus)status;
            
            if (statusWord != SW_NO_ERROR) {
                goto done;
            }
            
        }
        
        status = [self tranceiveAPDUwithClass:BM_CLA
                               andInstruction:BM_INS_VERIFY
                                withParameter:container
                                 andParameter:BM_P2_FINAL
                            returnsStatusWord:&statusWord];
        
        if (status != PBSmartcardStatusSuccess) return (PBSmartcardBioManagerStatus)status;
        
    done:
        
        if (statusWord == SW_NO_ERROR) {
            *match = YES;
        }
        
        PBSmartcardBioManagerStatus bioManagerStatus = [self convertFromStatusWord:statusWord];
        if (bioManagerStatus == PBSmartcardBioManagerStatusWrongPIN) {
            /* Finger did not match, but this is still a valid use case. */
            bioManagerStatus = PBSmartcardBioManagerStatusSuccess;
        }
        
        return bioManagerStatus; 
    }    
}

/* Methods for strict singleton implementation. */

static PBSmartcardBioManager* _sharedSmartcardBioManager = nil;

+ (PBSmartcardBioManager*) sharedBioManager
{
    @synchronized ([PBSmartcardBioManager class]) 
    {
        if (_sharedSmartcardBioManager == nil) {
            _sharedSmartcardBioManager = [[super allocWithZone:NULL] init];
        }
        return _sharedSmartcardBioManager;
    }
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized ([PBSmartcardBioManager class]) 
    {
        return [[self sharedBioManager] retain];
    }    
}

@end
 