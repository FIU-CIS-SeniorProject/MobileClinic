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
//  ColorMe.h
//  OmniOrganize
//
//  Created by Michael Montaque on 1/11/12.
//
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "UIImage+ImageVerification.h"

@interface ColorMe : NSObject
{
    int pickedColor;
}

-(int)selectedColor;
-(UIColor*)useSelectedColor;
-(void)setColor:(int)myColor;

+(void)addGradientToLayer:(CALayer*)layer colorOne:(UIColor*)colorOne andColorTwo:(UIColor*)colorTwo inFrame:(CGRect)rect;
+(UIColor*)lightGray;
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
