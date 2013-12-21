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
//  UIViewControllerExt.h
//  OmniOrganize
//
//  Created by Michael Montaque on 1/22/12.
//
#define BYTES 1048576
#import <Foundation/Foundation.h>


@interface UIViewController (Extended)
/* This is not needed in this project
-(void)customFadeInPresentationOfNewView:(UIViewController*)controller;
-(void)dismissCustomViewController:(UIViewController*)view;
-(void)customTopFadeInPresentationOfNewView:(UIViewController*)controller;
-(void)overlayThisViewOverSelf:(UIView*)view;
-(void)ExecuteActionInViewControllerForAppropriateDevice:(ScreenDelegator)mainScreen;
-(void)ExecuteActionInNavigationControllerForAppropriateDevice:(ScreenDelegator)mainScreen;
*/
-(id)getViewControllerFromiPhoneStoryboardWithName:(NSString*)viewName;
-(id)getViewControllerFromiPadStoryboardWithName:(NSString*)viewName;
+(id)getViewControllerFromiPadStoryboardWithName:(NSString*)viewName;
-(double)convertBytesToMegaBytes:(long)byte;
-(void)showIndeterminateHUDInView:(UIView*)view withText:(NSString*)string shouldHide:(BOOL)shouldHide afterDelay:(NSInteger)delay andShouldDim:(BOOL)shouldDim;
-(void)ShowTextHUDInView:(UIView*)view WithText:(NSString*)text shouldHide:(BOOL)shouldHide afterDelay:(NSInteger)delay andShouldDim:(BOOL)shouldDim;
-(void)HideALLHUDDisplayInView:(UIView*)view;
@end
