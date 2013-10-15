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
#import "PBBiometryFinger.h"

@protocol PBFingerPickerDelegate <NSObject>

// Called when the user chooses a finger.
- (void)fingerPickerUserChooseFinger: (PBFingerPosition)fingerPosition;

// Called when the user chooses to cancel the fingerpicker.
//- (void)fingerPickerUserCancelled;
@end

@interface PBFingerPickerController : UIViewController <UIScrollViewDelegate>
{
    IBOutlet UIButton* leftLittleButton;
    IBOutlet UIButton* leftRingButton;
    IBOutlet UIButton* leftMiddleButton;
    IBOutlet UIButton* leftIndexButton;
    IBOutlet UIButton* leftThumbButton;
    IBOutlet UIButton* rightLittleButton;
    IBOutlet UIButton* rightRingButton;
    IBOutlet UIButton* rightMiddleButton;
    IBOutlet UIButton* rightIndexButton;
    IBOutlet UIButton* rightThumbButton;
    IBOutlet UIButton* gotoLeftHandButton;
    IBOutlet UIButton* gotoRightHandButton;
    IBOutlet UIImageView* rightHandImageView;
    IBOutlet UIScrollView* scrollView;
    
    // The delegate of the fingerpicker controller. Will be called when the
    // user has chosen a finger.
    id<PBFingerPickerDelegate> delegate;
    // The fingers to choose from. If not set, then all 10 fingers may be
    // chosen from.
    NSArray* pickableFingers;
    
    BOOL isAnimatingScroll;
}

@property (nonatomic, retain) id<PBFingerPickerDelegate> delegate;
@property (nonatomic, retain) NSArray* pickableFingers;

- (IBAction)fingerChosen:(id)sender;
- (IBAction)scrollLeft;
- (IBAction)scrollRight;
@end