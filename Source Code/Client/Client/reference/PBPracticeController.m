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
#import "PBPracticeController.h"
#import "PBPractice1Controller.h"
#import "PBPractice2Controller.h"
#import "PBPractice3Controller.h"
#import "PBPractice4Controller.h"

@implementation PBPracticeController

- (id)init 
{
    self = [super init];
        
    /* Create the view controllers for the 4 views. */
    PBPractice1Controller* practice1 = [[PBPractice1Controller alloc] initWithPracticeController:self];
    PBPractice2Controller* practice2 = [[PBPractice2Controller alloc] initWithPracticeController:self];
    PBPractice3Controller* practice3 = [[PBPractice3Controller alloc] initWithPracticeController:self];
    PBPractice4Controller* practice4 = [[PBPractice4Controller alloc] initWithPracticeController:self];    
    self->viewControllers = [[NSMutableArray alloc] initWithObjects:practice1, practice2, practice3, practice4, nil];
    [practice1 release];
    [practice2 release];
    [practice3 release];
    [practice4 release];
    
    self->pageCurrentlyShown = 0;

    /* Set tab bar item in case we are added in a tab bar controller. */
    UITabBarItem* tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Practice" image:[UIImage imageNamed:@"tab_practice.png"] tag:0];
    self.tabBarItem = tabBarItem;
    [tabBarItem release];
    
    /* Set title in case we are added in a navigation controller. */
    self.title = @"Practice";
    
    return self;
}

- (void)dealloc
{
    [scrollView release];
    
    [viewControllers release];
        
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
                        
    /* Add the views of the view controllers into the scrollview. */                                        
    for (UIViewController* viewController in viewControllers)
    {
        [viewController.view removeFromSuperview];
        [scrollView addSubview:viewController.view];
    }
    
    scrollView.delegate = self;

    isAnimatingScroll = NO;
    queuedScrollToX = CGFLOAT_MIN;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        for (UIViewController* viewController in viewControllers)
        {
            [viewController viewWillAppear:animated];
        }
    }
    else
    {
        UIViewController* appearingController = [viewControllers objectAtIndex:pageCurrentlyShown];
        [appearingController viewWillAppear:animated];
    }
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Set size and position of the view controllers.
    CGRect frame = CGRectMake(0, 0, 320, 480);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        frame.size.height = 400;
        CGFloat marginHorizontal = (scrollView.frame.size.width - (2 * frame.size.width)) / 3;
        CGFloat marginVertical = (scrollView.frame.size.height - (2 * frame.size.height)) / 3;
        
        // Upper left.
        UIViewController* viewController = [viewControllers objectAtIndex:0];
        frame.origin.x = marginHorizontal;
        frame.origin.y = marginVertical;
        viewController.view.frame = frame;
        
        // Upper right.
        viewController = [viewControllers objectAtIndex:1];
        frame.origin.x = 2 * marginHorizontal + frame.size.width;
        frame.origin.y = marginVertical;
        viewController.view.frame = frame;
        
        // Lower left.
        viewController = [viewControllers objectAtIndex:2];
        frame.origin.x = marginHorizontal;
        frame.origin.y = 2 * marginVertical + frame.size.height;
        viewController.view.frame = frame;
        
        // Lower right.
        viewController = [viewControllers objectAtIndex:3];
        frame.origin.x = 2 * marginHorizontal + frame.size.width;
        frame.origin.y = 2 * marginVertical + frame.size.height;
        viewController.view.frame = frame;
        scrollView.contentSize = CGSizeMake(1, 1);
    }
    else
    {
        for (NSInteger i = 0; i < 4; i++)
        {
            UIViewController* viewController = [viewControllers objectAtIndex:i];
            
            frame.origin.x = frame.size.width * i;
            viewController.view.frame = frame;
        }        
        scrollView.contentSize = CGSizeMake(4 * frame.size.width, 1);
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        for (UIViewController* viewController in viewControllers)
        {
            [viewController viewDidAppear:animated];
        }
    }
    else
    {
        UIViewController* appearingController = [viewControllers objectAtIndex:pageCurrentlyShown];
        [appearingController viewDidAppear:animated];    
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        for (UIViewController* viewController in viewControllers)
        {
            [viewController viewWillDisappear:animated];
        }
    }
    else
    {
        UIViewController* disappearingController = [viewControllers objectAtIndex:pageCurrentlyShown];    
        [disappearingController viewWillDisappear:animated];
    }
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        for (UIViewController* viewController in viewControllers)
        {
            [viewController viewDidDisappear:animated];
        }
    }
    else
    {
        UIViewController* disappearingController = [viewControllers objectAtIndex:pageCurrentlyShown];
        [disappearingController viewDidDisappear:animated];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    CGFloat pageWidth = aScrollView.frame.size.width;
    NSInteger page = floor((aScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (page > 3)
    {
        page = 3;
    }
    if (page < 0)
    {
        page = 0;
    }
    
    // Handle appear and disappear notifications (since they aren't handled automatically when adding subviews (for some reason?).
    if (page != pageCurrentlyShown)
    {
        UIViewController* disappearingController = [viewControllers objectAtIndex:pageCurrentlyShown];
        UIViewController* appearingController = [viewControllers objectAtIndex:page];
        
        [disappearingController viewWillDisappear:YES];
        [appearingController viewWillAppear:YES];
        [disappearingController viewDidDisappear:YES];
        [appearingController viewDidAppear:YES];
        pageCurrentlyShown = page;
    }
}

- (void)scrollToX: (CGFloat)x
{
    if (isAnimatingScroll)
    {
        // Already animating, queue scroll.
        queuedScrollToX = x;
    }
    else if (x != scrollView.contentOffset.x)
    {
        isAnimatingScroll = YES;
        [scrollView setContentOffset:CGPointMake(x, 0) animated:YES];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    isAnimatingScroll = NO;
    if (queuedScrollToX != CGFLOAT_MIN)
    {
        // We have a queued scroll, do that now instead.
        [self scrollToX:queuedScrollToX];
        queuedScrollToX = CGFLOAT_MIN;
    }
}

- (IBAction)scrollLeft:(id)sender
{
    int page = pageCurrentlyShown - 1;
    [self scrollToX:(scrollView.frame.size.width * page)];
}

- (IBAction)scrollRight:(id)sender
{
    int page = pageCurrentlyShown + 1;

    [self scrollToX:(scrollView.frame.size.width * page)];
}
@end