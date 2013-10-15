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
//  ColorMe.m
//  OmniOrganize
//
//  Created by Michael Montaque on 1/11/12.
//  Copyright (c) 2012 Florida International University. All rights reserved.
//
#define GRADIENT @"shadow_Gradient"
#define GRADIENT_NAME @"GradientBlack"
#import "ColorMe.h"

@implementation ColorMe

+(UIColor*)colorFor:(int)colorNumber
{
    UIColor *color;
    switch (colorNumber)
    {
        case 0:
            //FireBrick Red
            color = [UIColor colorWithRed:255.0/255.0 green:48.0/255.0 blue:48.0/255.0 alpha:1];
            break;
        case 1:
            //Light GoldenRod 255;236;139
            color = [UIColor colorWithRed:255.0/255.0 green:236.0/255.0 blue:139.0/255.0 alpha:1];
            break;
        case 2:
            //Sky Blue 135;206;255
            color = [UIColor colorWithRed:135.0/255 green:206.0/255 blue:255.0/255 alpha:1];
            break;
        case 3:
            //Spring Green 0;255;127
            color = [UIColor colorWithRed:0 green:255.0/255 blue:127.0/255 alpha:1];
            break;
        case 4:
            // Medium Purple 171;130;255
            color = [UIColor colorWithRed:171.0/255.0 green:130.0/255.0 blue:255.0/255.0 alpha:1];
            break;
        case 5:
            // dark Green
            color = [UIColor colorWithRed:47.0/255.0 green:85.0/255.0 blue:60.0/255.0 alpha:1];
            break;
        case 6:
            //Pink
            color = [UIColor colorWithRed:255.0/255.0 green:140.0/255 blue:232.0/244 alpha:1];
            break;
        case 7:
            // Orange
            color = [UIColor colorWithRed:255.0/255.0 green:160.0/255.0 blue:30.0/255.0 alpha:1];
            break;
        case 8:
            // Deep Blue
            color = [UIColor colorWithRed:0.0/255.0 green:105.0/255.0 blue:255.0/255.0 alpha:1];
            break;
        case 9:
            //Sky Blue compliment 135;206;255
            color = [UIColor colorWithRed:30.0/255 green:144.0/255 blue:255.0/255 alpha:1];
            break;
        case 10:
            //Gainsboro Grey
            color = [UIColor colorWithRed:255.0/255 green:250.0/255 blue:250.0/255 alpha:1];
            break;
        case 11:
            //White Smoke 
            color = [UIColor colorWithRed:245.0/255 green:245.0/255 blue:245.0/255 alpha:1];
            break;
        case 12:
            // lightGray
            color = [UIColor colorWithWhite:.8 alpha:.5];
            break;
        case 13:
            // MC - Orange
            color = [UIColor colorWithRed:232.0/255 green:151.0/255 blue:98.0/255 alpha:1.0];
            break;
        case 14:
            // MC - Blue
            color = [UIColor colorWithRed:111.0/255 green:146.0/255 blue:225.0/255 alpha:1.0];
            break;
        case 15:
            // MC - Green
            color = [UIColor colorWithRed:117.0/255 green:205.0/255 blue:142.0/255 alpha:1.0];
            break;
        default:
            //Clear (reflects grey color)
            color = [UIColor clearColor];
            break;
    }
    return color;
}

+(UIColor*)tintColorFor:(int)colorNumber
{
    UIColor *color;
    switch (colorNumber)
    {
        case 0:
            //FireBrick Red
            color = [UIColor colorWithRed:255.0/255.0 green:48.0/255.0 blue:48.0/255.0 alpha:.5];
            break;
        case 1:
            //Light GoldenRod 255;236;139
            color = [UIColor colorWithRed:255.0/255.0 green:236.0/255.0 blue:139.0/255.0 alpha:.5];
            break;
        case 2:
            //Sky Blue 135;206;255
            color = [UIColor colorWithRed:135.0/255 green:206.0/255 blue:255.0/255 alpha:.5];
            break;
        case 3:
            //Spring Green 0;255;127
            color = [UIColor colorWithRed:0 green:255.0/255 blue:127.0/255 alpha:.5];
            break;
        case 4:
            // Medium Purple 171;130;255
            color = [UIColor colorWithRed:171.0/255.0 green:130.0/255.0 blue:255.0/255.0 alpha:.5];
            break;
        case 5:
            // dark Green
            color = [UIColor colorWithRed:47.0/255.0 green:85.0/255.0 blue:60.0/255.0 alpha:.5];
            break;
        case 6:
            //Pink
            color = [UIColor colorWithRed:255.0/255.0 green:140.0/255 blue:232.0/244 alpha:.5];
            break;
        case 7:
            // Orange
            color = [UIColor colorWithRed:255.0/255.0 green:160.0/255.0 blue:30.0/255.0 alpha:.5];
            break;
        case 8:
            // Deep Blue
            color = [UIColor colorWithRed:0.0/255.0 green:105.0/255.0 blue:255.0/255.0 alpha:.5];
            break; 
        case 9:
            //Sky Blue compliment 135;206;255
            color = [UIColor colorWithRed:30.0/255 green:144.0/255 blue:255.0/255 alpha:.5];
            break;
        case 10:
            //Gainsboro Grey
            color = [UIColor colorWithRed:255.0/255 green:250.0/255 blue:250.0/255 alpha:.5];
            break;
        case 11:
            //White Smoke
            color = [UIColor colorWithRed:245.0/255 green:245.0/255 blue:245.0/255 alpha:.5];
        case 12:
            // lightGray
            color = [UIColor colorWithWhite:.8 alpha:.5];
            break;
        case 13:
            // MC - Orange
            color = [UIColor colorWithRed:232.0/255 green:151.0/255 blue:98.0/255 alpha:1.0];
            break;
        case 14:
            // MC - Blue
            color = [UIColor colorWithRed:111.0/255 green:146.0/255 blue:225.0/255 alpha:1.0];
            break;
        case 15:
            // MC - Green
            color = [UIColor colorWithRed:117.0/255 green:205.0/255 blue:142.0/255 alpha:1.0];
            break;
        default:
            //Clear (reflects grey color)
            color = [UIColor clearColor];
            break;
    }
    return color;
}

+(void)coloreMeCompletely:(CALayer*)layer andColor:(int)colorNumber
{
    [layer setBackgroundColor:[self colorFor:colorNumber].CGColor];
}

+(void)ColorTint:(CALayer*)layer forCustomColor:(UIColor*)color
{
    [layer setBackgroundColor:color.CGColor];
}

+(void)coloreTint:(CALayer*)layer andColor:(int)colorNumber
{
     [layer setBackgroundColor:[self tintColorFor:colorNumber].CGColor];
}

+(void)addRoundedBlackBorderWithShadowInRect:(CALayer*)layer
{
    [self addRoundedEdges:layer];
    [self addBorder:layer withWidth:1 withColor:[UIColor blackColor]];
    [self addShadowLayer:layer];
}

+(void)addBorder:(CALayer*)layer withWidth:(CGFloat)width withColor:(UIColor *)color
{
    [layer setBorderColor:color.CGColor];
    [layer setBorderWidth:width];
}

+(void)addRoundedEdges:(CALayer*)layer
{
    layer.cornerRadius = 7.0;
    layer.masksToBounds = YES;
}

+(void)addTopRoundedEdges:(CALayer*)layer
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:layer.bounds byRoundingCorners:UIRectCornerTopLeft cornerRadii:CGSizeMake(5.0, 5.0)];
    
    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = layer.bounds;
    maskLayer.path = maskPath.CGPath;
    
    [layer setMask:maskLayer];
    //layer.masksToBounds = YES;
}
   
+(void)addShadowLayer:(CALayer*)layer
{
    [layer setShadowColor:[[UIColor blackColor]CGColor]];
    [layer setShadowOffset:CGSizeMake(3, 3)];
    [layer setShadowOpacity:.8];
    [layer setShadowRadius:3];
}

+(void)drawGradient:(CGContextRef)context startColor:(UIColor *)color1 stopColor:(UIColor *)color2 addRect:(CGRect)rect colorSpaceRef:(CGColorSpaceRef)colorSpace isVertical:(BOOL)isVertical
{
    CGFloat locations[] = { 0.0, 0.3, 0.6, 1.0};
    NSArray *colors = [NSArray arrayWithObjects:(id)[color1 CGColor], (id)[color2 CGColor],(id)[color2 CGColor],(id)[color1 CGColor], nil];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace,(__bridge CFArrayRef) colors, locations);
    CGPoint startPoint;
    CGPoint endPoint;
    
    if(isVertical)
    {
        startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMidY(rect));
        endPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMidY(rect));
    }
    else
    {
        startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
        endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    }
    
    CGContextSaveGState(context);

    CGContextAddRect(context, rect);
    CGContextClip(context);
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

+(void)drawGlossyBackground:(CGContextRef)context startColor:(UIColor *)color1 stopColor:(UIColor *)color2 addRect:(CGRect)rect colorSpaceRef:(CGColorSpaceRef)colorSpace isVertical:(BOOL)isVertical
{
    [self drawGradient:context startColor:color1 stopColor:color2 addRect:rect colorSpaceRef:colorSpace isVertical:isVertical];
    
    UIColor* glossColor1 = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.45];
    UIColor* glossColor2 = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.20];
    
    CGRect topHalf = CGRectMake(rect.origin.x, rect.origin.y,rect.size.width, rect.size.height/2);
    [self drawGradient:context startColor:glossColor1 stopColor:glossColor2 addRect:topHalf colorSpaceRef:colorSpace isVertical:isVertical];
}

+(UIColor*)whitishColor
{
    return [UIColor colorWithRed:250.0/255 green:250.0/255 blue:250.0/255 alpha:.5];
}

+(UIColor*)grayishColor
{
    return [UIColor colorWithRed:180.0/255 green:180.0/255 blue:180.0/255 alpha:.5];
}

+(void)drawBorder:(CGContextRef)context borderColor:(UIColor *)color1 addRect:(CGRect)rect colorSpaceRef:(CGColorSpaceRef)colorSpace
{
    //Rounded Path   
    //UIBezierPath *roundEdge = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(30, 30)];
    // [roundEdge addClip];
    //add stroke
    CGContextSetStrokeColorWithColor(context, color1.CGColor);
    CGContextSetLineWidth(context, 3);
    CGContextStrokeRect(context, rect);
}

-(void)setColor:(int)myColor
{
    pickedColor = myColor;
}

-(UIColor *)useSelectedColor
{
    return  [ColorMe colorFor:pickedColor];
}

-(int)selectedColor
{
    return pickedColor;
}

+(UIColor*)greenTheme
{
    return [UIColor colorWithRed:5.0/255 green:85.0/255 blue:85.0/255 alpha:1];
}

+(void)addFadeGradientToLayer:(CALayer*)layer
{
    for (CALayer* all in layer.sublayers)
    {
        if ([all.name isEqualToString:GRADIENT])
        {
            return;
        }
    }
    
    CALayer* gradient = [[CALayer alloc]init];
    
    [gradient setFrame:layer.frame];
    [gradient setName:GRADIENT];
    
    UIImage* image =  [[UIImage imageNamed:GRADIENT_NAME] imageByScalingAndCroppingForSize:layer.frame.size];
    
    [gradient setBackgroundColor:[UIColor colorWithPatternImage:image].CGColor];

    [layer addSublayer:gradient];
    [UIView animateWithDuration:1 animations:^{ }];
}
@end