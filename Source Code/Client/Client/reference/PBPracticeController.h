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
#import "PBBiometry.h"

/** A view controller giving the user information about how to use the sensor. 
  * It also contains a part where the user can try to swiep his/her finger. 
  * 
  * The practice controller can be placed in a UINavigationController. It will 
  * set a default title that will be shown on the navigation bar.
  *
  * Example:
  * 
  *  PBPracticeController* practiceController = [[PBPracticeController alloc] init];
  *  UINavigationController* navController = [[UINavigationController alloc] init];
  *  
  *  [navController pushViewController:practiceController animated:NO];
  *  
  * The practice controller can also be placed in a tab bar controller. It will 
  * create a default tab bar item that will be shown on the tab bar. It is 
  * recommended to place the practice controller in a navigation controller and 
  * then place the navigation controller in the tab bar controller to also get 
  * the correct navigation bar for the practice controller.
  *
  * Example:
  * 
  *  PBPracticeController* practiceController = [[PBPracticeController alloc] init];
  *  UINavigationController* navController = [[UINavigationController alloc] init];
  *  UITabBarController* tabBarController = [[UITabBarController alloc] init];
  *  
  *  [navController pushViewController:practiceController animated:NO];
  *  [tabBarController setViewControllers:[NSArray arrayWithObjects:navController, nil]];
  */
@interface PBPracticeController : UIViewController <UIScrollViewDelegate>
{
    IBOutlet UIScrollView* scrollView;
    NSMutableArray* viewControllers;
    NSInteger pageCurrentlyShown;
    BOOL isAnimatingScroll;
    CGFloat queuedScrollToX;
}
- (IBAction)scrollLeft:(id)sender;
- (IBAction)scrollRight:(id)sender;
@end