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
#import "PBPractice2Controller.h"
@implementation PBPractice2Controller

- (id)initWithPracticeController: (PBPracticeController*)aPracticeController
{
    self = [super init];
    if (self)
    {
        self->practiceController = aPracticeController;
        [aPracticeController retain];
    }
    return self;
}

- (void)dealloc
{
    [handImage release];
    [nextButton release];
    [practiceController release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    insideAnimation = NO;
    continueAnimation = NO;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [nextButton setHidden:YES];
    }
}

- (void)animateHand
{
    /* Let the finger swipe for 1 second before fading it out and then letting it fade in
     * in the original position. */
    insideAnimation = YES;
    [UIView animateWithDuration:1 delay:1 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        handImage.transform = CGAffineTransformMakeTranslation(0, 40);
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            handImage.alpha = 0;
        } completion:^(BOOL finished){
            handImage.transform = CGAffineTransformMakeTranslation(0, 0);
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                handImage.alpha = 1;
            } completion:^(BOOL finished){
                if (continueAnimation) {
                    [self animateHand];
                }
                else {
                    insideAnimation = NO;
                }
            }];
        }];
    }];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Start animation of hand.
    if (! continueAnimation && ! insideAnimation)
    {
        [self animateHand];
    }
    continueAnimation = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    /* Stop animation of hand. */
    continueAnimation = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)next: (id)sender
{
    [practiceController scrollRight:sender];
}
@end