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
 * $Date: 2012-06-28 15:20:10 +0200 (to, 28 jun 2012) $ $Rev: 15253 $
 */
#import "PBVerificationController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>

@implementation PBVerificationController

@synthesize verifier;
@synthesize config;
@synthesize verifyAgainstAllFingers;

-(id) initWithDatabase: (id<PBBiometryDatabase>) aDatabase
            andFingers: (NSArray*) theFingers
           andDelegate: (id <PBVerificationDelegate>) aDelegate
              andTitle: (NSString*) aTitle;
{
    self = [super initWithNibName:@"PBVerificationController" bundle:[NSBundle mainBundle]];
    
    self->database = [aDatabase retain];
    self->firstFinger = [[theFingers objectAtIndex:0] retain];
    self->fingers = [[theFingers sortedArrayUsingComparator:(NSComparator)^(id obj1, id obj2) {
        return ([obj1 visualPosition] > [obj2 visualPosition]);}] retain];
    self->delegate = [aDelegate retain];
    self->title = [aTitle retain];
    
    /* Set default verifier and template type. */
    self->verifier = nil;
    self->config = [[PBBiometryVerifyConfig alloc] init];
    
    /* Default, the user does not have to choose which finger to verify
     * against. Instead all fingers are verified against. */
    self->verifyAgainstAllFingers = YES;
    
    /* Set title in case we are added to a navigation controller. */
    self.title = @"Verify";
    
    return self;
}

- (void)dealloc
{
    [insideView release];
    [errorLabel1 release];
    [errorLabel2 release];
    [errorLabel3 release];
    [errorLabel4 release];
    [titleLabel release];
    [processingLabel release];
    [currentFingerImage release];
    [activityIndicator release];
    [decisionImage release];
    [decisionLabel release];
    [fadeLabel release];
    [previousFingerButton release];
    [nextFingerButton release];
    [database release];
    [fingers release];
    [firstFinger release];
    [delegate release];
    [title release];
    if (verifier != nil)
    {
        [verifier release];
    }
    [config release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)animateHand
{
    /* Let the finger swipe for 1 second before fading it out and then letting it fade in
     * in the original position. */
    insideAnimation = YES;
    [UIView animateWithDuration:1 delay:1 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        currentFingerImage.transform = CGAffineTransformMakeTranslation(0, 40);
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            currentFingerImage.alpha = 0.0;
        } completion:^(BOOL finished){
            if (continueAnimation) {
                currentFingerImage.transform = CGAffineTransformMakeTranslation(0, 0);
                [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                    currentFingerImage.alpha = 1.0;
                } completion:^(BOOL finished){
                    if (continueAnimation) {
                        [self animateHand];
                    }
                    else {
                        insideAnimation = NO;
                    }
                }];
            }
            else {
                insideAnimation = NO;
            }
        }];
    }];
}

#pragma mark - View lifecycle

- (void)cancelCapture
{
    /* Cancel the enrollment. */
    [[PBBiometry sharedBiometry] cancel];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)displayError: (NSString*)error
{
    errorLabel4.text = errorLabel3.text;
    errorLabel3.text = errorLabel2.text;
    errorLabel2.text = errorLabel1.text;
    errorLabel1.text = error;
}

#define PB_DISPLAY_DECISION_ACCEPT   0
#define PB_DISPLAY_DECISION_REJECT_BLOCKED   1
#define PB_DISPLAY_DECISION_REJECT_CANCELLED 2
#define PB_DISPLAY_DECISION_REJECT_TIMEDOUT  3
#define PB_DISPLAY_DECISION_REJECT_UNKNOWN   4

- (void)playSound: (NSString*)filename
{
    SystemSoundID soundID;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:@"wav"];
    
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    AudioServicesCreateSystemSoundID((CFURLRef)fileUrl, &soundID);
    AudioServicesPlaySystemSound(soundID);    
}

- (void)displayDecision: (NSNumber*) decision
{
    if ([decision intValue] == PB_DISPLAY_DECISION_ACCEPT) {
        decisionImage.image = [UIImage imageNamed:@"accept.png"];

        /* Play accept sound, if allowed. */
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"PBPlaySounds"]) {
            [self playSound:@"PBVerificationAccepted"];
        }
    }
    else {
        decisionImage.image = [UIImage imageNamed:@"reject.png"];
        if ([decision intValue] == PB_DISPLAY_DECISION_REJECT_BLOCKED)
        {
            decisionLabel.text = @"Blocked";
        }
        else if ([decision intValue] == PB_DISPLAY_DECISION_REJECT_CANCELLED)
        {
            decisionLabel.text = @"Cancelled";
        }
        else if ([decision intValue] == PB_DISPLAY_DECISION_REJECT_TIMEDOUT)
        {
            decisionLabel.text = @"Timed out";
        }
        else
        {
            decisionLabel.text = @"Unknown error";
        }

        [decisionLabel setHidden:NO];

        /* Play reject sound, if allowed. */
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"PBPlaySounds"])
        {
            [self playSound:@"PBVerificationRejected"];
        }
    }
    [decisionImage setHidden:NO];
    [fadeLabel setHidden:NO];    
}

#define PB_DISPLAY_REJECT_TIME  0.5

- (void)showAlertInMainThread: (UIAlertView*)alertView
{
    [alertView show];
}

-(void) doVerification
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

    PBBiometryStatus status;
    PBBiometryFinger* matchingFinger = nil;
    NSArray* verifyAgainstFingers = nil;
    
    if (verifyAgainstAllFingers)
    {
        verifyAgainstFingers = fingers;
    }
    else
    {
        /* Only verify against chosen finger. */
        verifyAgainstFingers = [NSArray arrayWithObject:[fingers objectAtIndex:indexOfFingerToVerifyAgainst]];
    }
        
    /* Start the verification process. */
    status = [[PBBiometry sharedBiometry] verifyFingers:verifyAgainstFingers database:database gui:self verifier:verifier config:config matchingFinger:&matchingFinger];
    
    /* Notify user the status of the operation. */
    if (status == PBBiometryStatusOK)
    {
        /* Display decision to user. */
        if (matchingFinger != nil)
        {
            /* Store last finger for future verifications. */
            [[NSUserDefaults standardUserDefaults] setInteger:matchingFinger.position forKey:@"PBVerificationController.lastFingerPosition"];
            /* Display accept to user. */
            [self performSelectorOnMainThread:@selector(displayDecision:) withObject:[NSNumber numberWithInt: PB_DISPLAY_DECISION_ACCEPT] waitUntilDone:NO];
        }
        
        [(NSObject*)delegate performSelectorOnMainThread:@selector(verificationVerifiedFinger:) withObject:matchingFinger waitUntilDone:NO];
    }
    else if (status == PBBiometryStatusReaderBusy)
    {
        /* Reader is already used by another application. */
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Tactivo busy" message:@"The Tactivo is already used by another application. Close that application or make sure that it is no longer using the Tactivo before trying again." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [self performSelectorOnMainThread:@selector(showAlertInMainThread:) withObject:alertView waitUntilDone:NO];
        [alertView release];
    }
    else if (status == PBBiometryStatusReaderNotAvailable)
    {
        /* Reader is not available. */
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Tactivo not accessible" message:@"The Tactivo is not connected to the device or is waiting to be authenticated. Please connect the Tactivo or wait for the authentication to be completed." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [self performSelectorOnMainThread:@selector(showAlertInMainThread:) withObject:alertView waitUntilDone:NO];
        [alertView release];
    }
    else if (status == PBBiometryStatusProtocolNotIncluded)
    {
        /* Reader is not available. */
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Protocol not included" message:@"The protocol string 'com.precisebiometrics.sensor' is not included in the 'UISupportedExternalAccessoryProtocols' key in the Info.plist." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [self performSelectorOnMainThread:@selector(showAlertInMainThread:) withObject:alertView waitUntilDone:NO];
        [alertView release];
    }
    else if (status == PBBiometryStatusFatal)
    {
        /* Unknown error. */
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Unknown error!" message:@"An unknown error has occurred. Try disconnecting the Tactivo from the device and then connect it again or restart the application." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [self performSelectorOnMainThread:@selector(showAlertInMainThread:) withObject:alertView waitUntilDone:NO];
        [alertView release];
    }
    else
    {
        NSNumber* decisionNumber;
        
        if (status == PBBiometryStatusCancelled)
        {
            decisionNumber = [NSNumber numberWithInt:PB_DISPLAY_DECISION_REJECT_CANCELLED];
        }
        else if (status == PBBiometryStatusTimedOut)
        {
            decisionNumber = [NSNumber numberWithInt:PB_DISPLAY_DECISION_REJECT_TIMEDOUT];
        }
        else if (status == PBBiometryStatusFingerBlocked)
        {
            decisionNumber = [NSNumber numberWithInt:PB_DISPLAY_DECISION_REJECT_BLOCKED];
        }
        else
        {
            decisionNumber = [NSNumber numberWithInt:PB_DISPLAY_DECISION_REJECT_UNKNOWN];
        }
        
        if (restartVerification)
        {
            /* The cancel was triggered by the user choosing another finger. */
            restartVerification = NO;
        }
        else
        {
            /* Display reject decision to user. */
            [self performSelectorOnMainThread:@selector(displayDecision:) withObject:decisionNumber waitUntilDone:NO];
            /* Sleep for a short while so user has time to see what went wrong. */
            [NSThread sleepForTimeInterval:PB_DISPLAY_REJECT_TIME];
            
            /* Cancel or timeout or other event that we don't need to alert the user about. 
             * Notify delegate that the verification failed. */
            [(NSObject*)delegate performSelectorOnMainThread:@selector(verificationVerifiedFinger:) withObject:nil waitUntilDone:NO];
        }   
    }
    
    [pool release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    /* Notify delegate that the verification failed. */
    [(NSObject*)delegate performSelectorOnMainThread:@selector(verificationVerifiedFinger:) withObject:nil waitUntilDone:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    /* Set title. */
    titleLabel.text = title;
    
    /* Set cancel button. */
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelCapture)];
    
    self.navigationItem.rightBarButtonItem = cancelButton;
    [cancelButton release];
    
    errorLabel1.text = @"";
    errorLabel2.text = @"";
    errorLabel3.text = @"";
    errorLabel4.text = @"";

    [decisionImage setHidden:YES];
    [decisionLabel setHidden:YES];
    [fadeLabel setHidden:YES];
    
    insideAnimation = NO;
    continueAnimation = NO;
}

- (UIImage*)imageForFinger: (PBBiometryFinger*)finger
{
    switch (finger.position)
    {
        case PBFingerPositionLeftLittle:
            return [UIImage imageNamed:@"left_little.png"];
        case PBFingerPositionLeftRing:
            return [UIImage imageNamed:@"left_ring.png"];
        case PBFingerPositionLeftMiddle:
            return [UIImage imageNamed:@"left_middle.png"];
        case PBFingerPositionLeftIndex:
            return [UIImage imageNamed:@"left_index.png"];
        case PBFingerPositionLeftThumb:
            return [UIImage imageNamed:@"left_thumb.png"];
        case PBFingerPositionRightLittle:
            return [UIImage imageNamed:@"right_little.png"];
        case PBFingerPositionRightRing:
            return [UIImage imageNamed:@"right_ring.png"];
        case PBFingerPositionRightMiddle:
            return [UIImage imageNamed:@"right_middle.png"];
        case PBFingerPositionRightIndex:            
        default:
            return [UIImage imageNamed:@"right_index.png"];
        case PBFingerPositionRightThumb:
            return [UIImage imageNamed:@"right_thumb.png"];
    }
    
}

- (void)displayFingersForIndex: (NSUInteger)index
{
    /* Set previous finger image, if applicable. */
    if (index == 0)
    {
        [previousFingerButton setHidden:YES];
    }
    else
    {
        [previousFingerButton setImage:[self imageForFinger:[fingers objectAtIndex:index - 1]] forState:UIControlStateNormal];
        [previousFingerButton setHidden:NO];
    }
    
    /* Set next finger image, if applicable. */
    if (index == [fingers count] - 1)
    {
        [nextFingerButton setHidden:YES];
    }
    else
    {
        [nextFingerButton setImage:[self imageForFinger:[fingers objectAtIndex:index + 1]] forState:UIControlStateNormal];
        [nextFingerButton setHidden:NO];
    }
    
    /* Set chosen finger image. */
    [currentFingerImage setImage:[self imageForFinger:[fingers objectAtIndex:index]]];    
    [currentFingerImage setHidden:NO];
}

- (void)displayFingersForIndex: (NSUInteger)index
                 previousIndex: (NSUInteger)previousIndex
                      animated: (BOOL)animated
{    
    if (verifyAgainstAllFingers)
    {
        [nextFingerButton setHidden:YES];
        [previousFingerButton setHidden:YES];
        [currentFingerImage setImage:[self imageForFinger:[fingers objectAtIndex:indexOfFingerToVerifyAgainst]]];
    }
    else
    {
        if (animated)
        {
            /* Create copies of the current fingers to use for animation. */
            UIImageView* previousCopy = [[UIImageView alloc] initWithImage:[previousFingerButton imageForState:UIControlStateNormal]];
            UIImageView* currentCopy = [[UIImageView alloc] initWithImage:currentFingerImage.image];
            UIImageView* nextCopy = [[UIImageView alloc] initWithImage:[nextFingerButton imageForState:UIControlStateNormal]];
            [previousFingerButton.superview addSubview:previousCopy];
            [currentFingerImage.superview addSubview:currentCopy];
            [nextFingerButton.superview addSubview:nextCopy];
            
            /* Since current finger is being animated we need to use it's presentationLayer
             * to get properties of the image. */
            CALayer* currentImagePresentationLayer = currentFingerImage.layer.presentationLayer;

            previousCopy.frame = previousFingerButton.frame;
            currentCopy.frame = currentImagePresentationLayer.frame;
            nextCopy.frame = nextFingerButton.frame;
            
            [previousCopy setHidden:previousFingerButton.hidden];
            [currentCopy setHidden:NO];
            [nextCopy setHidden:nextFingerButton.hidden];
            
            [previousCopy.layer setZPosition:previousFingerButton.layer.zPosition];
            [currentCopy.layer setZPosition:currentFingerImage.layer.zPosition];
            [nextCopy.layer setZPosition:nextFingerButton.layer.zPosition];
            
            currentCopy.alpha = currentImagePresentationLayer.opacity;

            [nextFingerButton setHidden:YES];
            [previousFingerButton setHidden:YES];
            [currentFingerImage setHidden:YES];
            
            /* Stop current finger animation and make sure that it will restart from origin. */
            continueAnimation = NO;
            [currentFingerImage.layer removeAllAnimations];
            [currentFingerImage setAlpha:0.0];
            [currentFingerImage setTransform:CGAffineTransformMakeTranslation(0, 0)];

            /* Animate switch between fingers, using the copied image views. */
            [UIView animateWithDuration:0.2 animations:^{
                if (previousIndex > index)
                {
                    previousCopy.frame = currentFingerImage.frame;
                    currentCopy.frame = nextFingerButton.frame;
                    CGRect frame = nextCopy.frame;
                    frame.size.width = 0;
                    frame.size.height = 0;
                    frame.origin.x += 30;
                    frame.origin.y += 90;
                    nextCopy.frame = frame;
                }
                else
                {
                    nextCopy.frame = currentFingerImage.frame;
                    currentCopy.frame = previousFingerButton.frame;
                    CGRect frame = previousCopy.frame;
                    frame.size.width = 0;
                    frame.size.height = 0;
                    frame.origin.x -= 30;
                    frame.origin.y += 90;
                    previousCopy.frame = frame;
                }
            } completion:^(BOOL finished)
            {
                [previousCopy removeFromSuperview];
                [currentCopy removeFromSuperview];
                [nextCopy removeFromSuperview];
                [previousCopy release];
                [currentCopy release];
                [nextCopy release];
                
                /* Startup current finger animation again. */
                [currentFingerImage setAlpha:1.0];
                if (! continueAnimation && ! insideAnimation) {
                    [self animateHand];
                }
                continueAnimation = YES;
                [self displayFingersForIndex:index];
                
                /* Startup verification again. */
                [NSThread detachNewThreadSelector:@selector(doVerification) toTarget:self withObject:nil];
            }];
        }
        else
        {
            [self displayFingersForIndex:index];
        }
    }    
}

- (void)initializeFingerToVerifyAgainst
{    
    self->restartVerification = NO;
    
    /* Find the finger that was last verified against. We assume that the 
     * user wants to verify against that finger again. */
    PBFingerPosition lastFingerPosition = [[NSUserDefaults standardUserDefaults] integerForKey:@"PBVerificationController.lastFingerPosition"];
    
    /* Check if the last finger is found amongst the fingers to verify 
     * against. Use first enrolled finger if not found. */
    indexOfFingerToVerifyAgainst = 0;
    for (NSUInteger f = 0; f < [fingers count]; f++)
    {
        PBBiometryFinger* finger = [fingers objectAtIndex:f];
        
        if (finger.position == lastFingerPosition)
        {
            indexOfFingerToVerifyAgainst = f;
            break;
        }
        else if ([finger isEqualToFinger:firstFinger])
        {
            /* Store index of first finger (fingers have been resorted) in case the last
             * finger position is not found. */
            indexOfFingerToVerifyAgainst = f;
        }
    }
    
    /* Store last finger for future verifications. */
    PBBiometryFinger* finger = [fingers objectAtIndex:indexOfFingerToVerifyAgainst];
    [[NSUserDefaults standardUserDefaults] setInteger:finger.position forKey:@"PBVerificationController.lastFingerPosition"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    /* Show toolbar if we are used in a navigation controller. */
    [self.navigationController setToolbarHidden:NO];
    
    /* Display the fingers. */
    [self initializeFingerToVerifyAgainst];
    [self displayFingersForIndex:indexOfFingerToVerifyAgainst previousIndex:0 animated:NO];
     
    /* Start animation of hand. */
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

- (void)viewDidAppear:(BOOL)animated
{
    /* Start the verification in a new thread to allow for the UI to be updated while enrolling. */
    [NSThread detachNewThreadSelector:@selector(doVerification) toTarget:self withObject:nil];    
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

- (void)earthquake:(UIView*)view
         amplitude:(CGFloat)amplitude
       repeatCount:(float)repeatCount
 animationDuration:(NSTimeInterval)animationDuration
{
    CGAffineTransform leftQuake  = CGAffineTransformTranslate(CGAffineTransformIdentity, amplitude, 0);
    CGAffineTransform rightQuake = CGAffineTransformTranslate(CGAffineTransformIdentity, -amplitude, 0);
    
    /* Start at one side. */
    view.transform = leftQuake;
    
    [UIView beginAnimations:@"earthquake" context:view];
    /* Autoreversing from start side to end side. */
    [UIView setAnimationRepeatAutoreverses:YES];
    [UIView setAnimationRepeatCount:repeatCount];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(earthquakeEnded:finished:context:)];
    
    /* End at other side. */
    view.transform = rightQuake;
    
    [UIView commitAnimations];
}

- (void)earthquakeEnded:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
    if ([finished boolValue]) 
    {
        UIView* view = (UIView *)context;
        view.transform = CGAffineTransformIdentity;
    }
}

- (void)vibrate
{
    /* Play swipe error sound, if allowed. */
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"PBPlaySounds"])
    {
        [self playSound:@"PBSwipeFailed"];
    }
    /* Vibrate, if allowed. */
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"PBVibrateForSwipeFailure"])
    {
        AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);        
    }
    [self earthquake:self.view amplitude:2.0 repeatCount:5 animationDuration:0.05];
}

/** Helper function to allow for the UI changes to be made by the main thread. */
-(void) displayEventInMainThread: (NSMutableArray*) params
{
    NSInteger event_ = (PBEvent)[[params objectAtIndex:0] intValue];
    
    switch (event_)
    {
        case PBEventAlertFingerRejected:
            [self displayError:@"Finger did not match"];
            [self vibrate];
            break;
            
        case PBEventAlertImageCaptured:
            /* Restart the idle timer, to simulate the same behavior as when the user
             * touched the screen. Also un-dimms the screen if it is currently dimmed. */
            [UIApplication sharedApplication].idleTimerDisabled = YES;
            [UIApplication sharedApplication].idleTimerDisabled = NO;
            
            /* Notify user that the image has been captured and now being processed. */
            [activityIndicator setHidden:NO];
            [activityIndicator startAnimating];
            [processingLabel setHidden:NO];
            [currentFingerImage setHidden:YES];
            [nextFingerButton setEnabled:NO];
            [previousFingerButton setEnabled:NO];
            break;
            
        case PBEventAlertSwipeTooFast:
            [self displayError:@"Swipe was too fast"];
            [self vibrate];
            break;
            
        case PBEventAlertQualityTooBad:
            [self displayError:@"Fingerprint quality too poor"];
            [self vibrate];
            break;
            
        case PBEventAlertAreaTooSmall:
            [self displayError:@"Fingerprint area too small"];
            [self vibrate];
            break;
            
        case PBEventPromptSwipeFinger:
            [activityIndicator stopAnimating];
            [processingLabel setHidden:YES];
            [currentFingerImage setHidden:NO];
            [nextFingerButton setEnabled:YES];
            [previousFingerButton setEnabled:YES];
            break;
    }
}

-(void) displayEvent: (PBEvent) event_ 
           forFinger: (PBBiometryFinger*) finger
{
    NSMutableArray* params = [[NSMutableArray alloc] init];
    NSNumber* number;
    
    /* Create an NSMutableArray object including all the parameters, which can 
     * be sent using the performSelectorOnMainThread message. */
    number = [[NSNumber alloc] initWithInt:event_];
    [params addObject:number];
    [number release];
    
    /* Make sure all UI changes are made in the main thread. */
    [self performSelectorOnMainThread:@selector(displayEventInMainThread:) withObject:params waitUntilDone:NO];
    [params release];
}

-(IBAction)choosePreviousFinger:(id)sender
{
    if (indexOfFingerToVerifyAgainst > 0)
    {
        indexOfFingerToVerifyAgainst--;
        
        /* Store last finger for future verifications. */
        PBBiometryFinger* finger = [fingers objectAtIndex:indexOfFingerToVerifyAgainst];
        [[NSUserDefaults standardUserDefaults] setInteger:finger.position forKey:@"PBVerificationController.lastFingerPosition"];
        
        /* Display the new fingers. */
        [self displayFingersForIndex:indexOfFingerToVerifyAgainst previousIndex:indexOfFingerToVerifyAgainst + 1 animated:YES];
        
        /* Stop verification, will be restarted after display animation. */
        restartVerification = YES;
        [[PBBiometry sharedBiometry] cancel];
    }
}

-(IBAction)chooseNextFinger:(id)sender
{
    if (indexOfFingerToVerifyAgainst < ([fingers count] - 1))
    {
        indexOfFingerToVerifyAgainst++;
        
        /* Store last finger for future verifications. */
        PBBiometryFinger* finger = [fingers objectAtIndex:indexOfFingerToVerifyAgainst];
        [[NSUserDefaults standardUserDefaults] setInteger:finger.position forKey:@"PBVerificationController.lastFingerPosition"];
        
        /* Display the new fingers. */
        [self displayFingersForIndex:indexOfFingerToVerifyAgainst previousIndex:indexOfFingerToVerifyAgainst - 1 animated:YES];
        
        /* Stop verification, will be restarted after display animation. */
        restartVerification = YES;
        [[PBBiometry sharedBiometry] cancel];
    }
}
@end