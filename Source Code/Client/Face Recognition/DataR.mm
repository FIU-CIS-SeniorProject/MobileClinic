//
//  DataR.mm
//  Mobile Clinic
//
//  Created by Humberto Suarez on 10/22/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import "DataR.h"

@implementation DataR

+ (NSData *)serializeCvMat:(cv::Mat&)cvMat
{
    return [[NSData alloc] initWithBytes:cvMat.data length:cvMat.elemSize() * cvMat.total()];
}

+ (cv::Mat)dataToMat:(NSData *)data width:(NSNumber *)width height:(NSNumber *)height
{
    cv::Mat output = cv::Mat([width integerValue], [height integerValue], CV_8UC1);
    output.data = (unsigned char*)data.bytes;
    
    return output;
}

+ (CGRect)faceToCGRect:(cv::Rect)face
{
    CGRect faceRect;
    faceRect.origin.x = face.x*2.7;
    faceRect.origin.y = face.y*2;
    faceRect.size.width = face.width*2.5;
    faceRect.size.height = face.height*2.5;
    
    return faceRect;
}

+ (UIImage *)UIImageFromMat:(cv::Mat)image
{
    NSData *data = [NSData dataWithBytes:image.data length:image.elemSize()*image.total()];
    CGColorSpaceRef colorSpace;
    
    if (image.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
      }
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    CGImageRef imageRef = CGImageCreate(
                                        image.cols,                                 //width
                                        image.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * image.elemSize(),                       //bits per pixel
                                        image.step.p[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    // Create UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

+ (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    return [DataR cvMatFromUIImage:image usingColorSpace:CV_RGB2GRAY];
}

+ (cv::Mat)cvMatFromUIImage:(UIImage *)image usingColorSpace:(int)outputSpace
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4);
    
    CGContextRef contextRef = CGBitmapContextCreate(
                                                    cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast|kCGBitmapByteOrderDefault // Bitmap info flags
                                                    );
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    cv::Mat finalOutput;
    cvtColor(cvMat, finalOutput, outputSpace);
    
    return finalOutput;
}

@end
