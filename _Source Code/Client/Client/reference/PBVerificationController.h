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

#import "PBBiometryGUI.h"
#import "PBBiometry.h"
#import "PBBiometryDatabase.h"
#import "PBBiometryVerifier.h"

@protocol PBVerificationDelegate <NSObject>

@required

/** Tells that the verification process has been completed and which
  * finger that matched. If finger is nil, then the verification failed
  * or was cancelled. */
- (void)verificationVerifiedFinger: (PBBiometryFinger*) finger;

@end

/** Controller responsible for the verification process. The user is prompted 
  * to swipe any finger (of the registered ones) in order to verify him/herself.
  * When the verification is completed the delegate of the controller will be 
  * notified through the verificationVerifiedFinger: method. 
  * The user may choose to cancel the verification process at any time. 
  *
  * It is recommended that the verification controller is presented as a modal 
  * view controller using the presentModalViewController method. Note that 
  * first placing the verification controller in a navigation controller and 
  * then presenting the navigation controller as a modal view controller will
  * set a navigationbar and toolbar for the verification controller.
  *
  * Example:
  *  PBVerificationController* verificationController = [[PBVerificationController alloc]
  *           initWithDatabase:database ...];
  *  UINavigationController* navController = [[UINavigationController alloc]
  *           initWithRootViewController:verificationController];
  *  
  *  [self presentModalViewController:navController animated:YES]; 
  */
@interface PBVerificationController : UIViewController <PBBiometryGUI, UIAlertViewDelegate> {
    /* The inside view used for centering the content when e.g. viewed on iPad. */
    IBOutlet UIView* insideView;
    
    IBOutlet UILabel* errorLabel1;
    IBOutlet UILabel* errorLabel2;
    IBOutlet UILabel* errorLabel3;
    IBOutlet UILabel* errorLabel4;
    IBOutlet UILabel* titleLabel;
    IBOutlet UILabel* processingLabel;
    IBOutlet UIImageView* currentFingerImage;
    IBOutlet UIActivityIndicatorView* activityIndicator;
    IBOutlet UIImageView* decisionImage;
    IBOutlet UILabel* decisionLabel;
    IBOutlet UILabel* fadeLabel;
    
    /** The buttons for switching to another finger, if verifyAgainstAllFingers is set to NO. */
    IBOutlet UIButton* previousFingerButton;
    IBOutlet UIButton* nextFingerButton;
    
    id<PBBiometryDatabase> database;
    NSArray* fingers;
    PBBiometryFinger* firstFinger;
    id <PBVerificationDelegate> delegate;
    NSString* title;

    NSUInteger indexOfFingerToVerifyAgainst;
    
    BOOL restartVerification;
    
    BOOL continueAnimation;
    BOOL insideAnimation;
    
    /** Verifier, in case the default verifier shall not be used, e.g. for
      * match on card. */
    id<PBBiometryVerifier> verifier;
    
    /** The config parameters for the verification. If nil, the default config
      * parameters will be used. */ 
    PBBiometryVerifyConfig* config;
    
    /** Tells if the verification is done against all of the enrolled fingers or if the 
      * user has to choose finger to verify against. E.g. for match on card it is better 
      * to only verify against one finger, since otherwise it is likely that fingers are
      * accidently locked by the card itself. Default YES. */
    BOOL verifyAgainstAllFingers;
}

@property (nonatomic, retain) id<PBBiometryVerifier> verifier;
@property (nonatomic, retain) PBBiometryVerifyConfig* config;
@property (nonatomic) BOOL verifyAgainstAllFingers;

/** Initializes the verification controller. 
  * 
  * @param[in] aDatabase is the database where the enrolled templates are stored.
  * @param[in] theFingers is the fingers to verify against. 
  * @param[in] aDelegate is the delegate to be called when the verification process is completed
  *     using the verificationVerifiedFinger method.
  * @param[in] aTitle is the title on the verification view giving the user an understanding of
  *     what content that is being verified. 
  */
-(id) initWithDatabase: (id<PBBiometryDatabase>) aDatabase
            andFingers: (NSArray*) theFingers
           andDelegate: (id <PBVerificationDelegate>) aDelegate
              andTitle: (NSString*) aTitle;

-(IBAction)choosePreviousFinger:(id)sender;
-(IBAction)chooseNextFinger:(id)sender;

@end
