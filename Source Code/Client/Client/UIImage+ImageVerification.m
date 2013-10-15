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
//  UIImage+ImageVerification.m
//  StudentConnect
//
//  Created by Michael Montaque on 5/25/12.
//  Copyright (c) 2012 Florida International University. All rights reserved.
//
#define MAX_BYTE_SIZE  1500000   /* The Lower the number the faster the transfer speed */
#define DEFAULT_IMAGE @"Flow"

//main
#define BLK @"HDBlackBoard"
#define GRN @"HDGreenBoard"
#define WHT @"HDWhiteBoard"

//alternates
#define BLACK @"HDBlack"
#define GREEN @"HDGreen"
#define WHITE @"HDWhite"

#import "UIImage+ImageVerification.h"

@implementation UIImage (ImageVerification)

-(UIImage*)fixImageOrientation
{
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation)
    {
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
    }
    
    switch (self.imageOrientation)
    {
            case UIImageOrientationUp:
            case UIImageOrientationDown:
            case UIImageOrientationLeft:
            case UIImageOrientationRight:
            break;
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage),
                                             0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    
    switch (self.imageOrientation)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}



- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize
{
    UIImage *sourceImage = self;
    UIImage *newImage = nil;        
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) 
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor) 
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5; 
        }
        else
        {
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
    {
        NSLog(@"could not scale image");
    }
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark -
#pragma mark Private helper methods

// Returns an affine transform that takes into account the image orientation when drawing a scaled image
- (CGAffineTransform)transformForOrientation:(CGSize)newSize
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation)
    {
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
        
        case UIImageOrientationDown:           // EXIF = 3
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:           // EXIF = 6
        case UIImageOrientationLeftMirrored:   // EXIF = 5
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:          // EXIF = 8
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, 0, newSize.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
    }
    
    switch (self.imageOrientation)
    {
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
        case UIImageOrientationUpMirrored:     // EXIF = 2
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:   // EXIF = 5
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, newSize.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
    }
    
    return transform;
}


//Writes designated text to the given image
+(void)writeText:(NSString *)text toImageWithTextLayer:(UIImageView *)img
{
    BOOL shouldContinue=YES;
    
    for (CATextLayer* data in img.layer.sublayers)
    {
        if ([data.name isEqualToString:@"layer"])
        {
            [data setString:text];
            shouldContinue = NO;
        }
    }
    
    if (shouldContinue)
    {
        CATextLayer *textLayer = [[CATextLayer alloc]init];
        
        [textLayer setName:@"layer"];
        
        [textLayer setString:text];
        CGFloat width = img.frame.size.width;
        CGFloat height = img.frame.size.height;
        [textLayer setAlignmentMode:kCAAlignmentCenter];
        
        if (text.length == 1)
        {
            [textLayer setFontSize:height*.8];
        }
        else
        {
            [textLayer setFontSize:height*.65];
        }
        
        [textLayer setFrame:CGRectMake(0, height/5, width, height)];
        [img.layer addSublayer:textLayer];
    }
}

//saves the current image to document path
-(BOOL)saveCurrentImageToFileWithName:(NSString*)name
{
    NSData *imageData = UIImagePNGRepresentation(self);
    BOOL ok =[imageData writeToFile:name atomically:YES];
    
    if (!ok)
    {
        NSLog(@"Error creating file %@", name);
    }
    return ok;
}

//returns the image saved by the specified name
+(UIImage*)getSpecifiedImageFromFile:(NSString*)name
{
    NSData *pngData = [NSData dataWithContentsOfFile:name];
    return [UIImage imageWithData:pngData];
}

//returns where the image file is saved
+(NSString*)returnImagePathNameForName:(NSString*)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString * fileName = [NSString stringWithFormat:@"%@.png",name];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}

-(NSData *)convertImageToPNGBinaryData
{
    return UIImagePNGRepresentation(self);
}

+(BOOL)DeleteImage:(NSString*)name
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError* error = nil;
    
    return [fm removeItemAtPath:name error:&error];
}

-(NSData*)checkAndReducePictureSize
{
    NSData* newdata = UIImageJPEGRepresentation(self, 1);
    
    if (newdata.length > MAX_BYTE_SIZE)
    {
        NSLog(@"Orginal: %i \nReducing BLoB Size",newdata.length);
        NSData* compressed = UIImageJPEGRepresentation(self, .35);
        NSLog(@"Original: %i\n NEw BloB Size %i",newdata.length,compressed.length);

        return  compressed;
    }
    else
    {
        return newdata;
    }
}

- (UIImage*)scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), self.CGImage);
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

+(UIImage*)imageStyleForName:(NSString*)style
{
    if ([style isEqualToString:BLK])
    {
        return  [UIImage imageNamed:BLACK];
    }
    else if ([style isEqualToString:GRN])
    {
        return  [UIImage imageNamed:GREEN];
    }
    else
    {
        return  [UIImage imageNamed:WHITE];
    }
}

+(UIImage*)returnDefaultImage
{
    return [UIImage imageNamed:DEFAULT_IMAGE];
}
@end