//
//  FRViewController.mm
//  Mobile Clinic
//
//  Created by Humberto Suarez on 10/22/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import "FRViewController.h"
#import "DataR.h"
#import "MobileClinicFacade.h"
#import "SearchPatientViewController.h"
#import "RegisterPatientViewController.h"
#define CAPTURE_FPS 30


@interface FRViewController ()
- (IBAction)switchCameraClicked:(id)sender;

@end

@implementation FRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setupCamera];
    self.faceDetector = [[FaceDetector alloc] init];
    //self.faceRecognizer = [[FaceRecognizer alloc] initWithEigenFaceRecognizer];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.videoCamera start];
    // Re-train the model in case more pictures were added
    //self.modelAvailable = [self.faceRecognizer trainModel];
    //if (!self.modelAvailable) {
      //  self.instructionLabel.text = @"Add people in the database first";
    //}
    

}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.videoCamera stop];
}

- (void)setupCamera
{
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.imageView];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = CAPTURE_FPS;
    self.videoCamera.grayscaleMode = NO;
}

#pragma mark - Protocol CvVideoCameraDelegate



- (void)processImage:(cv::Mat&)image
{
    // Only process every CAPTURE_FPS'th frame (every 1s)
    if (self.frameNum == CAPTURE_FPS) {
        [self parseFaces:[self.faceDetector facesFromImage:image] forImage:image];
        self.frameNum = 0;
    }
    
    self.frameNum++;
}

- (void)parseFaces:(const std::vector<cv::Rect> &)faces forImage:(cv::Mat&)image
{
    NSDictionary* faceData = [[NSMutableDictionary alloc]init];
    // No faces found
    if (faces.size() != 1) {
        [self noFaceToDisplay];
        return;
    }
    
    // We only care about the first face
    cv::Rect face = faces[0];
    
    // By default highlight the face in red, no match found
    CGColor *highlightColor = [[UIColor redColor] CGColor];
    NSString *message = @"No match found";
    NSString *confidence = @"";
    
    cv::Mat faceData1 = [self pullStandardizedFace:face fromImage:image];
    NSData *serialized = [DataR serializeCvMat:faceData1];
    MobileClinicFacade* mobileFacade = [[MobileClinicFacade alloc]init];
    
    
    [faceData setValue:serialized forKey:@"photo"];
    [mobileFacade findPatientFace:faceData AndOnCompletion:^(NSArray *allObjectsFromSearch, NSError *error)
    {
        if (allObjectsFromSearch) {
            RegisterPatientViewController* registerPatientViewController = [self getViewControllerFromiPadStoryboardWithName:@"registerPatientViewController"];
            [registerPatientViewController view];
            [registerPatientViewController setPatientArray:[NSArray arrayWithArray:allObjectsFromSearch]];
            [registerPatientViewController.searchResultTableView reloadData];
            [self.navigationController pushViewController:registerPatientViewController animated:YES];
            
            NSLog(@"IM finally heereeeeeeeee");
           //  NSDictionary* patient = [NSMutableDictionary dictionaryWithDictionary:[allObjectsFromSearch objectAtIndex:indexPath.row]];
            // Redisplay the information
         //   [_searchResultTableView reloadData];
            
          //  [FIUAppDelegate getNotificationWithColor:AJNotificationTypeBlue Animation:AJLinedBackgroundTypeAnimated WithMessage:error.localizedDescription inView:self.view];
        }else{
           // [FIUAppDelegate getNotificationWithColor:AJNotificationTypeRed Animation:AJLinedBackgroundTypeAnimated WithMessage:error.localizedDescription inView:self.view];
        }
        /** This will remove the HUD since the search is complete */
     
        
    }];
    //[self HideALLHUDDisplayInView:_searchResultTableView];
    // Unless the database is empty, try a match
    /*if (self.modelAvailable) {
        NSDictionary *match = [self.faceRecognizer recognizeFace:face inImage:image];
        
        // Match found
        if ([match objectForKey:@"personID"] != [NSNumber numberWithInt:-1]) {
            //[self.videoCamera stop];
            message =  [match objectForKey:@"firstName"] ;
            highlightColor = [[UIColor greenColor] CGColor];
            
            NSNumberFormatter *confidenceFormatter = [[NSNumberFormatter alloc] init];
            [confidenceFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
            confidenceFormatter.maximumFractionDigits = 2;
            
            confidence = [NSString stringWithFormat:@"Confidence: %@",
                          [confidenceFormatter stringFromNumber:[match objectForKey:@"confidence"]]];
        }
    }*/
    
    // All changes to the UI have to happen on the main thread
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.instructionLabel.text = message;
        self.confidenceLabel.text = confidence;
        
        [self highlightFace:[DataR  faceToCGRect:face] withColor:highlightColor];
    });
}
- (cv::Mat)pullStandardizedFace:(cv::Rect)face fromImage:(cv::Mat&)image
{
        // Pull the grayscale face ROI out of the captured image
        cv::Mat onlyTheFace;
        cv::cvtColor(image(face), onlyTheFace, CV_RGB2GRAY);
        // Standardize the face to 100x100 pixels
        cv::resize(onlyTheFace, onlyTheFace, cv::Size(100, 100), 0, 0);
        return onlyTheFace;
}

- (void)noFaceToDisplay
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.instructionLabel.text = @"No face in image";
        self.confidenceLabel.text = @"";
        self.featureLayer.hidden = YES;
    });
}

- (void)highlightFace:(CGRect)faceRect withColor:(CGColor *)color
{
    if (self.featureLayer == nil) {
        self.featureLayer = [[CALayer alloc] init];
        self.featureLayer.borderWidth = 4.0;
    }
    
    [self.imageView.layer addSublayer:self.featureLayer];
    
    
    self.featureLayer.hidden = NO;
    self.featureLayer.borderColor = color;
    self.featureLayer.frame = faceRect;
}

- (IBAction)switchCameraClicked:(id)sender {
    [self.videoCamera stop];
    
    if (self.videoCamera.defaultAVCaptureDevicePosition == AVCaptureDevicePositionFront) {
        self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    } else {
        self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    }
    
    [self.videoCamera start];
}
@end
