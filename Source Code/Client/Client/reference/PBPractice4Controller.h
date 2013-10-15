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
#import "PBPracticeController.h"
#import "PBBiometry.h"
#import "PBBiometryGUI.h"
#import "PBFingerImageView.h"
#import "PBBarImageView.h"
#import "PBAccessory.h"
#import "PBDisconnectionViewController.h"

// Lets the user practice swiping the sensor.
@interface PBPractice4Controller : UIViewController <PBBiometryGUI, UIAlertViewDelegate>
{
    IBOutlet PBFingerImageView* largeImage;
    IBOutlet PBBarImageView* barImage0;
    IBOutlet PBBarImageView* barImage1;
    IBOutlet PBBarImageView* barImage2;
    IBOutlet PBBarImageView* barImage3;
    IBOutlet PBBarImageView* barImage4;
    IBOutlet PBBarImageView* barImage5;
    IBOutlet PBBarImageView* barImage6;
    IBOutlet PBBarImageView* barImage7;
    IBOutlet PBBarImageView* barImage8;
    IBOutlet PBBarImageView* barImage9;
    IBOutlet PBBarImageView* barImageA0;
    IBOutlet PBBarImageView* barImageA1;
    IBOutlet PBBarImageView* barImageA2;
    IBOutlet PBBarImageView* barImageA3;
    IBOutlet PBBarImageView* barImageA4;
    IBOutlet PBBarImageView* barImageA5;
    IBOutlet PBBarImageView* barImageA6;
    IBOutlet PBBarImageView* barImageA7;
    IBOutlet PBBarImageView* barImageA8;
    IBOutlet PBBarImageView* barImageA9;
    
    PBDisconnectionViewController* disconnectionView;
    
    NSArray* barImages;
    NSArray* barImagesA;
    
    IBOutlet UILabel* resultLabel;    
    
    PBPracticeController* practiceController;
    
    BOOL startNewCapture;
    BOOL isVisible;
}
- (id)initWithPracticeController: (PBPracticeController*)aPracticeController;
- (IBAction)next: (id)sender;
@end