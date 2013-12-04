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
#import "PBSmartcardBioManager.h"
#import "PBSmartcardIDStoreContainer.h"


/** Status codes for an ID Store smartcard. */
typedef enum {
    PBSmartcardIDStoreStatusSuccess = PBSmartcardStatusSuccess,
    PBSmartcardIDStoreStatusInvalidParameter = PBSmartcardStatusInvalidParameter,
    PBSmartcardIDStoreStatusSharingViolation = PBSmartcardStatusSharingViolation,
    PBSmartcardIDStoreStatusNoSmartcard = PBSmartcardStatusNoSmartcard,
    PBSmartcardIDStoreStatusProtocolMismatch = PBSmartcardStatusProtocolMismatch,
    PBSmartcardIDStoreStatusNotReady = PBSmartcardStatusNotReady,
    PBSmartcardIDStoreStatusInvalidValue = PBSmartcardStatusInvalidValue,
    PBSmartcardIDStoreStatusReaderUnavailable = PBSmartcardStatusReaderUnavailable,
    PBSmartcardIDStoreStatusUnexpected = PBSmartcardStatusUnexpected,
    PBSmartcardIDStoreStatusUnsupportedCard = PBSmartcardStatusUnsupportedCard,
    PBSmartcardIDStoreStatusUnresponsiveCard = PBSmartcardStatusUnresponsiveCard,
    PBSmartcardIDStoreStatusUnpoweredCard = PBSmartcardStatusUnpoweredCard, 
    PBSmartcardIDStoreStatusResetCard = PBSmartcardStatusResetCard, 
    PBSmartcardIDStoreStatusRemovedCard = PBSmartcardStatusRemovedCard, 
    PBSmartcardIDStoreStatusProtocolNotIncluded = PBSmartcardStatusProtocolNotIncluded,
    /** IDStore applet not found on the card. */
    PBSmartcardIDStoreStatusNotFound,
    /** The selected container is invalid, or nothing has been written to it (is empty). */
    PBSmartcardIDStoreStatusInvalidContainer,
    /** The selected container is not initialized. */
    PBSmartcardIDStoreStatusContainerNotInitialized,
    /** The operation is not allowed (probably due to the container access conditions not satisfied). */
    PBSmartcardIDStoreStatusAccessDenied,
    /** Unsupported or wrong length parameters. */
    PBSmartcardIDStoreStatusWrongLength,
} PBSmartcardIDStoreStatus;

@interface PBSmartcardIDStore : PBSmartcardBioManager
{
    // Array of IDStore containers (PBSmartcardIDStoreContainer)
    NSArray* dataContainers;  
    
@private
    /* Tells if it is required to call the card to get updates for the card properties. */
    BOOL updateIDStorePropertiesIsNeeded;
}

@property (readonly)NSArray* dataContainers;

// singleton receiver
+(PBSmartcardIDStore*) sharedIDStore;

/**
 Writes data to a container.
 
 @param[in] data Data to be written
 @param[in] length Length of the data to be written in bytes
 @param[in] container Index of the container to write to.
 
 @returns PBSmartcardIDStoreStatusSuccess if the write operation was succesful, 
    otherwise an error code.
 */
-(PBSmartcardIDStoreStatus) writeData:(void*)data 
                             ofLength:(unsigned short)length 
                          toContainer:(unsigned char)container;

/**
 Writes a string to a container.
 
 @param[in] string String to be written
 @param[in] container Index of the container to write to.
 
 @returns PBSmartcardIDStoreStatusSuccess if the write operation was succesful, 
    otherwise an error code.
 */
-(PBSmartcardIDStoreStatus) writeString:(NSString*)string 
                            toContainer:(unsigned char)container;

/**
 Reads a number of bytes from a container.
 
 @param[out] data Buffer of data read from the card. The caller is responsible to release the memory. 
 @param[in] length Number of bytes to read
 @param[in] container Index of the container to read from.
 
 @returns PBSmartcardIDStoreStatusSuccess if the write operation was succesful, 
    otherwise an error code.
 */
-(PBSmartcardIDStoreStatus) readData:(void**)data  // memory must be freed by the caller
                            ofLength:(unsigned short)length
                       fromContainer:(unsigned char)container;

/**
 Reads a string from a container.
 
 @param[out] string String read from the card. 
 @param[in] container Index of the container to read from.
 
 @returns PBSmartcardIDStoreStatusSuccess if the write operation was succesful, 
    otherwise an error code.
 */
-(PBSmartcardIDStoreStatus) readString:(NSString**)string
                         fromContainer:(unsigned char)container;

/**
 Resets a container and erases all data written. 
 
 @param[in] container Index of the container to reset.
 
 @returns PBSmartcardIDStoreStatusSuccess if the write operation was succesful, 
    otherwise an error code.
 */
-(PBSmartcardIDStoreStatus) resetContainer:(unsigned char)container;

@end
