// The MIT License (MIT)
//
// Copyright (c) 2013 Florida International University
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//  UIViewControllerExt.m
//  OmniOrganize
//
//  Created by Michael Montaque on 1/22/12.
//
#import "MBProgressHUD.h"
#define STORYBOARDNAME @"NewStoryboard"
#import "UIViewControllerExt.h"

@implementation UIViewController (Extended)

/* Not Needed in this project
-(void)customFadeInPresentationOfNewView:(UIViewController*)controller{
  
    [controller.view setAlpha:0];
    
    //self.view.center=CGPointMake(160, -300);
   
    [self.view addSubview:controller.view];
    
    [UIView animateWithDuration:.5 animations:^{
        [controller.view setAlpha:1];
    }];

}
-(void)dismissCustomViewController:(UIViewController*)view{
    
    [UIView animateWithDuration:.5 animations:^{
        [view.view setAlpha:0];
    } completion:^(BOOL finished) {
            [view.view removeFromSuperview];
    }];
}
-(void)customTopFadeInPresentationOfNewView:(UIView*)view{
    
   
        
        [view setAlpha:0];
        
        [self.view addSubview:self.view];
    
        CGFloat width = self.view.frame.size.width;
        CGFloat height = self.view.frame.size.height;
    [view setCenter:CGPointMake(width/2, -(height/2))];
           
    
        [UIView animateWithDuration:.5 animations:^{
           
            [view setCenter:self.self.view.center];

            [view setAlpha:1];
        }];

}
-(void)ExecuteActionInViewControllerForAppropriateDevice:(ScreenDelegator)mainScreen{
    if ([self isDeviceiPad]) {
        ScreenDelegator delegate = ^(id screen){
            if ([screen isKindOfClass:[UINavigationController class]]) {
                UINavigationController* nav = screen;
                mainScreen(nav.visibleViewController);
            }else if ([screen isKindOfClass:[UIViewController class]]){
                mainScreen(screen);
            }
        };
        [[NSNotificationCenter defaultCenter]postNotificationName:DETAIL_VIEW_MAIN_CONTROLLER object:delegate];
    }else{
        mainScreen(self);
    }
}
-(void)ExecuteActionInNavigationControllerForAppropriateDevice:(ScreenDelegator)mainScreen{
    if ([self isDeviceiPad]) {
        ScreenDelegator delegate = ^(id screen){
            if ([screen isKindOfClass:[UINavigationController class]]) {
                mainScreen(screen);
            }
        };
        [[NSNotificationCenter defaultCenter]postNotificationName:DETAIL_VIEW_MAIN_CONTROLLER object:delegate];
    }else{
        if (self.navigationController) {
            mainScreen(self.navigationController);
        }
    }
}
-(void)overlayThisViewOverSelf:(UIView *)view{
    
    [view setAlpha:0];
    
    [self.view addSubview:view];
   
    [UIView animateWithDuration:.5 animations:^{
        [view setAlpha:1];
    }];
}
*/

-(id)getViewControllerFromiPadStoryboardWithName:(NSString *)viewName{
    UIStoryboard* story = [UIStoryboard storyboardWithName:STORYBOARDNAME bundle:[NSBundle mainBundle]];
    return [story instantiateViewControllerWithIdentifier:viewName];
}
-(id)getViewControllerFromiPhoneStoryboardWithName:(NSString *)viewName{
    UIStoryboard* story = [UIStoryboard storyboardWithName:STORYBOARDNAME bundle:nil];
    return [story instantiateViewControllerWithIdentifier:viewName];
}
+(id)getViewControllerFromiPadStoryboardWithName:(NSString *)viewName{
    UIStoryboard* story = [UIStoryboard storyboardWithName:STORYBOARDNAME bundle:nil];
    return [story instantiateViewControllerWithIdentifier:viewName];
}
-(double)convertBytesToMegaBytes:(long)byte{
    double size = ((double)byte/BYTES);
    return size;
}

-(void)showIndeterminateHUDInView:(UIView*)view withText:(NSString*)string shouldHide:(BOOL)shouldHide afterDelay:(NSInteger)delay andShouldDim:(BOOL)shouldDim{
    
    MBProgressHUD* progress = [MBProgressHUD showHUDAddedTo:view animated:YES];
    
     [progress setDimBackground:shouldDim];
    
     [progress setMode:MBProgressHUDModeIndeterminate];
   
    if (string && string.length > 0) {
        [progress setLabelText:string];
    }
    if (shouldHide) {
        [progress hide:shouldHide afterDelay:delay];
    }
}
-(void)ShowTextHUDInView:(UIView*)view WithText:(NSString*)text shouldHide:(BOOL)shouldHide afterDelay:(NSInteger)delay andShouldDim:(BOOL)shouldDim{
    
    MBProgressHUD* progress = [MBProgressHUD showHUDAddedTo:view animated:YES];
    
    [progress setDimBackground:shouldDim];
    
    [progress setMode:MBProgressHUDModeText];
    
    if (text && text.length > 0) {
        [progress setLabelText:text];
    }
    
    if (shouldHide) {
        [progress hide:shouldHide afterDelay:delay];
    }
}

-(void)HideALLHUDDisplayInView:(UIView*)view{
    [MBProgressHUD hideAllHUDsForView:view animated:YES];
}
-(BOOL)isDeviceiPad{
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
    
}
@end
