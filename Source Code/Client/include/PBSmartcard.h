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
 * $Date: 2012-05-21 18:41:21 +0200 (må, 21 maj 2012) $ $Rev: 14780 $ 
 *
 */

#import <Foundation/Foundation.h>

/** Status (return) codes. */
typedef enum 
{
    /** No error was encountered. */
    PBSmartcardStatusSuccess,
    /** One or more of the supplied parameters could not be properly interpreted. */
    PBSmartcardStatusInvalidParameter,
    /** The smart card cannot be accessed because of other connections outstanding. */
    PBSmartcardStatusSharingViolation,
    /** The operation requires a Smart Card, but no Smart Card is currently in the device. */
    PBSmartcardStatusNoSmartcard,
    /** The requested protocols are incompatible with the protocol currently in use with the smart card. */
    PBSmartcardStatusProtocolMismatch,
    /** The reader or smart card is not ready to accept commands. */
    PBSmartcardStatusNotReady,
    /** One or more of the supplied parameters values could not be properly interpreted. */
    PBSmartcardStatusInvalidValue,
    /** The specified reader is not currently available for use. */
    PBSmartcardStatusReaderUnavailable,
    /** An unexpected card error has occurred. */
    PBSmartcardStatusUnexpected,
    /** The reader cannot communicate with the card, due to ATR string configuration conflicts. */
    PBSmartcardStatusUnsupportedCard,
    /** The smart card is not responding to a reset. */
    PBSmartcardStatusUnresponsiveCard,
    /** Power has been removed from the smart card, so that further communication is not possible. */
    PBSmartcardStatusUnpoweredCard, 
    /** The smart card has been reset, so any shared state information is invalid. */
    PBSmartcardStatusResetCard, 
    /** The smart card has been removed, so further communication is not possible. */
    PBSmartcardStatusRemovedCard, 
    /** No open connection to the card */
    PBSmartcardStatusNotConnected, 
    /** The low level session to the Tactivo has been forcedly terminated by iOS and further communication is not possible. */
    PBSmartcardStatusInternalSessionLost, 
    /** All necessary supported protocols are not defined in the plist file */
    PBSmartcardStatusProtocolNotIncluded,
    /** The requested operation is not supported with the current hardware/software setup. This error can be returned when an old iOS version or a Tactivo with an outdated firmware is used.*/
    PBSmartcardStatusNotSupported
} PBSmartcardStatus;


/** Smart card protocols. */
typedef enum
{
    /** Protocol not set */
    PBSmartcardProtocolUndefined,
    /** T=0 active protocol. */
    PBSmartcardProtocolT0,
    /** T=1 active protocol. */
    PBSmartcardProtocolT1,
    /** IFD determines protocol. */
    PBSmartcardProtocolTx
} PBSmartcardProtocol; 

/** States describing the Slot status. */
typedef enum 
{
    /** The status of the slot is unknown. Typically set before the first call to openReader or when a Tactivo isn't connected to the iOS device */
    PBSmartcardSlotStatusUnknown,
    /** A card is present in the card reader slot. */
    PBSmartcardSlotStatusPresent,
    /** A card is present and a connection to the card is established */
    PBSmartcardSlotStatusPresentConnected,
    /** The card reader slot is empty. */
    PBSmartcardSlotStatusEmpty
} PBSmartcardSlotStatus;

/** Action to take on the card in the connected reader on close. */
typedef enum
{
    /** Do nothing on close. */
    PBSmartcardDispositionLeaveCard,
    /** Reset on close. */
    PBSmartcardDispositionResetCard,
    /** Power down on close. */
    PBSmartcardDispositionUnpowerCard
} PBSmartcardDisposition; 

/** Reset types */
typedef enum
{
    /** Cold reset. */
    PBSmartcardResetCold, 
    /** Warm reset. */
    PBSmartcardResetWarm  
} PBSmartcardReset;

/** Class containing the main Smartcard operations.
 *
 * PBSmartCard generates the following notifications:
 *     PB_CARD_INSERTED
 *     PB_CARD_REMOVED
 * The application can register for these notifications by adding itself as an observer on the
 * NSNotificationCenter object (note that sender object must be set to nil):
 *     [[NSNotificationCenter defaultCenter] addObserver:myObject selector:@selector(mySelector:) name:@"PB_CARD_INSERTED" object:nil];
 *
 * The initial state of the slot can be checked with "slotStatus" which is updated when PBSmartcard is initialized.
 */
@interface PBSmartcard : NSObject {   

}

/**
 Initializes the library and enables notifications and \ref PBSmartcard property values.
 @returns PBSmardcardStatusSuccess if successful, otherwise an error code.
 */
- (PBSmartcardStatus)open;

/**
 Does the same initializations as \ref open but also disables the automatic background management in the library. This method should only be used when an application expliciteley need to manage smart card operations in the background. See the document "Precise iOS Toolkit Smart Card Reader User Manual" for more details on the automatic background management in the library. 
 This method requires at least iOS 5.x. Calling the method on iOS version < 5.x will return PBSmartcardStatusNotSupported.
 @returns PBSmardcardStatusSuccess if successful, otherwise an error code.
 */
- (PBSmartcardStatus)openWithDisabledBackgroundManagement;


/**
 Closes the library and disables all notifications. Property values are no longer reliable. 
 @returns PBSmardcardStatusSuccess if successful, otherwise an error code.
 */
- (PBSmartcardStatus)close;

/**
 Connects to a card in the reader using a specified protocol. The card will be open exclusively for this thread until released with a call to \ref disconnect:.
 @param[in] preferredProtocol The preferred protocol for further communication. 
 @returns PBSmardcardStatusSuccess if successful, or an error code. 
 */
- (PBSmartcardStatus)connect: (PBSmartcardProtocol)preferredProtocol;

/**
 Disconnect from a previous call to \ref connect: allowing other applications to access the card. Allows the caller to set the card in a preferred disposition for the next caller. 
 @param[in] disposition The disposition of the card in the reader. 
 @returns PBSmardcardStatusSuccess if successful, or an error code. 
 */
- (PBSmartcardStatus)disconnect: (PBSmartcardDisposition)disposition;

/**
 Resets and reconnects to the card in the reader. This can be used to select a different interface on the card (if supported).
 @param[in] preferredProtocol The preferred protocol to use for further communication. 
 @param[in] resetType The type of reset of the card to be performed. 
 @returns PBSmardcardStatusSuccess if successful, or an error code. 
 */
- (PBSmartcardStatus)reconnect: (PBSmartcardProtocol)preferredProtocol
                              : (PBSmartcardReset)resetType;

/**
 Transmits an APDU to the card and retrieves the result of the command from the card.
 @param[in] command The command APDU to send to the card
 @param[in] commandLength The size of the command in bytes.
 @param[out] response Pointer to the response APDU from the card. This memory must be allocated by the calling application. 
 @param[in,out] responseLength Supplies the length in bytes of the response parameter and received the actual number of bytes received from the smart card. 
 @returns PBSmardcardStatusSuccess if successful, or an error code. 
 */
- (PBSmartcardStatus)transmit: (unsigned char*)command
            withCommandLength: (unsigned short)commandLength
            andResponseBuffer: (unsigned char*)response
            andResponseLength: (unsigned short*)responseLength;

/**
 * Returns the current slot status of the card reader. 
 */
- (PBSmartcardSlotStatus)getSlotStatus;
/** DEPRECATED, use getSlotStatus. */
- (PBSmartcardSlotStatus)getSlot;

/**
 * Returns the protocol used by the currently connected card, if any. 
 */
- (PBSmartcardProtocol)getCurrentProtocol;
/** DEPRECATED, use getCurrentProtocol. */
- (PBSmartcardProtocol)getProt;

/** Returns the card ATR stored as an array of NSNumber. */
- (NSArray*)getATR; 

/** Converts a smartcard status code to a readable string. */
+ (NSString*)stringFromStatus: (PBSmartcardStatus) status;


/**
 * "Protected method", should only be used if subclassing PBSmartcard. The subclass 
 * may override this method and act accordingly, as long as [super smartcardInserted]
 * is called.
 * This method will be called when a smartcard is inserted in the reader. 
 */
- (void)smartcardInserted: (NSNotification*)notification;
/**
 * "Protected method", should only be used if subclassing PBSmartcard. The subclass 
 * may override this method and act accordingly, as long as [super smartcardRemoved]
 * is called.
 * This method will be called when a smartcard is removed from the reader. 
 */
- (void)smartcardRemoved: (NSNotification*)notification;
/**
 * "Protected method", should only be used if subclassing PBSmartcard. The subclass 
 * may override this method and act accordingly, as long as [super accessoryConnected]
 * is called.
 * This method will be called when the accessory is connected to the device. 
 */
- (void)accessoryConnected: (NSNotification*)notification;
/**
 * "Protected method", should only be used if subclassing PBSmartcard. The subclass 
 * may override this method and act accordingly, as long as [super accessoryDisconnected]
 * is called.
 * This method will be called when the accessory is disconnected from the device. 
 */
- (void)accessoryDisconnected: (NSNotification*)notification;

@end
