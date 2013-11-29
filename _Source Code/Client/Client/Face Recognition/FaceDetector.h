//
//  FaceDetector.h
//  Mobile Clinic
//
//  Created by Humberto Suarez on 10/22/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <opencv2/highgui/cap_ios.h>

@interface FaceDetector : NSObject
{
   cv::CascadeClassifier _faceCascade;
}

- (std::vector<cv::Rect>)facesFromImage:(cv::Mat&)image;

@end