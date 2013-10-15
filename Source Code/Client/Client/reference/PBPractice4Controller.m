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
 * $Date: 2012-05-16 16:16:10 +0200 (on, 16 maj 2012) $ $Rev: 14768 $
 */
#import "PBPractice4Controller.h"
#import "PBBiometryEnrollConfig.h"
#import <QuartzCore/CALayer.h>

@implementation PBPractice4Controller

- (id)initWithPracticeController:(PBPracticeController *)aPracticeController 
{
    self = [super init];
    
    self->practiceController = aPracticeController;
    [aPracticeController retain];
    self->disconnectionView = [[PBDisconnectionViewController alloc] init];
    self->startNewCapture = NO;
    self->isVisible = NO;
    
    /* Adding ourself as delegate to PBAccessory to be able to get connect/disconnect 
     * notifications. */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAccessoryDidConnect) name:PBAccessoryDidConnectNotification object:[PBAccessory sharedClass]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAccessoryDidDisconnect) name:PBAccessoryDidDisconnectNotification object:[PBAccessory sharedClass]];
    
    /* Starting the image capturing thread. */
    [NSThread detachNewThreadSelector:@selector(doImageCapturing) toTarget:self withObject:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    
    return self;
}

- (void)dealloc
{
    [largeImage release];
    [barImage0 release];
    [barImage1 release];
    [barImage2 release];
    [barImage3 release];
    [barImage4 release];
    [barImage5 release];
    [barImage6 release];
    [barImage7 release];
    [barImage8 release];
    [barImage9 release];
    [barImageA0 release];
    [barImageA1 release];
    [barImageA2 release];
    [barImageA3 release];
    [barImageA4 release];
    [barImageA5 release];
    [barImageA6 release];
    [barImageA7 release];
    [barImageA8 release];
    [barImageA9 release];
    [resultLabel release];
    [disconnectionView release];
    
    [practiceController release];
    [barImages release];
    [barImagesA release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    barImages = [[NSArray alloc] initWithObjects:barImage0, barImage1, barImage2, barImage3, barImage4, barImage5, barImage6, barImage7, barImage8, barImage9, nil];
    barImagesA = [[NSArray alloc] initWithObjects:barImageA0, barImageA1, barImageA2, barImageA3, barImageA4, barImageA5, barImageA6, barImageA7, barImageA8, barImageA9, nil];
    
    resultLabel.text = nil;
    
    // Place in upper right corner.
    NSInteger padding = 1;
    disconnectionView.view.center = CGPointMake([self view].bounds.size.width - ([disconnectionView view].bounds.size.width / 2) - padding, ([disconnectionView view].bounds.size.height / 2) + padding);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)handleAccessoryDidConnectInMainThread
{
    [disconnectionView viewWillDisappear:NO];
    [[disconnectionView view] removeFromSuperview];
    
    if (isVisible)
    {
        @synchronized (self)
        {
            startNewCapture = YES;
        }        
    }    
}

- (void)handleAccessoryDidConnect
{
    [self performSelectorOnMainThread:@selector(handleAccessoryDidConnectInMainThread) withObject:nil waitUntilDone:NO];
}

- (void)handleAccessoryDidDisconnectInMainThread
{
    [disconnectionView viewWillAppear:NO];
    [[self view] addSubview:[disconnectionView view]];
    
    [[PBBiometry sharedBiometry] cancel];
    @synchronized (self)
    {
        startNewCapture = NO;
    }        
}

- (void)handleAccessoryDidDisconnect
{
    [self performSelectorOnMainThread:@selector(handleAccessoryDidDisconnectInMainThread) withObject:nil waitUntilDone:NO];
}

- (void)showAlertInMainThread: (UIAlertView*)alertView
{
    [alertView show];
}

- (void)doImageCapturing
{
    while (YES)
    {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        
        if (startNewCapture)
        {
            @synchronized (self)
            {
                startNewCapture = NO;
            }
            /* Start image capturing. */
            PBBiometryStatus status = [[PBBiometry sharedBiometry] captureImagesWithGUI:self];
            
            /* Alert user of certain errors. */
            if (status == PBBiometryStatusReaderBusy)
            {
                /* Reader is already used by another application. */
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Tactivo busy" message:@"The Tactivo is already used by another application. Close that application or make sure that it is no longer using the Tactivo before trying again." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
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
        }
        else
        {
            /* Sleep for 100ms. */
            [NSThread sleepForTimeInterval:0.100];
        }
        
        [pool release];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    /* Do nothing. */
}

- (void)startImageCapturing
{
    if ([[PBAccessory sharedClass] isConnected])
    {
        /* Reader is connected, start image capturing. */
        @synchronized (self)
        {
            startNewCapture = YES;
        }
    }    
}

- (void)stopImageCapturing
{
    /* Stop image capturing. */
    [[PBBiometry sharedBiometry] cancel]; 
    @synchronized (self)
    {
        startNewCapture = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([[PBAccessory sharedClass] isConnected])
    {
        [disconnectionView viewWillDisappear:NO];
        [[disconnectionView view] removeFromSuperview];
    }
    else
    {
        [disconnectionView viewWillAppear:NO];
        [[self view] addSubview:[disconnectionView view]];
    }
    isVisible = YES;
#ifdef PB_PRACTICE_RUN_4EVER
    [UIApplication sharedApplication].idleTimerDisabled = YES;
#endif /* PB_PRACTICE_RUN_4EVER */
    
    [self startImageCapturing];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    isVisible = NO;
#ifdef PB_PRACTICE_RUN_4EVER
    [UIApplication sharedApplication].idleTimerDisabled = NO;
#endif /* PB_PRACTICE_RUN_4EVER */
    
    [self stopImageCapturing];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/** Helper function to allow for the UI changes to be made by the main thread. */
-(void) displayEventInMainThread: (NSMutableArray*) params
{
    NSInteger event_ = (PBEvent)[[params objectAtIndex:0] intValue];
    
    switch (event_)
    {
        case PBEventAlertImageCaptured:
            break;
            
        case PBEventAlertSwipeTooFast:
            break;
            
        case PBEventAlertTemplateEnrolled:
            break;
            
        case PBEventAlertTemplateExtracted:
            break;
            
        case PBEventPromptSwipeFinger:
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

/** Helper function to allow for the UI changes to be made by the main thread. */
-(void) displayImageInMainThread: (UIImage*) image
{
    [largeImage setImage:image];
    /* Restart the idle timer, to simulate the same behavior as when the user
     * touched the screen. Also un-dimms the screen if it is currently dimmed. */

#ifndef PB_PRACTICE_RUN_4EVER
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [UIApplication sharedApplication].idleTimerDisabled = NO;
#endif /* ! PB_PRACTICE_RUN_4EVER */
}

-(void) displayImage: (UIImage*) image
{
    /* Make sure all UI changes are made in the main thread. */
    [self performSelectorOnMainThread:@selector(displayImageInMainThread:) withObject:image waitUntilDone:NO];
}

/** Helper function to allow for the UI changes to be made by the main thread. */
-(void) displayQualityInMainThread: (NSMutableArray*) params
{ 
    NSInteger imageQuality = [[params objectAtIndex:0] intValue];
    NSInteger area = [[params objectAtIndex:1] intValue];
    /* Use the default thresholds for the enroll config as thresholds when practicing. */
    PBBiometryEnrollConfig* config = [[PBBiometryEnrollConfig alloc] init];
    NSInteger imageQualityThreshold = config.minimumQuality;
    NSInteger areaThreshold = config.minimumArea;
    [config release];
    BOOL qualityIsOk = (imageQuality > imageQualityThreshold);
    BOOL areaIsOk = (area > areaThreshold);
        
    /* Set text and text color. */
    if (qualityIsOk && areaIsOk)
    {
        /* Ok. */
        resultLabel.text = @"OK!";
        resultLabel.textColor = [UIColor greenColor];
    }
    else
    {
        /* Not ok. */
        resultLabel.textColor = [UIColor redColor];
        
        if (! qualityIsOk)
        {
            resultLabel.text = @"Insufficient quality";
        }
        else
        {
            resultLabel.text = @"Finger area too small";
        }
    }
    
    imageQuality = MIN (9, imageQuality / 10);
    area = MIN (9, 10 * area / 210); 
        
    /* Set bar images for quality. */
    for (NSInteger i = 0; i < 10; i++)
    {
        PBBarImageView* barImage = [barImages objectAtIndex:i];
        
        if (imageQuality >= i)
        {
            if (qualityIsOk)
            {
                [barImage setState:PBBarImageStateOnGreen];
            }
            else
            {
                [barImage setState:PBBarImageStateOnRed];
            }
        }
        else
        {
            [barImage setState:PBBarImageStateOff];
        }
    }
    /* Set bar images for area. */
    for (NSInteger i = 0; i < 10; i++)
    {
        PBBarImageView* barImage = [barImagesA objectAtIndex:i];
        
        if (area >= i)
        {
            if (areaIsOk)
            {
                [barImage setState:PBBarImageStateOnGreen];
            }
            else
            {
                [barImage setState:PBBarImageStateOnRed];
            }
        }
        else
        {
            [barImage setState:PBBarImageStateOff];
        }
    }
}

-(void) displayQuality: (uint8_t) imageQuality
               andArea: (uint32_t) area
 imageQualityThreshold: (uint8_t) imageQualityThreshold
         areaThreshold: (uint32_t) areaThreshold
{
    NSMutableArray* params = [[NSMutableArray alloc] init];
    NSNumber* number;
    
    /* Create an NSMutableArray object including all the parameters, which can 
     * be sent using the performSelectorOnMainThread message. */
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
    
    /* Make sure all UI changes are made in the main thread. */
    [self performSelectorOnMainThread:@selector(displayQualityInMainThread:) withObject:params waitUntilDone:NO];
    [params release];
}

- (IBAction)next: (id)sender
{
    [practiceController scrollRight:sender];
}

- (void)applicationWillResignActive: (NSNotification*)notification
{
    if (isVisible)
    {
        [self stopImageCapturing];
    }
}

- (void)applicationDidBecomeActive: (NSNotification*)notification
{
    if (isVisible)
    {
        [self startImageCapturing];
    }
}

@end
