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
#import "PBFingerPickerController.h"

@implementation PBFingerPickerController

@synthesize delegate;
@synthesize pickableFingers;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        self->delegate = nil;
        self->pickableFingers = nil;
    }
    return self;
}

- (void)dealloc
{
    [leftLittleButton release];
    [leftRingButton release];
    [leftMiddleButton release];
    [leftIndexButton release];
    [leftThumbButton release];
    [rightLittleButton release];
    [rightRingButton release];
    [rightMiddleButton release];
    [rightIndexButton release];
    [rightThumbButton release];
    [rightHandImageView release];
    [gotoLeftHandButton release];
    [gotoRightHandButton release];
    [scrollView release];
    [delegate release];
    [pickableFingers release];
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
    self.title = @"Choose finger";
    
    scrollView.pagingEnabled = YES;
    scrollView.clipsToBounds = YES;
    
    CGFloat contentWidth;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        // Make wider.
        CGRect frame = scrollView.frame;
        frame.size.width = 660;
        scrollView.frame = frame;
        
        // Remove small hands.
        [gotoLeftHandButton setHidden:YES];
        [gotoRightHandButton setHidden:YES];
        
        contentWidth = scrollView.frame.size.width;
    }
    else
    {
        contentWidth = 2 * 320;
    }
    
    scrollView.delegate = self;
    
    // Set content size.
    [scrollView setContentSize:CGSizeMake(contentWidth, 1)];

    // Move right hand images to right.
    CGPoint center;
    
    center = rightHandImageView.center;
    center.x += (contentWidth / 2);
    rightHandImageView.center = center;
    center = gotoLeftHandButton.center;
    center.x += (contentWidth / 2);
    gotoLeftHandButton.center = center;
    center = rightLittleButton.center;
    center.x += (contentWidth / 2);
    rightLittleButton.center = center;
    center = rightRingButton.center;
    center.x += (contentWidth / 2);
    rightRingButton.center = center;
    center = rightMiddleButton.center;
    center.x += (contentWidth / 2);
    rightMiddleButton.center = center;
    center = rightIndexButton.center;
    center.x += (contentWidth / 2);
    rightIndexButton.center = center;
    center = rightThumbButton.center;
    center.x += (contentWidth / 2);
    rightThumbButton.center = center;
    
    isAnimatingScroll = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)scrollLeftAnimated: (BOOL)animated
{
    if (! isAnimatingScroll)
    {
        [scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:animated];
        isAnimatingScroll = animated;
    }
}

- (void)scrollRightAnimated: (BOOL)animated
{
    if (! isAnimatingScroll)
    {
        [scrollView scrollRectToVisible:CGRectMake(2*320-1, 0, 1, 1) animated:animated];
        isAnimatingScroll = animated;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Setting pickable fingers.
    BOOL defaultValue = (pickableFingers == nil);
    
    // Default is YES if pickableFingers is nil, otherwise NO.
    leftLittleButton.enabled = defaultValue;
    leftRingButton.enabled = defaultValue;
    leftMiddleButton.enabled = defaultValue;
    leftIndexButton.enabled = defaultValue;
    leftThumbButton.enabled = defaultValue;
    rightLittleButton.enabled = defaultValue;
    rightRingButton.enabled = defaultValue;
    rightMiddleButton.enabled = defaultValue;
    rightIndexButton.enabled = defaultValue;
    rightThumbButton.enabled = defaultValue;
    
    // Set to YES for all fingers set as pickable.
    for (PBBiometryFinger* finger in pickableFingers)
    {
        switch (finger.position)
        {
            case PBFingerPositionLeftLittle:
                leftLittleButton.enabled = YES;
                break;
            case PBFingerPositionLeftRing:
                leftRingButton.enabled = YES;
                break;
            case PBFingerPositionLeftMiddle:
                leftMiddleButton.enabled = YES;
                break;
            case PBFingerPositionLeftIndex:
                leftIndexButton.enabled = YES;
                break;
            case PBFingerPositionLeftThumb:
                leftThumbButton.enabled = YES;
                break;
            case PBFingerPositionRightLittle:
                rightLittleButton.enabled = YES;
                break;
            case PBFingerPositionRightRing:
                rightRingButton.enabled = YES;
                break;
            case PBFingerPositionRightMiddle:
                rightMiddleButton.enabled = YES;
                break;
            case PBFingerPositionRightIndex:
                rightIndexButton.enabled = YES;
                break;
            case PBFingerPositionRightThumb:
                rightThumbButton.enabled = YES;
                break;
            default:
                break;
        }
    }
    
    // Make sure that the user sees the same hand as the last time.
    if (! [[NSUserDefaults standardUserDefaults] boolForKey:@"PBFingerPickerController.startAtLeftHand"])
    {
        [self scrollRightAnimated:NO];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    float x = scrollView.contentOffset.x;
    // Save the current hand for the next time the user gets here.
    [[NSUserDefaults standardUserDefaults] setBool:x < (320/2) forKey:@"PBFingerPickerController.startAtLeftHand"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)fingerChosen:(id)sender
{
    if ([delegate respondsToSelector:@selector(fingerPickerUserChooseFinger:)])
    {
        if ([sender isEqual:leftLittleButton])
        {
            [delegate fingerPickerUserChooseFinger:PBFingerPositionLeftLittle];
        }
        else if ([sender isEqual:leftRingButton])
        {
            [delegate fingerPickerUserChooseFinger:PBFingerPositionLeftRing];            
        }
        else if ([sender isEqual:leftMiddleButton])
        {
            [delegate fingerPickerUserChooseFinger:PBFingerPositionLeftMiddle];            
        }
        else if ([sender isEqual:leftIndexButton])
        {
            [delegate fingerPickerUserChooseFinger:PBFingerPositionLeftIndex];            
        }
        else if ([sender isEqual:leftThumbButton])
        {
            [delegate fingerPickerUserChooseFinger:PBFingerPositionLeftThumb];            
        }
        else if ([sender isEqual:rightLittleButton])
        {
            [delegate fingerPickerUserChooseFinger:PBFingerPositionRightLittle];
        }
        else if ([sender isEqual:rightRingButton])
        {
            [delegate fingerPickerUserChooseFinger:PBFingerPositionRightRing];            
        }
        else if ([sender isEqual:rightMiddleButton])
        {
            [delegate fingerPickerUserChooseFinger:PBFingerPositionRightMiddle];            
        }
        else if ([sender isEqual:rightIndexButton])
        {
            [delegate fingerPickerUserChooseFinger:PBFingerPositionRightIndex];            
        }
        else if ([sender isEqual:rightThumbButton])
        {
            [delegate fingerPickerUserChooseFinger:PBFingerPositionRightThumb];            
        }
    }
}

- (IBAction)scrollLeft
{
    [self scrollLeftAnimated:YES];
}

- (IBAction)scrollRight
{
    [self scrollRightAnimated:YES];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    isAnimatingScroll = NO;
}
@end