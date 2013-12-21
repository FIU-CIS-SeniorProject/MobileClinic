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
//  RegisterFaceViewController.h
//  Mobile Clinic
//
//  Created by Humberto Suarez on 10/22/13.
//

#import <UIKit/UIKit.h>
#import <opencv2/highgui/cap_ios.h>
//#import "FaceDetector.h"
//#import "FaceRecognizer.h"
//#import "DatabaseProtocol.h"
#import <Foundation/Foundation.h>

@protocol faceViewDelegate <NSObject>

- (void)addItemViewController:(id)controller didFinishEnteringItem:( UIImage*)item;

@end


@interface RegisterFaceViewController : UIViewController <CvVideoCameraDelegate>
{
    NSMutableArray *pictures;
     UIImage *previousImage;
    
}
//@property(nonatomic, strong) id<DatabaseProtocol> database;


- (IBAction)savePerson:(id)sender;

@property (nonatomic, assign) id <faceViewDelegate> delegate1;
@property (weak, nonatomic) IBOutlet UIButton *Register;
@property (strong, nonatomic) IBOutlet UIButton *switchCameraButton;
@property (nonatomic, strong) IBOutlet UIImageView * imageView;
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *familyNameField;

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *familyName;
@property (nonatomic,strong) NSNumber *label;
@property (strong, nonatomic) NSMutableDictionary * fData;

//@property (nonatomic, strong) FaceDetector *faceDetector;
//@property (nonatomic, strong) FaceRecognizer *faceRecognizer;
@property (nonatomic, strong) CvVideoCamera* videoCamera;
@property (nonatomic, strong) CALayer *featureLayer;
@property (nonatomic) NSInteger frameNum;
@property (nonatomic) NSInteger numPicsTaken;
@property (strong, nonatomic) IBOutlet UIScrollView *imageScrollView;

- (IBAction)cameraButtonClicked:(id)sender;
- (IBAction)switchCameraButtonClicked:(id)sender;
//-(UIImage *)imageWithCVMat:(const cv::Mat&)cvMat;


@end

