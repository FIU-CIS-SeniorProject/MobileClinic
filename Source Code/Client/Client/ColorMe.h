//
//  ColorMe.h
//  OmniOrganize
//
//  Created by Michael Montaque on 1/11/12.
//  Copyright (c) 2012 Florida International University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "UIImage+ImageVerification.h"

@interface ColorMe : NSObject{
    int pickedColor;
}

-(int)selectedColor;
-(UIColor*)useSelectedColor;
-(void)setColor:(int)myColor;

+(void)addShadowLayer:(CALayer*)layer;
+(void)addRoundedEdges:(CALayer*)layer;
+(void)addBorder:(CALayer*)layer withWidth:(CGFloat)width withColor:(UIColor*)color;

+(void)addFadeGradientToLayer:(CALayer*)layer;
+(void)addTopRoundedEdges:(CALayer*)layer;
+(UIColor*)whitishColor;

+(UIColor*)grayishColor;

+(void)coloreMeCompletely:(CALayer*)layer andColor:(int)colorNumber;
    
+(void)coloreTint:(CALayer*)layer andColor:(int)colorNumber;
+(UIColor*)colorFor:(int)colorNumber;

+(void)addRoundedBlackBorderWithShadowInRect:(CALayer*)layer;

+(UIColor*)tintColorFor:(int)colorNumber;

+(void)drawGlossyBackground:(CGContextRef)context startColor:(UIColor *)color1 stopColor:(UIColor *)color2 addRect:(CGRect)rect colorSpaceRef:(CGColorSpaceRef)colorSpace isVertical:(BOOL)isVertical;


+(void)drawGradient:(CGContextRef)context startColor:(UIColor *)color1 stopColor:(UIColor *)color2 addRect:(CGRect)rect colorSpaceRef:(CGColorSpaceRef)colorSpace isVertical:(BOOL)isVertical;

+(void)drawBorder:(CGContextRef)context borderColor:(UIColor *)color1 addRect:(CGRect)rect colorSpaceRef:(CGColorSpaceRef)colorSpace;

+(UIColor*)greenTheme;

+(void)ColorTint:(CALayer*)layer forCustomColor:(UIColor*)color;
@end
