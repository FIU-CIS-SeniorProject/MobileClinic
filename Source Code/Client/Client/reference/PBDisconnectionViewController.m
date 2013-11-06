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

#import "PBDisconnectionViewController.h"


@implementation PBDisconnectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [shellImageView release];
    [phoneImageView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    insideAnimation = NO;
    continueAnimation = NO;
}

- (void)animatePhone
{
    /* Let the finger swipe for 1 second before fading it out and then letting it fade in
     * in the original position. */
    insideAnimation = YES;
    [UIView animateWithDuration:1 delay:1 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        phoneImageView.transform = CGAffineTransformMakeTranslation(0, 32);
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            phoneImageView.alpha = 0;
        } completion:^(BOOL finished){
            phoneImageView.transform = CGAffineTransformMakeTranslation(0, 0);
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                phoneImageView.alpha = 1;
            } completion:^(BOOL finished){
                if (continueAnimation) {
                    [self animatePhone];
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
    
    /* Start animation of iphone. */
    if (! continueAnimation && ! insideAnimation) {
        [self animatePhone];
    }
    continueAnimation = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    /* Stop animation of iphone. */
    continueAnimation = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
