//
//  UIImage+ImageVerification.h
//  StudentConnect
//
//  Created by Michael Montaque on 5/25/12.
//  Copyright (c) 2012 Florida International University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface UIImage (ImageVerification)
-(UIImage*)fixImageOrientation;
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;


+ (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSize:(CGSize)newSize;

- (CGAffineTransform)transformForOrientation:(CGSize)newSize;



+(void)writeText:(NSString*)text toImageWithTextLayer:(UIImageView*)img;

-(BOOL)saveCurrentImageToFileWithName:(NSString*)name;
-(NSData*)convertImageToPNGBinaryData;
-(UIImage*)scaleToSize:(CGSize)size;
+(UIImage*)getSpecifiedImageFromFile:(NSString*)name;
+(NSString*)returnImagePathNameForName:(NSString*)name;
+(BOOL)DeleteImage:(NSString*)name;
-(NSData*)checkAndReducePictureSize;
+(UIImage*)returnDefaultImage;
+(UIImage*)imageStyleForName:(NSString*)style;
@end
