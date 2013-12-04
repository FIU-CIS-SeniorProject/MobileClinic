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
 * $Date: 2012-04-20 13:34:23 +0200 (fr, 20 apr 2012) $ $Rev: 14647 $ 
 *
 */

#import <Foundation/Foundation.h>
#import "PBBiometryFinger.h"
#import "PBBiometryTemplate.h"
#import "PBSmartcard7816.h"
#import "PBSmartcardBioManagerContainer.h"

/** Status codes for a BioManager smartcard. */
typedef enum {
    PBSmartcardBioManagerStatusSuccess = PBSmartcardStatusSuccess,
    PBSmartcardBioManagerStatusInvalidParameter = PBSmartcardStatusInvalidParameter,
    PBSmartcardBioManagerStatusSharingViolation = PBSmartcardStatusSharingViolation,
    PBSmartcardBioManagerStatusNoSmartcard = PBSmartcardStatusNoSmartcard,
    PBSmartcardBioManagerStatusProtocolMismatch = PBSmartcardStatusProtocolMismatch,
    PBSmartcardBioManagerStatusNotReady = PBSmartcardStatusNotReady,
    PBSmartcardBioManagerStatusInvalidValue = PBSmartcardStatusInvalidValue,
    PBSmartcardBioManagerStatusReaderUnavailable = PBSmartcardStatusReaderUnavailable,
    PBSmartcardBioManagerStatusUnexpected = PBSmartcardStatusUnexpected,
    PBSmartcardBioManagerStatusUnsupportedCard = PBSmartcardStatusUnsupportedCard,
    PBSmartcardBioManagerStatusUnresponsiveCard = PBSmartcardStatusUnresponsiveCard,
    PBSmartcardBioManagerStatusUnpoweredCard = PBSmartcardStatusUnpoweredCard, 
    PBSmartcardBioManagerStatusResetCard = PBSmartcardStatusResetCard, 
    PBSmartcardBioManagerStatusRemovedCard = PBSmartcardStatusRemovedCard, 
    PBSmartcardBioManagerStatusProtocolNotIncluded = PBSmartcardStatusProtocolNotIncluded,
    /** No applet w/ the expected AID was found on the card. */
    PBSmartcardBioManagerStatusNotFound,
    /** The content of the data is not valid for the specific command. */
    PBSmartcardBioManagerStatusInvalidData,
    /** Mismatch finger position / container. */
    PBSmartcardBioManagerStatusInvalidTemplate,
    /** The command is not allowed in the current life cycle state. */
    PBSmartcardBioManagerStatusWrongState,
    /** The required key is not verified. */
    PBSmartcardBioManagerStatusSecurityCondition,
    /** PIN verification failed. */
    PBSmartcardBioManagerStatusWrongPIN
} PBSmartcardBioManagerStatus;

/** BioManager states (see BioManager manual for details). */
typedef enum {
    PBBioManagerLifeCycleStateVirgin = 0x01,
    PBBioManagerLifeCycleStateInitialization = 0x02,    
    PBBioManagerLifeCycleStateAdministration = 0x04,
    PBBioManagerLifeCycleStateOperational = 0x08,
    PBBioManagerLifeCycleStateLocked = 0x80
} PBBioManagerLifeCycleState;

/** BioManager key properties. */
typedef struct {
    unsigned char retryCounter; // current number of remaining retries before the key is locked
    BOOL isAuthenticated; // true if the key is currently verified, false otherwise. 
} PBBioManagerKeyProperties;


@interface PBSmartcardBioManager : PBSmartcard7816
{    
    /** Version of the BioManager applet coded as major.minor. */
    NSString* bioManagerVersion;
    /** Version of the BioMatch package coded as major.minor. */
    NSString* onCardMatchingAlgorithmVersion;
    /** The current state of the BioManager applet. */
    PBBioManagerLifeCycleState currentState;
    /** The administration key properties. */
    PBBioManagerKeyProperties adminKeyProperties;
    /** The start key properties. */
    PBBioManagerKeyProperties startKeyProperties;
    /** Array of BioManager containers (PBSmartcardBioManagerContainer). */
    NSArray* biometryContainers;
    
@private
    /** The currently selected application id, if any. Used so that the same application
     * is not selected twice. */
    NSData* currentySelectedApplicationID;
    
    /** Tells if it is required to call the card to get updates for the card properties. */
    BOOL updateBioManagerPropertiesIsNeeded;
}

@property (readonly) NSString* bioManagerVersion;
@property (readonly) NSString* onCardMatchingAlgorithmVersion;
@property (readonly) PBBioManagerLifeCycleState currentState;
@property (readonly) PBBioManagerKeyProperties adminKeyProperties;
@property (readonly) PBBioManagerKeyProperties startKeyProperties;
@property (readonly) NSArray* biometryContainers;

// singleton receiver
+ (PBSmartcardBioManager*) sharedBioManager;

// BioManager methods

/**
 Unlocks a locked biometric template.
 @param[in] position Finger position.
 
 @returns PBSmartcardBioManagerStatusSuccess if the write operation was succesful, 
    otherwise an error code.
*/
-(PBSmartcardBioManagerStatus) unlockTemplate:(PBFingerPosition) position;

/**
 Deletes a biometric template
 @param[in] position Finger position.
 
 @returns PBSmartcardBioManagerStatusSuccess if the write operation was succesful, 
    otherwise an error code.
 */
-(PBSmartcardBioManagerStatus) deleteTemplate:(PBFingerPosition) position;

/**
 Verifies the admin key
 @param[in] key is the admin key
 @param[in] keyLength is the length of the admin key
 
 @returns PBSmartcardBioManagerStatusSuccess if the write operation was succesful, 
    otherwise an error code.
 */
 -(PBSmartcardBioManagerStatus) verifyAdminKey:(unsigned char*)key 
                                    withLength:(unsigned char)keyLength;

/**
 Verifies the start key
 @param[in] key is the start key
 @param[in] keyLength is the length of the start key
 
 @returns PBSmartcardBioManagerStatusSuccess if the write operation was succesful, 
    otherwise an error code.
 */
-(PBSmartcardBioManagerStatus) verifyStartKey:(unsigned char*)key 
                                   withLength:(unsigned char)keyLength;

/**
 Leaves the virgin state and receives the random start key
 @param[out] randomKey the start key generated by the card. The caller is responsible to release the memory.
 @param[out] keyLength the length of the random key in bytes.
 
 @returns PBSmartcardBioManagerStatusSuccess if the write operation was succesful, 
    otherwise an error code.
 */
-(PBSmartcardBioManagerStatus) leaveVirginState:(unsigned char**)randomKey // memory must be freed by the caller
                                      keyLength:(unsigned char*)keyLength;

/**
  Resets the isAuthenticated flag for a biometric template.
 @param[in] position Finger position.
 
 @returns PBSmartcardBioManagerStatusSuccess if the write operation was succesful, 
    otherwise an error code.
 */
-(PBSmartcardBioManagerStatus) resetAuthenticationStatus:(PBFingerPosition) position;

/**
 Changes the state of the BioManager.
 @param[in] newState The new state
 
 @returns PBSmartcardBioManagerStatusSuccess if the write operation was succesful, 
    otherwise an error code.
 */
-(PBSmartcardBioManagerStatus) changeState:(PBBioManagerLifeCycleState)newState;

/**
 Stores / enrols a BioMatch 3 template on the card.
 @param[in] position Finger position.
 @param[in] template_ The biometric template
 
 @returns PBSmartcardBioManagerStatusSuccess if the write operation was succesful, 
    otherwise an error code.
 */
-(PBSmartcardBioManagerStatus) enrollFinger:(PBFingerPosition) position
                               withTemplate:(PBBiometryTemplate*)template_;

/**
 Stores / enrols a BioMatch 3 template on the card.
 @param[in] position Finger position.
 @param[in] biometricHeader The biometric header part of the enrolment data
 @param[in] biometricHeaderLength The size of the biometric header in bytes
 @param[in] referenceData The reference part of the enrolment data
 @param[in] referenceDataLength The size of the biometric reference data
 
 @returns PBSmartcardBioManagerStatusSuccess if the write operation was succesful, 
    otherwise an error code.
 */
-(PBSmartcardBioManagerStatus) enrollFinger:(PBFingerPosition) position
                                usingHeader:(const unsigned char*) biometricHeader
                                 withLength:(unsigned char)  biometricHeaderLength
                           andReferenceData:(const unsigned char*) referenceData
                                 withLength:(unsigned short) referenceDataLength;

/**
 Retrieves the biometric header for an enrolled finger
 @param[in] position Finger position.
 @param[out] header The biometric header. The caller is responsible to release the memory.
 @param[out] headerLength the length of the biometric header.
 
 @returns PBSmartcardBioManagerStatusSuccess if the write operation was succesful, 
    otherwise an error code.
 */
-(PBSmartcardBioManagerStatus) getHeaderForFinger:(PBFingerPosition)position
                                        bioHeader:(unsigned char**)header  // must be freed by caller
                                       withLength:(unsigned char*)headerLength;

/**
 Sends verification data to the card, performs a match-on-card for one finger and returns the match result as a boolean.
 @param[in] position Finger position.
 @param[in] verificationData The verification data
 @param[in] verificationDataLength length of the vrification data
 @param[out] match result of the on-card match. true if the match was as success, false otherwise.
 
 @returns PBSmartcardBioManagerStatusSuccess if the write operation was succesful, 
    otherwise an error code.
 */
-(PBSmartcardBioManagerStatus) verifyFinger:(PBFingerPosition) position
                      withVerificationData : (unsigned char*) verificationData
                                  ofLength : (unsigned short)verificationDataLength
                                  didMatch : (BOOL*)match; 


@end
