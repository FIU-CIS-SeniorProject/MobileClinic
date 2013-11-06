//
//  UIViewControllerExt.h
//  OmniOrganize
//
//  Created by Michael Montaque on 1/22/12.
//  Copyright (c) 2012 Florida International University. All rights reserved.
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
