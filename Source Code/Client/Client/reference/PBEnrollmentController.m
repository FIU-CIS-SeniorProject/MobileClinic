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
 * $Date: 2012-05-16 16:16:10 +0200 (on, 16 maj 2012) $ $Rev: 14768 $
 *
 */
#import "PBEnrollmentController.h"
#import "PBBiometry.h"
#import <QuartzCore/CALayer.h>
#import <AudioToolbox/AudioToolbox.h>

#define PB_GUI_NBR_OF_ANIMATION_IMAGES 3
#define PB_GUI_NBR_OF_ENROLLMENT_IMAGES 3

@implementation PBEnrollmentController
@synthesize config;

-(id) initWithDatabase: (id<PBBiometryDatabase>) aDatabase
             andFinger: (PBBiometryFinger*) aFinger
           andDelegate: (id <PBEnrollmentDelegate>) aDelegate
{
    self = [super init];
    self->finger = aFinger;
    [aFinger retain];
    self->delegate = aDelegate;
    [aDelegate retain];
    self->database = aDatabase;
    [aDatabase retain];
    
    self->config = [[PBBiometryEnrollConfig alloc] init];
    
    /* Set title in case we are added in a navigation controller. */
    self.title = @"Register finger";
    
    return self;
}

- (void)dealloc
{
    [insideView release];
    [mainImage release];
    [smallImage1 release];
    [smallImage2 release];
    [smallImage3 release];
    [errorLabel1 release];
    [errorLabel2 release];
    [errorLabel3 release];
    [errorLabel4 release];
    [numberLabel1 release];
    [numberLabel2 release];
    [numberLabel3 release];
    [infoLabel release];
    [activityIndicator release];
    [decisionImage release];
    [decisionLabel release];
    [fadeLabel release];
    [database release];
    [finger release];
    [delegate release];
    [config release];
    [smallImages release];
    [numberLabels release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(NSString*) fingerStringfromFinger: (PBBiometryFinger*) aFinger
{
    switch (aFinger.position)
    {
        case PBFingerPositionLeftIndex:
            return @"left index";
        case PBFingerPositionLeftLittle:
            return @"left little";
        case PBFingerPositionLeftMiddle:
            return @"left middle";
        case PBFingerPositionLeftRing:
            return @"left ring";
        case PBFingerPositionLeftThumb:
            return @"left thumb";
        case PBFingerPositionRightIndex:
            return @"right index";
        case PBFingerPositionRightLittle:
            return @"right little";
        case PBFingerPositionRightMiddle:
            return @"right middle";
        case PBFingerPositionRightRing:
            return @"right ring";
        case PBFingerPositionRightThumb:
            return @"right thumb";
        default:
            return @"any";
    }
}

- (void)cancelCapture
{
    enrolling = NO;
    // Cancel the enrollment.
    [[PBBiometry sharedBiometry] cancel];
}

- (void)displayError: (NSString*)error
{
    errorLabel4.text = errorLabel3.text;
    errorLabel3.text = errorLabel2.text;
    errorLabel2.text = errorLabel1.text;
    errorLabel1.text = error;
}

#define PB_DISPLAY_DECISION_ACCEPT   0
#define PB_DISPLAY_DECISION_REJECT_CANCELLED 2
#define PB_DISPLAY_DECISION_REJECT_TIMEDOUT  3
#define PB_DISPLAY_DECISION_REJECT_UNKNOWN   4
#define PB_DISPLAY_DECISION_REJECT_VERIFICATION_FAILED 5

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
    if ([decision intValue] == PB_DISPLAY_DECISION_ACCEPT)
    {
        decisionImage.image = [UIImage imageNamed:@"accept.png"];
        
        // Play accept sound, if allowed.
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"PBPlaySounds"])
        {
            [self playSound:@"PBVerificationAccepted"];
        }
    }
    else
    {
        decisionImage.image = [UIImage imageNamed:@"reject.png"];
        if ([decision intValue] == PB_DISPLAY_DECISION_REJECT_CANCELLED)
        {
            decisionLabel.text = @"Cancelled";
        }
        else if ([decision intValue] == PB_DISPLAY_DECISION_REJECT_TIMEDOUT)
        {
            decisionLabel.text = @"Timed out";
        }
        else if ([decision intValue] == PB_DISPLAY_DECISION_REJECT_VERIFICATION_FAILED)
        {
            decisionLabel.text = @"No match";
        }
        else
        {
            decisionLabel.text = @"Unknown error";
        }
        
        [decisionLabel setHidden:NO];
        
        // Play reject sound, if allowed.
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

-(void) doEnrollment
{
    // Create an autorelease pool for the thread.
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    PBBiometryStatus status;
    
    currentChosenImage = 0;
    
    // Start the enrollment process.
    status = [[PBBiometry sharedBiometry] enrollFinger:finger database:database gui:self nbrOfImages:PB_GUI_NBR_OF_ENROLLMENT_IMAGES config:config];
    
    enrolling = NO;
    
    // Notify user the status of the operation.
    if (status == PBBiometryStatusOK)
    {
        // Display decision to user.
        [self performSelectorOnMainThread:@selector(displayDecision:) withObject:[NSNumber numberWithInt: PB_DISPLAY_DECISION_ACCEPT] waitUntilDone:NO];
        
        [(NSObject*)delegate performSelectorOnMainThread:@selector(enrollmentTemplateEnrolledForFinger:) withObject:finger waitUntilDone:NO];
    }
    else if (status == PBBiometryStatusReaderBusy)
    {
        // Reader is already used by another application.
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Tactivo busy" message:@"The Tactivo is already used by another application. Close that application or make sure that it is no longer using the Tactivo before trying again." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [self performSelectorOnMainThread:@selector(showAlertInMainThread:) withObject:alertView waitUntilDone:NO];
        [alertView release];
    }
    else if (status == PBBiometryStatusReaderNotAvailable)
    {
        // Reader is not available.
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Tactivo not accessible" message:@"The Tactivo is not connected to the device or is waiting to be authenticated. Please connect the Tactivo or wait for the authentication to be completed." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [self performSelectorOnMainThread:@selector(showAlertInMainThread:) withObject:alertView waitUntilDone:NO];
        [alertView release];
    }
    else if (status == PBBiometryStatusProtocolNotIncluded)
    {
        // Reader is not available.
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Protocol not included" message:@"The protocol string 'com.precisebiometrics.sensor' is not included in the 'UISupportedExternalAccessoryProtocols' key in the Info.plist." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [self performSelectorOnMainThread:@selector(showAlertInMainThread:) withObject:alertView waitUntilDone:NO];
        [alertView release];
    }
    else if (status == PBBiometryStatusFatal)
    {
        // Unknown error.
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
        else if (status == PBBiometryStatusEnrollmentVerificationFailed)
        {
            decisionNumber = [NSNumber numberWithInt:PB_DISPLAY_DECISION_REJECT_VERIFICATION_FAILED];
        }
        else
        {
            decisionNumber = [NSNumber numberWithInt:PB_DISPLAY_DECISION_REJECT_UNKNOWN];
        }
        
        // Display reject decision to user.
        [self performSelectorOnMainThread:@selector(displayDecision:) withObject:decisionNumber waitUntilDone:NO];

        // Sleep for a short while so user has time to see what went wrong.
        [NSThread sleepForTimeInterval:PB_DISPLAY_REJECT_TIME];
        
        // Cancel or timeout or other event that we don't need to alert the user about.
        // Notify delegate that the verification failed.
        [(NSObject*)delegate performSelectorOnMainThread:@selector(enrollmentTemplateEnrolledForFinger:) withObject:nil waitUntilDone:NO];
    }
    
    [activityIndicator stopAnimating];
    [pool release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Notify delegate that the verification failed.
    [(NSObject*)delegate performSelectorOnMainThread:@selector(enrollmentTemplateEnrolledForFinger:) withObject:nil waitUntilDone:NO];
}

- (void)setInfoTextInMainThread: (NSString*) infoText
{
    infoLabel.text = infoText;
    [infoText release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    enrolling = YES;
    
    // Set cancel button.
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelCapture)];
    
    self.navigationItem.rightBarButtonItem = cancelButton;
    [cancelButton release];
    
    /* Setup small images. */
    smallImages = [[NSArray alloc] initWithObjects:smallImage1, smallImage2, smallImage3, nil];
    
    /* Setup number labels. */
    numberLabels = [[NSArray alloc] initWithObjects:numberLabel1, numberLabel2, numberLabel3, nil];
    
    errorLabel1.text = @"";
    errorLabel2.text = @"";
    errorLabel3.text = @"";
    errorLabel4.text = @"";
    
    [decisionImage setHidden:YES];
    [decisionLabel setHidden:YES];
    [fadeLabel setHidden:YES];
    
    // Show toolbar if we are used in a navigation controller.
    [self.navigationController setToolbarHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    // Start the enrollment in a new thread to allow for the UI to be updated while enrolling.
    [NSThread detachNewThreadSelector:@selector(doEnrollment) toTarget:self withObject:nil];
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
    
    // Start at one side.
    view.transform = leftQuake;
    
    [UIView beginAnimations:@"earthquake" context:view];

    // Autoreversing from start side to end side.
    [UIView setAnimationRepeatAutoreverses:YES];
    [UIView setAnimationRepeatCount:repeatCount];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(earthquakeEnded:finished:context:)];
    
    // End at other side.
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
    // Play swipe error sound, if allowed.
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"PBPlaySounds"])
    {
        [self playSound:@"PBSwipeFailed"];
    }
    
    // Vibrate, if allowed.
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"PBVibrateForSwipeFailure"]) {
        AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
    }
    [self earthquake:self.view amplitude:2.0 repeatCount:5 animationDuration:0.05];
}

// Helper function to allow for the UI changes to be made by the main thread.
-(void) displayEventInMainThread: (NSMutableArray*) params
{
    NSInteger event_ = (PBEvent)[[params objectAtIndex:0] intValue];
    
    switch (event_)
    {
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
            infoLabel.text = [NSString stringWithFormat:@"Swipe %@ finger", [self fingerStringfromFinger:finger]];
            break;
    }
}

-(void) displayEvent: (PBEvent) event_
           forFinger: (PBBiometryFinger*) finger
{
    NSMutableArray* params = [[NSMutableArray alloc] init];
    NSNumber* number;
    
    // Create an NSMutableArray object including all the parameters, which can
    // be sent using the performSelectorOnMainThread message.
    number = [[NSNumber alloc] initWithInt:event_];
    [params addObject:number];
    [number release];
    
    // Make sure all UI changes are made in the main thread.
    [self performSelectorOnMainThread:@selector(displayEventInMainThread:) withObject:params waitUntilDone:NO];
    [params release];
}

// Helper function to allow for the UI changes to be made by the main thread.
-(void) displayImageInMainThread: (UIImage*) image
{
    [mainImage setImage:image];
    // Restart the idle timer, to simulate the same behavior as when the user
    // touched the screen. Also un-dimms the screen if it is currently dimmed.
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

-(void) displayImage: (UIImage*) image
{
    // Make sure all UI changes are made in the main thread.
    [self performSelectorOnMainThread:@selector(displayImageInMainThread:) withObject:image waitUntilDone:NO];
}

// Helper function to allow for the UI changes to be made by the main thread.
-(void) displayChosenImageInMainThread: (UIImage*) image
{
    UIImageView* imageView = [smallImages objectAtIndex:currentChosenImage];
    UILabel* label = [numberLabels objectAtIndex:currentChosenImage];
    
    PBFingerImageView* animatingImage = [[PBFingerImageView alloc] initWithImage:image];
    [insideView addSubview:animatingImage];
    animatingImage.frame = mainImage.frame;
    [mainImage setImage:nil];
    
    [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        animatingImage.frame = imageView.frame;
    } completion:^(BOOL finished)
    {
        [label setHidden:YES];
        [imageView setImage:image];
        [animatingImage removeFromSuperview];
        [animatingImage release];
    }];
    
    if (currentChosenImage == (PB_GUI_NBR_OF_ENROLLMENT_IMAGES - 1))
    {
        // Last chosen image, start activity indicator since a lot of processing
        // will occur now.
        [activityIndicator setHidden:NO];
        [activityIndicator startAnimating];
        [infoLabel setText:@"Processing images..."];
    }
    
    currentChosenImage = (currentChosenImage + 1) % PB_GUI_NBR_OF_ENROLLMENT_IMAGES;
    
    // Reset error labels.
    errorLabel1.text = @"";
    errorLabel2.text = @"";
    errorLabel3.text = @"";
    errorLabel4.text = @"";
}

-(void) displayChosenImage: (UIImage*) image
{
    // Make sure all UI changes are made in the main thread.
    [self performSelectorOnMainThread:@selector(displayChosenImageInMainThread:) withObject:image waitUntilDone:NO];
}

// Helper function to allow for the UI changes to be made by the main thread.
-(void) displayQualityInMainThread: (NSMutableArray*) params
{
    // Do nothing.
}

-(void) displayQuality: (uint8_t) imageQuality
               andArea: (uint32_t) area
 imageQualityThreshold: (uint8_t) imageQualityThreshold
         areaThreshold: (uint32_t) areaThreshold
{
    NSMutableArray* params = [[NSMutableArray alloc] init];
    NSNumber* number;
    
    // Create an NSMutableArray object including all the parameters, which can
    // be sent using the performSelectorOnMainThread message.
    number = [[NSNumber alloc] initWithUnsignedChar:imageQuality];
    [params addObject:number];
    [number release];
    number = [[NSNumber alloc] initWithUnsignedInt:area];
    [params addObject:number];
    [number release];
    number = [[NSNumber alloc] initWithUnsignedChar:imageQualityThreshold];
    [params addObject:number];
    [number release];
    number = [[NSNumber alloc] initWithUnsignedInt:areaThreshold];
    [params addObject:number];
    [number release];
    
    // Make sure all UI changes are made in the main thread.
    [self performSelectorOnMainThread:@selector(displayQualityInMainThread:) withObject:params waitUntilDone:NO];
    [params release];
}
@end