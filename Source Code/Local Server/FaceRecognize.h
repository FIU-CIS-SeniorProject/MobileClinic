//
//  FaceRecognize.h
//  Mobile Clinic
//
//  Created by Humberto Suarez on 11/11/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <opencv2/highgui/highgui_c.h>

#import <opencv2/opencv.hpp>
//#import <opencv2/highgui/highgui.hpp>
//#import <sqlite3.h>
#import "DatabaseProtocol.h"

@interface FaceRecognize : NSObject
{
    cv::Ptr<cv::FaceRecognizer> _model;
}

@property(nonatomic, strong) id<DatabaseProtocol> database;



- (id)initWithEigenFaceRecognizer;
- (id)initWithFisherFaceRecognizer;
- (id)initWithLBPHFaceRecognizer;
- (int)newPersonWithName:(NSString *)name;
- (NSMutableArray *)getAllPeople;
- (BOOL)trainModel;
- (void)forgetAllFacesForPersonID:(int)personID;
- (void)learnFace:(cv::Rect)face ofPersonName:(NSString *)name fromImage:(cv::Mat&)image; //ofPersonID:(int)personID fromImage:(cv::Mat&)image;
- (cv::Mat)pullStandardizedFace:(cv::Rect)face fromImage:(cv::Mat&)image;
- (NSDictionary *)recognizeFace:(cv::Mat)face;

@end