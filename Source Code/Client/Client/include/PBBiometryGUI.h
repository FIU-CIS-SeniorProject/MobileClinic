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



#import <UIKit/UIKit.h>

#import "PBBiometryFinger.h"

/** Event types. */
typedef enum {
    /** Prompt the user to swipe his/her finger on the sensor. */
    PBEventPromptSwipeFinger,

    /** Alert the user that the swipe was too fast. */
	PBEventAlertSwipeTooFast,

    /** Alert the user that an image has been captured. */
	PBEventAlertImageCaptured,
	
    /** Alert the user that a template has been extracted. */
	PBEventAlertTemplateExtracted,
    /** Alert the user that the extracted template has been enrolled in the 
      * database. */
	PBEventAlertTemplateEnrolled,
	
    /** Alert the user that the finger presented for verification was rejected. */
    PBEventAlertFingerRejected,
    
    /** Alert the user that the quality of the image was too bad. */
    PBEventAlertQualityTooBad,

    /** Alert the user that the area of the fingerprint within the 
     * image was too small. */
    PBEventAlertAreaTooSmall    
} PBEvent;

/** Protocol for a biometric GUI. The GUI is used to display to the  
  * user what is happening when enrolling or verifying. */
@protocol PBBiometryGUI <NSObject> /* add <NSObject> otherwise the retain cannot be performed */


@optional


/** Tells the GUI to display to the user that an event has occurred, for 
  * possible events, see PBEvent. The GUI chooses what will happen for each 
  * event, it could e.g. display a text or image for the user indicating what 
  * happened, light a LED or simply just ignore the event.
  *
  * @param[in] event_ is the type of event, see PB_EVENT_X.
  * @param[in] finger is the finger in case of the events
  *     PBEventPromptSwipeFinger and PBEventAlertFingerRejected. For other 
  *     events the finger will be nil. 
  */
-(void) displayEvent: (PBEvent) event_ 
           forFinger: (PBBiometryFinger*) finger;

/** Tells the GUI to display a fingerprint image from the sensor. The GUI 
 * decides if it wants to show the image or just simply ignore it. This 
 * function will most likely be called together with a posting of the event 
 * PBEventAlertImageCaptured. 
 *
 * @param[in] image is the image from the sensor to be displayed.
 */
-(void) displayImage: (UIImage*) image;

/** Tells the GUI to display a fingerprint image from the sensor. The image has
 * been chosen for further processing, e.g. for enrollment or verification. The 
 * GUI decides if it wants to show the image or just simply ignore it. This 
 * function will likely be called together with a call to displayImage. 
 * Note that the image in the call to displayImage may be different from the
 * image in the call to displayChosenImage, but more likely they will be 
 * the same image.
 *
 * @param[in] image is the image from the sensor to be displayed.
 */
-(void) displayChosenImage: (UIImage*) image;

/** Tells the GUI to display quality information of the captured image. The GUI 
  * may choose to show parts or all of this quality information or simply ignore 
  * it. The GUI may choose to display this information as numbers or e.g. as 
  * bars indicating the values. 
  *
  * @param[in] imageQuality is the image quality of the captured image. The 
  *     quality values range from 0 (worst quality) to 100 (best quality).
  * @param[in] area is the fingerprint area in the captured image, in mm^2.
  * @param[in] imageQualityThreshold is the threshold that are used when 
  *     checking if the image quality is acceptable or not. 
  * @param[in] areaThreshold is the threshold that are used when checking if the 
  *     fingerprint area is acceptable (large enough) or not.
  */
-(void) displayQuality: (uint8_t) imageQuality
               andArea: (uint32_t) area
 imageQualityThreshold: (uint8_t) imageQualityThreshold
         areaThreshold: (uint32_t) areaThreshold;
	
@end
