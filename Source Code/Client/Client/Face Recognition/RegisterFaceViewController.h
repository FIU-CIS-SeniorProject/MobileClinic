//
//  RegisterFaceViewController.h
//  Mobile Clinic
//
//  Created by Humberto Suarez on 10/22/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/highgui/cap_ios.h>
#import "FaceDetector.h"
//#import "FaceRecognizer.h"
#import "DatabaseProtocol.h"

@interface RegisterFaceViewController : UIViewController <CvVideoCameraDelegate>
@property(nonatomic, strong) id<DatabaseProtocol> database;


- (IBAction)savePerson:(id)sender;


@property (weak, nonatomic) IBOutlet UIButton *Register;
@property (strong, nonatomic) IBOutlet UIButton *switchCameraButton;
@property (nonatomic, strong) IBOutlet UIImageView * imageView;
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *familyNameField;

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *familyName;

@property (nonatomic, strong) FaceDetector *faceDetector;
//@property (nonatomic, strong) FaceRecognizer *faceRecognizer;
@property (nonatomic, strong) CvVideoCamera* videoCamera;
@property (nonatomic, strong) CALayer *featureLayer;
@property (nonatomic) NSInteger frameNum;
@property (nonatomic) NSInteger numPicsTaken;
@property (strong, nonatomic) IBOutlet UIScrollView *imageScrollView;

- (IBAction)cameraButtonClicked:(id)sender;
- (IBAction)switchCameraButtonClicked:(id)sender;
-(UIImage *)imageWithCVMat:(const cv::Mat&)cvMat;


@end

