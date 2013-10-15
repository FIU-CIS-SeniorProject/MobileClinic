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
 * $Date: 2012-04-20 13:38:30 +0200 (fr, 20 apr 2012) $ $Rev: 14651 $
 */

#import <UIKit/UIKit.h>
#import "PBEnrollmentController.h"
#import "PBVerificationController.h"
#import "PBBiometry.h"
#import "PBBiometryDatabase.h"
#import "PBBiometryUser.h"

/** Controller responsible for displaying information about which fingers that
  * are currently enrolled/registerd and to provide funtionality for enrolling
  * new fingers and deleting previously enrolled fingers. If any fingers are 
  * already enrolled the user will be prompted to verify her/himself before being
  * allowed to enroll or delete any fingers. 
  * 
  * The manage fingers controller can be placed in a UINavigationController. It will 
  * set a default title that will be shown on the navigation bar.
  *
  * Example:
  * 
  *  PBManageFingersController* manageFingersController = [[PBManageFingersController alloc] 
  *         initWithDatabase:database];
  *  UINavigationController* navController = [[UINavigationController alloc] init];
  *  
  *  [navController pushViewController:manageFingersController animated:NO];
  *  
  * The manage fingers controller can also be placed in a tab bar controller. It will 
  * create a default tab bar item that will be shown on the tab bar. It is 
  * recommended to place the manage fingers controller in a navigation controller and 
  * then place the navigation controller in the tab bar controller to also get 
  * the correct navigation bar for the manage fingers controller.
  *
  * Example:
  * 
  *  PBManageFingersController* manageFingersController = [[PBManageFingersController alloc] 
  *         initWithDatabase:database];
  *  UINavigationController* navController = [[UINavigationController alloc] init];
  *  UITabBarController* tabBarController = [[UITabBarController alloc] init];
  *  
  *  [navController pushViewController:manageFingersController animated:NO];
  *  [tabBarController setViewControllers:[NSArray arrayWithObjects:navController, nil]];
  */
@interface PBManageFingersController : UIViewController <PBEnrollmentDelegate, PBVerificationDelegate, UIActionSheetDelegate, UIScrollViewDelegate>
{
    IBOutlet UIImageView* leftHandImage;
    IBOutlet UIImageView* rightHandImage;
    IBOutlet UIButton* leftLittle;
    IBOutlet UIButton* leftRing;
    IBOutlet UIButton* leftMiddle;
    IBOutlet UIButton* leftIndex;
    IBOutlet UIButton* leftThumb;
    IBOutlet UIButton* rightLittle;
    IBOutlet UIButton* rightRing;
    IBOutlet UIButton* rightMiddle;
    IBOutlet UIButton* rightIndex;
    IBOutlet UIButton* rightThumb;
    IBOutlet UIButton* scrollToLeftHandImage;
    IBOutlet UIButton* scrollToRightHandImage;
    IBOutlet UIScrollView* scrollView;
    IBOutlet UILabel* noFingersLabel;
    
    NSArray* fingerButtons;
    id<PBBiometryDatabase> database;
    PBBiometryUser* user;

    NSInteger pageCurrentlyShown;
    
    BOOL isAnimatingScroll;
    
    /** Verifier, in case the default verifier shall not be used, e.g. for
      * match on card. */
    id<PBBiometryVerifier> verifier;
    
    /** The config parameters for the verification. If nil, the default config
     * parameters will be used. */ 
    PBBiometryVerifyConfig* verifyConfig;
    /** The config parameters for the enrollment. If nil, the default config
     * parameters will be used. */ 
    PBBiometryEnrollConfig* enrollConfig;
    
    /** Tells if the verification is done against all of the enrolled fingers or if the 
      * user has to choose finger to verify against. E.g. for match on card it is better 
      * to only verify against one finger, since otherwise it is likely that fingers are
      * accidently locked by the card itself. */
    BOOL verifyAgainstAllFingers;

    /** The fingers that may be enrolled. If not set, then all 10 fingers may be 
     *  enrolled. */
    NSArray* enrollableFingers;
}

@property (nonatomic, retain) id<PBBiometryVerifier> verifier;
@property (nonatomic, retain) PBBiometryVerifyConfig* verifyConfig;
@property (nonatomic, retain) PBBiometryEnrollConfig* enrollConfig;
@property (nonatomic) BOOL verifyAgainstAllFingers;
@property (nonatomic, retain) NSArray* enrollableFingers;

/** Initiates the manage fingers controller with a database and a user. */
- (id) initWithDatabase: (id<PBBiometryDatabase>) aDatabase
                andUser: (PBBiometryUser*) aUser;

/** Refreshes the manage fingers controller. Updates the enrolled fingers and sets the 
  * state back to normal (in case in edit state). 
  * Call this method e.g. if the enrolled fingers are stored on a smartcard and the 
  * smartcard is inserted or removed from the card reader. */
- (void)refresh;
- (IBAction)enrollFinger: (id) sender;
- (IBAction)scrollLeft;
- (IBAction)scrollRight;
@end