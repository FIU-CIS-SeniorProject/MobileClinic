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
//  FRViewController.mm
//  Mobile Clinic
//
//  Created by Humberto Suarez on 10/22/13.
//

#import "FRViewController.h"
#import "DataR.h"
#import "MobileClinicFacade.h"
#import "SearchPatientViewController.h"
#import "RegisterPatientViewController.h"
#import "Face.h"
#import "Database.h"

#define CAPTURE_FPS 30


@interface FRViewController ()
- (IBAction)switchCameraClicked:(id)sender;

@end

@implementation FRViewController
@synthesize database;
int count =0;
RegisterPatientViewController* registerPatientViewController;
NSManagedObjectContext* context2;
- (void)viewDidLoad
{
    [super viewDidLoad];
    database = [Database sharedInstance];
    context2 = database.managedObjectContext;
	[self setupCamera];
    self.faceDetector = [[FaceDetector alloc] init];
    //self.faceRecognizer = [[FaceRecognizer alloc] initWithEigenFaceRecognizer];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[self.videoCamera start];
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
    self.frameNum =0;
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
    /*if (self.frameNum == 60)
    {
        [self.videoCamera stop];
        registerPatientViewController = [self getViewControllerFromiPadStoryboardWithName:@"registerPatientViewController"];
        [registerPatientViewController view];
        [registerPatientViewController setPatientArray:nil];
        //[registerPatientViewController setPatientArray:[NSArray arrayWithArray:allObjectsFromSearch1]];
        [registerPatientViewController.searchResultTableView reloadData];
        [self.navigationController pushViewController:registerPatientViewController animated:YES];
        self.frameNum =0;
    }*/
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
    
    NSLog(@"count = %i",count);
    [faceData setValue:serialized forKey:@"photo"];
    
    [mobileFacade findPatientFace:faceData AndOnCompletion:^(NSArray *allObjectsFromSearch, NSError *error)
    {
        if (allObjectsFromSearch) {
            if(allObjectsFromSearch.count>0)
            {
                NSDictionary* pat = [NSMutableDictionary dictionaryWithDictionary:[allObjectsFromSearch objectAtIndex:0]];
                NSString *fname = [pat objectForKey:@"firstName"];
                NSNumber *label = [pat objectForKey:@"label"];
                NSString *lname = [pat objectForKey:@"familyName"];
                if([fname length] != 0 && [lname length]!=0 ){
                
                    //[mobileFacade findPatientWithFirstName:fname orLastName:lname onCompletion:^(NSArray *allObjectsFromSearch1, NSError *error)
                 [mobileFacade findPatientWithLabel:label onCompletion:^(NSArray *allObjectsFromSearch1, NSError *error)
                    {
                     if(allObjectsFromSearch1){
                     registerPatientViewController = [self getViewControllerFromiPadStoryboardWithName:@"registerPatientViewController"];
                     [registerPatientViewController view];
                     [registerPatientViewController setPatientArray:nil];
                     [registerPatientViewController setPatientArray:[NSArray arrayWithArray:allObjectsFromSearch1]];
                     [registerPatientViewController.searchResultTableView reloadData];
                     [self.navigationController pushViewController:registerPatientViewController animated:YES];
                     self.frameNum =0;
                     NSLog(@"IM finally heereeeeeeeee2");
                     }
                     else
                         NSLog(@"IM finally heereeeeeeeee10");
                 }];}
            }
            registerPatientViewController = [self getViewControllerFromiPadStoryboardWithName:@"registerPatientViewController"];
            [registerPatientViewController view];
            [registerPatientViewController setPatientArray:nil];
            //[registerPatientViewController setPatientArray:[NSArray arrayWithArray:allObjectsFromSearch1]];
            [registerPatientViewController.searchResultTableView reloadData];
            [self.navigationController pushViewController:registerPatientViewController animated:YES];
            self.frameNum =0;
     
            NSLog(@"IM finally heereeeeeeeee1");
     
        }else{
            registerPatientViewController = [self getViewControllerFromiPadStoryboardWithName:@"registerPatientViewController"];
            [registerPatientViewController view];
            [registerPatientViewController setPatientArray:nil];
            //[registerPatientViewController setPatientArray:[NSArray arrayWithArray:allObjectsFromSearch1]];
            [registerPatientViewController.searchResultTableView reloadData];
            [self.navigationController pushViewController:registerPatientViewController animated:YES];
            self.frameNum =0;
            NSLog(@"IM finally heereeeeeeeee");
        }
        /** This will remove the HUD since the search is complete */
     
        
    }];
    [self deleteAllFromDatabase];
    
    

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
        
        //[self highlightFace:[DataR  faceToCGRect:face] withColor:highlightColor];
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
- (void) deleteAllFromDatabase
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Faces" inManagedObjectContext:context2];
    [fetchRequest setEntity:entity];
    //fetchRequest.predicate = [NSPredicate predicateWithFormat:@"firstName ==nil AND familyName == nil"];
    
    //fetchRequest.predicate = [NSPredicate predicateWithFormat:@"firstName == %@ AND familyName == %@",fName,lName];
    
    NSError *error;
    NSArray *listToBeDeleted = [context2 executeFetchRequest:fetchRequest error:&error];
    
    for(Face *c in listToBeDeleted)
    {
        [context2 deleteObject:c];
    }
    error = nil;
    [context2 save:&error];
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
