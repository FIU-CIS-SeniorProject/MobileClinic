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
 * $Date: 2012-04-20 11:36:52 +0200 (fr, 20 apr 2012) $ $Rev: 14637 $ 
 *
 */


#import <Foundation/Foundation.h>
#import "PBBiometryDatabase.h"
#import "PBBiometryGUI.h"
#import "PBBiometryVerifier.h"
#import "PBBiometryEnrollConfig.h"
#import "PBBiometryVerifyConfig.h"

/* Status (return) codes. */
typedef enum {
    /** The function returned without errors. */
    PBBiometryStatusOK,
    
    /** At least one of the parameters is invalid. */
    PBBiometryStatusInvalidParameter,
    
    /** The data passed to the function has the wrong format. */
    PBBiometryStatusWrongDataFormat,
    
    /** At least one buffer has an incorrect size. */
    PBBiometryStatusWrongBufferSize,
    
    /** A function is called before the interface being initialized. */
    PBBiometryStatusNotInitialized,
    
    /** The requested item was not found. */
    PBBiometryStatusNotFound,
    
    /** The function returned because the caller canceled it. */
    PBBiometryStatusCancelled,
    
    /** The operation timed-out before it could finish the operation. */
    PBBiometryStatusTimedOut,
    
    /** Cannot allocate enough memory. */
    PBBiometryStatusMemoryAllocationFailed,
    
    /** Unable to open, read from or write to a file. */
    PBBiometryStatusFileError,
    
    /** Reader is not connected or not started. */
    PBBiometryStatusReaderNotAvailable,
    
    /** Reader has been locked by another user. */
    PBBiometryStatusReaderBusy,
    
    /** The enrollment failed because none of the images matched each
      * other. This only applies if multiple images are required for
      * enrollment. */    
    PBBiometryStatusEnrollmentVerificationFailed,
    
    /** The finger has been blocked for further verifications. The finger 
      * will be unblocked after a while. A block of the finger is due to 
      * that multiple subsequent rejects has been recorded for that finger. */
	PBBiometryStatusFingerBlocked,
    
    /** The protocol string "com.precisebiometrics.sensor" has not been 
      * included for the "UISupportedExternalAccessoryProtocols" key in
      * the Info.plist. */
    PBBiometryStatusProtocolNotIncluded,
    
    /** An undefined fatal error has occurred. This error code is used
      * for errors that "cannot happen" and isn't covered by any other
      * error code. */
    PBBiometryStatusFatal
} PBBiometryStatus;

/** Class containing the main biometric operations, enrollFinger and 
  * verifyFinger. */
@interface PBBiometry : NSObject {
    BOOL isEnrolling;
    BOOL isVerifying;
    BOOL isCapturing;
}

/* Class method for receiving the singleton object. */
+ (PBBiometry*) sharedBiometry;

/** Captures x images from a fingerprint sensor. A template is then
  * extracted from the "best" image out of the x images and that 
  * template is enrolled in the database. 
  *
  * @param[in] finger is the finger to be enrolled.
  * @param[in] database is the database module in which the enrolled template
  *     will be saved. 	 
  * @param[in] gui is the GUI module that will display the enrollment progress.         	
  * @param[in] nbrOfImages is the number of images to be captured and used for 
  *     selecting the "best" image. It is recommended to use 3-5 images.
  * @param[in] config is the config parameters for the enrollment. 
  *
  * @return PBBiometryStatusOK if successful, or an error code. 
  */
-(PBBiometryStatus) enrollFinger: (PBBiometryFinger*) finger
                        database: (id <PBBiometryDatabase>) database 
                             gui: (id <PBBiometryGUI>) gui
                     nbrOfImages: (uint8_t) nbrOfImages 
                          config: (PBBiometryEnrollConfig*) config;

/** Extracts a template from an image captured from a fingerprint 
  * sensor and verifies it against templates stored in the database. 
  * The internal verifier will be used.
  *
  * @param[in] fingers is an array of fingers to verify against. Will be
  *     input to the database to deliver the correct templates.
  * @param[in] database is the database module in which the enrolled templates
  *     has been saved.
  * @param[in] gui is the GUI module that will display the verification 
  *     progress.
  * @param[in] config is the config parameters for the verification. 
  * @param[out] matchingFinger is the matching finger of the verification, or
  *     nil if no finger matched.
  *
  * @return PBBiometryStatusOK if successful, or an error code. 
  */
-(PBBiometryStatus) verifyFingers: (NSArray*) fingers
                         database: (id <PBBiometryDatabase>) database
                              gui: (id <PBBiometryGUI>) gui
                           config: (PBBiometryVerifyConfig*) config
                   matchingFinger: (PBBiometryFinger**) matchingFinger;

/** Extracts a template from an image captured from a fingerprint 
  * sensor and verifies it against templates stored in the database. 
  * The method allows for external verifiers to be used, e.g. to be
  * able to do a match-on-card.
  *
  * @param[in] fingers is an array of fingers to verify against. Will be
  *     input to the database to deliver the correct templates.
  * @param[in] database is the database module in which the enrolled templates
  *     has been saved.
  * @param[in] gui is the GUI module that will display the verification 
  *     progress.
  * @param[in] verifier is the verifier module that will do the actual 
  *     comparison of the templates. This allows for external verifiers e.g. 
  *     for match-on-card verifiers. All external verifiers that support any of
  *     the possible template types may be used. Also make sure that the correct
  *     template type is specified, both for enrollment and for verification. 
  *     Passing nil as verifier is the same as calling 
  *     verifyFingers:database:gui:config:matchingFinger: in which case the 
  *     internal verifier will be used.
  * @param[in] config is the config parameters for the verification. 
  * @param[out] matchingFinger is the matching finger of the verification, or
  *     nil if no finger matched.
  *
  * @return PBBiometryStatusOK if successful, or an error code. 
  */
-(PBBiometryStatus) verifyFingers: (NSArray*) fingers
                         database: (id <PBBiometryDatabase>) database
                              gui: (id <PBBiometryGUI>) gui
                         verifier: (id <PBBiometryVerifier>) verifier
                           config: (PBBiometryVerifyConfig*) config
                   matchingFinger: (PBBiometryFinger**) matchingFinger;

/** Captures images from a fingerprint sensor. 
 *
 * @param[in] gui is the GUI module that will display the image capturing 
 *     progress.
 *
 * @return PBBiometryStatusOK if successful, or an error code. 
 */
-(PBBiometryStatus) captureImagesWithGUI: (id <PBBiometryGUI>) gui;

/** Captures images from a fingerprint sensor. Use this method instead of
 *  captureImagesWithGUI: when there is requirements on quality and area
 *  for the captured images.
 *  Note: Implement the displayChosenImage: for the GUI to display the
 *  images with enough quality and area. displayImage: will still be 
 *  called for all images, including images that do not pass the quality
 *  and area restrictions.
 *
 * @param[in] gui is the GUI module that will display the image capturing 
 *     progress.
 * @param[in] minimumQuality is the minimum quality required for a fingerprint 
 *     image to be captured. The quality value ranges from 0 (worst quality) 
 *     to 100 (best quality). 
 * @param[in] minimumArea is the minimum fingerprint area, in mm^2 required for 
 *     a fingerprint image to be captured.
 *
 * @return PBBiometryStatusOK if successful, or an error code. 
 */
-(PBBiometryStatus) captureImagesWithGUI: (id <PBBiometryGUI>) gui
                          minimumQuality: (uint8_t) minimumQuality
                             minimumArea: (uint32_t) minimumArea;

/** Cancels the enrollment, verification or image capturing process. 
 *
 * @return PBBiometryStatusOK if successful, or an error code. 
 */
-(PBBiometryStatus) cancel;

/** Converts a biometry status code to a readable string. */
+(NSString*) stringFromStatus: (PBBiometryStatus) status;

@end
