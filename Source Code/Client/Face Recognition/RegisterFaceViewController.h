//
//  RegisterFaceViewController.h
//  Mobile Clinic
//
//  Created by Humberto Suarez on 10/22/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/highgui/cap_ios.h>
//#import "FaceDetector.h"
//#import "FaceRecognizer.h"
//#import "DatabaseProtocol.h"
//#import "RegisterPatientViewController.h"
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

