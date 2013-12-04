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
 * $Date: 2012-04-20 13:38:30 +0200 (fr, 20 apr 2012) $ $Rev: 14651 $  
 *
 */

#import <UIKit/UIKit.h>

#import "PBBiometryFinger.h"
#import "PBBiometryGUI.h"
#import "PBBiometry.h"
#import "PBBiometryDatabase.h"
#import "PBFingerImageView.h"

@protocol PBEnrollmentDelegate <NSObject>

@required

/** Tells that the enrollment is completed and that a template has been 
  * enrolled for the specified finger. If finger is nil then the enrollment 
  * failed or was cancelled and no template was enrolled for the finger. */
- (void)enrollmentTemplateEnrolledForFinger: (PBBiometryFinger*) finger;

@end

/** Controller responsible for the enrollment process. The user is prompted 
  * swipe his/her finger three times and the best fingerprint out of those 
  * three collected is chosen to be enrolled. The user may choose to cancel 
  * the enrollment process at any time. 
  * 
  * It is recommended that the enrollment controller is presented as a modal 
  * view controller using the presentModalViewController method. Note that 
  * first placing the enrollment controller in a navigation controller and 
  * then presenting the navigation controller as a modal view controller will
  * set a navigationbar and toolbar for the enrollment controller.
  *
  * Example:
  *  PBEnrollmentController* enrollmentController = [[PBEnrollmentController alloc]
  *           initWithDatabase:database ...];
  *  UINavigationController* navController = [[UINavigationController alloc]
  *           initWithRootViewController:enrollmentController];
  *  
  *  [self presentModalViewController:navController animated:YES];
  */
@interface PBEnrollmentController : UIViewController <PBBiometryGUI, UIAlertViewDelegate> {
    /* The inside view used for centering the content when e.g. viewed on iPad. */
    IBOutlet UIView* insideView;
    
    /* The main image. */
    IBOutlet PBFingerImageView* mainImage;
    
    /* The smaller images. */
    IBOutlet PBFingerImageView* smallImage1;
    IBOutlet PBFingerImageView* smallImage2;
    IBOutlet PBFingerImageView* smallImage3;
    /* The array of the small images. */
    NSArray* smallImages;
    /* The current small image. */
    NSInteger currentChosenImage;

    /* Error labels. */
    IBOutlet UILabel* errorLabel1;
    IBOutlet UILabel* errorLabel2;
    IBOutlet UILabel* errorLabel3;
    IBOutlet UILabel* errorLabel4;
    
    /* The number labels. */
    IBOutlet UILabel* numberLabel1;
    IBOutlet UILabel* numberLabel2;
    IBOutlet UILabel* numberLabel3;
    /* The array of the number labels. */
    NSArray* numberLabels;
    
    /* The information text label. */
    IBOutlet UILabel* infoLabel;
    NSInteger nbrOfDots;
    BOOL enrolling;
    
    IBOutlet UIActivityIndicatorView* activityIndicator;
    
    IBOutlet UIImageView* decisionImage;
    IBOutlet UILabel* decisionLabel;
    IBOutlet UILabel* fadeLabel;

    PBBiometryFinger* finger;
    id <PBEnrollmentDelegate> delegate;
    
    id<PBBiometryDatabase> database;

    /** The config parameters for the enrollment. If nil, the default config
      * parameters will be used. */ 
    PBBiometryEnrollConfig* config;
}

@property (nonatomic, retain) PBBiometryEnrollConfig* config;

-(id) initWithDatabase: (id<PBBiometryDatabase>) aDatabase 
             andFinger: (PBBiometryFinger*) aFinger
           andDelegate: (id <PBEnrollmentDelegate>) aDelegate;

@end
