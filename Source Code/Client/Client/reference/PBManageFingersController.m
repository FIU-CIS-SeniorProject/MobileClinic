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
 * $Date: 2012-08-16 11:15:11 +0200 (to, 16 aug 2012) $ $Rev: 15397 $
 */
#import "PBManageFingersController.h"

#import <QuartzCore/CALayer.h>

@implementation PBManageFingersController

@synthesize verifier;
@synthesize verifyConfig;
@synthesize enrollConfig;
@synthesize verifyAgainstAllFingers;
@synthesize enrollableFingers;

-(CGSize)contentSizeForViewInPopover
{
    return CGSizeMake(768, 916);
}

- (id) initWithDatabase: (id<PBBiometryDatabase>) aDatabase
                andUser: (PBBiometryUser*) aUser;
{
    self = [super init];
    
    self->database = aDatabase;
    [aDatabase retain];
    self->user = aUser;
    [aUser retain];
    
    /* Set default verifier and config parameters. */
    self->verifier = nil;
    self->verifyConfig = [[PBBiometryVerifyConfig alloc] init];
    self->enrollConfig = [[PBBiometryEnrollConfig alloc] init];
    self->verifyAgainstAllFingers = YES;
    self->enrollableFingers = nil;
    
    // Set title in case we are added to a navigation controller.
    if (self.title == nil)
    {
        self.title = @"Manage fingers";
    }
    
    // Set tab bar item in case we are added in a tab bar controller.
    if (self.tabBarItem.image == nil)
    {
        UITabBarItem* tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Manage fingers" image:[UIImage imageNamed:@"tab_managefingers.png"] tag:0];
        self.tabBarItem = tabBarItem;
        [tabBarItem release];
    }    
    return self;
}

- (void)dealloc
{
    [leftHandImage release];
    [rightHandImage release];
    [leftLittle release];
    [leftRing release];
    [leftMiddle release];
    [leftIndex release];
    [leftThumb release];
    [rightLittle release];
    [rightRing release];
    [rightMiddle release];
    [rightIndex release];
    [rightThumb release];
    [scrollView release];
    [noFingersLabel release];
    [scrollToLeftHandImage release];
    [scrollToRightHandImage release];
    [database release];
    [user release];
    [fingerButtons release];
    [enrollableFingers release];
    [verifyConfig release];
    [enrollConfig release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)applyEnrollableFingers
{
    BOOL defaultValue = (enrollableFingers == nil);
    
    // Default is YES if enrollableFingers is nil, otherwise NO.
    leftLittle.enabled = defaultValue;
    leftRing.enabled = defaultValue;
    leftMiddle.enabled = defaultValue;
    leftIndex.enabled = defaultValue;
    leftThumb.enabled = defaultValue;
    rightLittle.enabled = defaultValue;
    rightRing.enabled = defaultValue;
    rightMiddle.enabled = defaultValue;
    rightIndex.enabled = defaultValue;
    rightThumb.enabled = defaultValue;
    
    // Set to YES for all fingers set as enrollable.
    for (PBBiometryFinger* finger in enrollableFingers)
    {
        switch (finger.position)
        {
            case PBFingerPositionLeftLittle:
                leftLittle.enabled = YES;
                break;
            case PBFingerPositionLeftRing:
                leftRing.enabled = YES;
                break;
            case PBFingerPositionLeftMiddle:
                leftMiddle.enabled = YES;
                break;
            case PBFingerPositionLeftIndex:
                leftIndex.enabled = YES;
                break;
            case PBFingerPositionLeftThumb:
                leftThumb.enabled = YES;
                break;
            case PBFingerPositionRightLittle:
                rightLittle.enabled = YES;
                break;
            case PBFingerPositionRightRing:
                rightRing.enabled = YES;
                break;
            case PBFingerPositionRightMiddle:
                rightMiddle.enabled = YES;
                break;
            case PBFingerPositionRightIndex:
                rightIndex.enabled = YES;
                break;
            case PBFingerPositionRightThumb:
                rightThumb.enabled = YES;
                break;
                
            default:
                break;
        }
    }
    
}

- (void)setButtons: (BOOL)inEditMode
{
    for (NSInteger i = 0; i < 10; i++)
    {
        UIButton* button = (UIButton*)[fingerButtons objectAtIndex:i];
        PBBiometryFinger* finger = [[PBBiometryFinger alloc] initWithPosition:(i + 1) andUser:user];
        BOOL isEnrolled = [database templateIsEnrolledForFinger:finger];
        [finger release];
        
        // Set correct button image.
        if (inEditMode)
        {
            if (isEnrolled)
            {
                [button setImage:[UIImage imageNamed:@"key_delete.png"] forState:UIControlStateNormal];                     
            }
            else
            {
                [button setImage:[UIImage imageNamed:@"key_add.png"] forState:UIControlStateNormal];                     
            }
            button.userInteractionEnabled = YES;
        }
        else
        {
            if (isEnrolled)
            {
                [button setImage:[UIImage imageNamed:@"key.png"] forState:UIControlStateNormal];                     
            }
            else
            {
                [button setImage:nil forState:UIControlStateNormal];                     
            }
            button.userInteractionEnabled = NO;
            
        }
    }
        
    // Set enrollable fingers.
    [self applyEnrollableFingers];
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

- (IBAction)scrollLeft
{
    [self scrollLeftAnimated:YES];
}

- (IBAction)scrollRight
{
    [self scrollRightAnimated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    CGFloat pageWidth = aScrollView.frame.size.width;
    NSInteger page = floor((aScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;

    if (page != pageCurrentlyShown)
    {
        pageCurrentlyShown = page;
        
        if (UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation]))
        {
            /* Save the current hand, but only do this while in portrait since when
             * rotating to landscape we might scroll to x = 0 which should not cause a
             * reset of the current hand. */
            [[NSUserDefaults standardUserDefaults] setBool:(page == 0) forKey:@"PBManageFingersController.startAtLeftHand"];
        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    isAnimatingScroll = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Enable paging.
    scrollView.pagingEnabled = YES;
        
    // Remove small hands.
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [scrollToLeftHandImage setHidden:YES];
        [scrollToRightHandImage setHidden:YES];
    }
    
    // Set content size.
    CGFloat contentWidth;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        contentWidth = 2 * 320 + 20;
    }
    else
    {
        contentWidth = 2 * 320;
    }
    [scrollView setContentSize:CGSizeMake(contentWidth, 1)];
    
    // Create and set edit button.
    UIBarButtonItem* editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editFingers)];
    self.navigationItem.rightBarButtonItem = editButton;
    [editButton release];
    
    fingerButtons = [[NSArray alloc] initWithObjects:rightThumb, rightIndex, rightMiddle, rightRing, rightLittle, leftThumb, leftIndex, leftMiddle, leftRing, leftLittle, nil];
    
    // Move right hand images to the right side.
    rightHandImage.transform = CGAffineTransformMake(-1, 0, 0, 1, contentWidth - (2 * rightHandImage.frame.origin.x) - rightHandImage.frame.size.width, 0);
    for (NSInteger i = 0; i < 5; i++) {
        UIButton* button = (UIButton*)[fingerButtons objectAtIndex:i];
        
        button.transform = CGAffineTransformMake(1, 0, 0, 1, contentWidth - (2 * button.frame.origin.x) - button.frame.size.width, 0);        
    }
    scrollToLeftHandImage.transform = CGAffineTransformMake(1, 0, 0, 1, contentWidth - (2 * scrollToLeftHandImage.frame.origin.x) - scrollToLeftHandImage.frame.size.width, 0);
    
    /* Flip scrollToRightImage. */
    scrollToRightHandImage.transform = CGAffineTransformMake(-1, 0, 0, 1, 0, 0);
    
    [self setButtons:NO];
            
    /* Set 'You have no fingers..' label if applicable. */
    [noFingersLabel setHidden:([[database getEnrolledFingers] count] > 0)];    
    
    pageCurrentlyShown = 0;
    
    isAnimatingScroll = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self layoutScrollView];
    if (! [[NSUserDefaults standardUserDefaults] boolForKey:@"PBManageFingersController.startAtLeftHand"])
    {
        [self scrollRightAnimated:NO];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
}

// Displays information to a first time user.
//- (void)handleFirstTimeUser
//{
//    BOOL hasInformedUserAboutFingerRegistration = [[NSUserDefaults standardUserDefaults] boolForKey:@"PBManageFingersController.hasInformedUserAboutFingerRegistration"];
//    
//    if (! hasInformedUserAboutFingerRegistration) {
//        /* Alert the user about fingerprint security. */
//        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Finger registration" message:@"To register a finger, press 'Edit' and then press the '+' sign for the finger to register." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
//        
//        [alertView show];
//        [alertView release];
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"PBManageFingersController.hasInformedUserAboutFingerRegistration"];
//    }
//}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    /* Do nothing. */
}

/* Layout scrollview based on type of device and device orientation. */
- (void)layoutScrollView
{
    BOOL isIPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    BOOL inLandscapeMode = UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]);
    
    /* Reset transform. */
    scrollView.transform = CGAffineTransformIdentity;
    
    /* Set frame size. */
    CGRect frame = scrollView.frame;  
    if (isIPad)
    {
        frame.size.width = 2 * 320 + 20; // Adding additional 20 points for more spacing.
    }
    else
    {
        if (inLandscapeMode)
        {
            frame.size.width = 2 * 320;
        }
        else
        {
            frame.size.width = 320;
        }
    }
    scrollView.frame = frame;
    
    // Apply scaling for iPhone landscape mode.
    if (!isIPad && inLandscapeMode)
    {
        CGFloat scale = 480 / scrollView.frame.size.width;
        scrollView.transform = CGAffineTransformMakeScale(scale, scale);
    }
    
    // Set frame position.
    if (isIPad)
    {
        scrollView.center = self.view.center;
    }
    else
    {
        frame = scrollView.frame;
        frame.origin.x = 0; 
        frame.origin.y = 0;
        scrollView.frame = frame;
    }
    
    // Center no fingers label.
    noFingersLabel.center = self.view.center;

    // Hide small hands for iPhone landscape mode.
    if (!isIPad)
    {
        scrollToLeftHandImage.hidden = inLandscapeMode;
        scrollToRightHandImage.hidden = inLandscapeMode;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self layoutScrollView];
    // Make sure that the user sees the same hand as the last time.
    if (! [[NSUserDefaults standardUserDefaults] boolForKey:@"PBManageFingersController.startAtLeftHand"])
    {
        [self scrollRightAnimated:NO];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    
}

- (void)viewDidAppear:(BOOL)animated
{
    //[self handleFirstTimeUser];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)doEditFingers
{
    [self setButtons:YES];
    
    // Create and set done button.
    UIBarButtonItem* editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditingFingers)];
    self.navigationItem.rightBarButtonItem = editButton;
    [editButton release];
    
    // Disable back button, if any.
    self.navigationItem.hidesBackButton = YES;
    // Disable tabs, if any.
    self.tabBarItem.enabled = NO;
    self.tabBarController.tabBar.userInteractionEnabled = NO;
    // Hide "No fingers registered".
    [noFingersLabel setHidden:YES];
}

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

- (void)editFingers
{    
//    if ([[database getEnrolledFingers] count] > 0) {
//        /* Do not allow non-authorized users to edit fingers, verify that this is
//         * the enrolled user. */
//        PBVerificationController* verificationController = [[PBVerificationController alloc] initWithDatabase:database andFingers:[database getEnrolledFingers] andDelegate:self andTitle:@"Swipe to unlock edit mode."];
//        verificationController.verifier = verifier;
//        verificationController.config = verifyConfig;
//        verificationController.verifyAgainstAllFingers = verifyAgainstAllFingers;
//        UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:verificationController];
//        [verificationController release];
//                
//        /* Set bar colors. */
//        navController.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
//        navController.toolbar.tintColor = self.navigationController.navigationBar.tintColor;
//        
//        [self presentModalViewController:navController animated:YES];
//        [navController release];
//    }
//    else {
//        /* No fingers enrolled, continue directly to edit mode. */
//        [self doEditFingers];
//    }
    [self doEditFingers];
}

- (void)refreshInMainThread
{
    /* Simulate pressing 'done'. */
    [self actionSheet:nil clickedButtonAtIndex:0];    
}

- (void)refresh
{
    [self performSelectorOnMainThread:@selector(refreshInMainThread) withObject:nil waitUntilDone:NO];
}

static PBBiometryFinger* fingerToBeDeleted = nil;

#define ACTION_SHEET_TAG_DELETE_FINGER     1
#define ACTION_SHEET_TAG_CONTINUE          2

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ((actionSheet == nil) || (actionSheet.tag == ACTION_SHEET_TAG_CONTINUE))
    {
        if (buttonIndex == 0)
        {
            // The user wants to continue without any registered fingers.
            [self setButtons:NO];
            
            // Create and set edit button.
            UIBarButtonItem* editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editFingers)];
            self.navigationItem.rightBarButtonItem = editButton;
            [editButton release];
            
            // Enable back button, if any.
            self.navigationItem.hidesBackButton = NO;
            // Enable tab bar, if any.
            self.tabBarController.tabBar.userInteractionEnabled = YES;
            self.tabBarItem.enabled = YES;

            // Set 'You have no fingers..' label if applicable.
            [noFingersLabel setHidden:([[database getEnrolledFingers] count] > 0)];    
        }
    }
    else if (actionSheet.tag == ACTION_SHEET_TAG_DELETE_FINGER)
    {
        if (buttonIndex == 0)
        {
            // The user wants to delete the finger.
            [database deleteTemplateForFinger:fingerToBeDeleted];
            
            UIButton* button = (UIButton*)[fingerButtons objectAtIndex:(fingerToBeDeleted.position - 1)];
            [button setImage:[UIImage imageNamed:@"key_add.png"] forState:UIControlStateNormal];
        }
        [fingerToBeDeleted release];
        fingerToBeDeleted = nil;
    }
}

- (IBAction)enrollFinger: (id) sender
{
    UIButton* buttonPressed = (UIButton*) sender;
    PBBiometryFinger* finger = nil;
    
    if (buttonPressed == leftLittle)
    {
        finger = [[PBBiometryFinger alloc] initWithPosition:PBFingerPositionLeftLittle andUser:user];
    }
    else if (buttonPressed == leftRing)
    {
        finger = [[PBBiometryFinger alloc] initWithPosition:PBFingerPositionLeftRing andUser:user];    
    }
    else if (buttonPressed == leftMiddle)
    {
        finger = [[PBBiometryFinger alloc] initWithPosition:PBFingerPositionLeftMiddle andUser:user];    
    }
    else if (buttonPressed == leftIndex)
    {
        finger = [[PBBiometryFinger alloc] initWithPosition:PBFingerPositionLeftIndex andUser:user];    
    }
    else if (buttonPressed == leftThumb)
    {
        finger = [[PBBiometryFinger alloc] initWithPosition:PBFingerPositionLeftThumb andUser:user];    
    }
    else if (buttonPressed == rightLittle)
    {
        finger = [[PBBiometryFinger alloc] initWithPosition:PBFingerPositionRightLittle andUser:user];    
    }
    else if (buttonPressed == rightRing)
    {
        finger = [[PBBiometryFinger alloc] initWithPosition:PBFingerPositionRightRing andUser:user];    
    }
    else if (buttonPressed == rightMiddle)
    {
        finger = [[PBBiometryFinger alloc] initWithPosition:PBFingerPositionRightMiddle andUser:user];    
    }
    else if (buttonPressed == rightIndex)
    {
        finger = [[PBBiometryFinger alloc] initWithPosition:PBFingerPositionRightIndex andUser:user];    
    }
    else if (buttonPressed == rightThumb)
    {
        finger = [[PBBiometryFinger alloc] initWithPosition:PBFingerPositionRightThumb andUser:user];    
    }
    
    /* Save current hand also when the user is enrolling a finger ensuring that if this is
     * done in landscape mode, when the user returns to portrait mode the hand of the 
     * enrolled finger should be the displayed hand. */
    [[NSUserDefaults standardUserDefaults] setBool:[finger isOnLeftHand] forKey:@"PBManageFingersController.startAtLeftHand"];  
    
    if (finger != nil)
    {
        if ([database templateIsEnrolledForFinger:finger])
        {
            // Already enrolled, delete.
            UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete registered finger" otherButtonTitles:nil];
            
            actionSheet.tag = ACTION_SHEET_TAG_DELETE_FINGER;
            fingerToBeDeleted = finger;
            [finger retain];
            actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            //[actionSheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
            [actionSheet showFromRect:buttonPressed.frame inView:scrollView animated:YES];
            [actionSheet release];
        }
        else
        {
            // Not enrolled, start enrollment.
            PBEnrollmentController* enrollmentController = [[PBEnrollmentController alloc] initWithDatabase:database andFinger:finger andDelegate:self];
            enrollmentController.config = enrollConfig;
            UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:enrollmentController];
            [enrollmentController release];
            
            // Set bar colors.
            navController.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
            navController.toolbar.tintColor = self.navigationController.navigationBar.tintColor;
            
            [self presentViewController:navController animated:YES completion:nil];
            [navController release];
        }
        [finger release];
    }
}

- (void)doneEditingFingers
{
    if ([[database getEnrolledFingers] count] >  0)
    {
        // At least one finger is registered, continue.
        [self actionSheet:nil clickedButtonAtIndex:0];
    }
    else
    {
        // No fingers registered, ask user to continue.
        UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"Continue without any registered fingers?" delegate:self cancelButtonTitle:@"Register fingers" destructiveButtonTitle:@"Continue" otherButtonTitles:nil];
        
        actionSheet.tag = ACTION_SHEET_TAG_CONTINUE;
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [actionSheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
        [actionSheet release];
    }
}

- (void)enrollmentTemplateEnrolledForFinger:(PBBiometryFinger *)finger
{
    if (finger)
    {
        UIButton* button = (UIButton*)[fingerButtons objectAtIndex:(finger.position - 1)];
        [button setImage:[UIImage imageNamed:@"key_delete.png"] forState:UIControlStateNormal];
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)verificationVerifiedFinger: (PBBiometryFinger*) finger
{
    if (finger)
    {
        [self doEditFingers];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end