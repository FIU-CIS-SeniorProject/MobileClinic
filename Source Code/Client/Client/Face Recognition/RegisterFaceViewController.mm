//
//  RegisterFaceViewController.mm
//  Mobile Clinic
//
//  Created by Humberto Suarez on 10/22/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//
#import "RegisterFaceViewController.h"
#import "DataR.h"
//#import "PatientObjectProtocol.h"
#import "MobileClinicFacade.h"
//#import "BaseObject+Protected.h"
//#import "BaseObject.h"
#import "Face.h"
//#import "DatabaseDriver.h"
//#import <CoreData/CoreData.h>
#import "FaceDetector.h"

@implementation RegisterFaceViewController

@synthesize firstName;
@synthesize familyName;
@synthesize label;

FaceDetector *faceDetector;
//int label;
NSManagedObjectContext* context;
NSDictionary* faceData;


- (void)viewDidLoad
{
    [super viewDidLoad];
    pictures = [[NSMutableArray alloc]init];
    
    
    faceDetector = [[FaceDetector alloc] init];
    
    
    NSString *instructions = @"Make sure %@ is holding the phone. "
    "When you are ready, press start. Or select images from your library.";
    //self.instructionsLabel.text = [NSString stringWithFormat:instructions, self.personName];
    
    [self setupCamera];
    
    /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Instructions"
     message:@"When the camera starts, move it around to show different angles of your face."
     delegate:nil
     cancelButtonTitle:@"OK"
     otherButtonTitles:nil];
     //[alert show];*/
     if (!faceData)
        faceData = [[NSMutableDictionary alloc]initWithCapacity:21];
    
}
- (void)viewDidUnload {
    
    [super viewDidUnload];
}


- (void)setupCamera
{
   
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView: self.imageView];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
    //[self.videoCamera start];
}
//#pragma mark - Protocol CvVideoCameraDelegate

- (void)processImage:(cv::Mat&)image
{
    
    // Only process every 60th frame (every 2s)
    if (self.frameNum == 10) {
        [self parseFaces:[faceDetector facesFromImage:image] forImage:image];
        
        self.frameNum = 1;
    }
    else {
        self.frameNum++;
    }
}

- (void)parseFaces:(const std::vector<cv::Rect> &)faces forImage:(cv::Mat&)image
{
    if (![self learnFace:faces forImage:image]) {
        return;
    };
    
    self.numPicsTaken++;
    NSLog(@"number %@",USERID);
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self highlightFace:[DataR faceToCGRect:faces[0]]];
        //self.instructionsLabel.text = [NSString stringWithFormat:@"Taken %d of 10", self.numPicsTaken];
        
        if (self.numPicsTaken == 20) {
            self.featureLayer.hidden = YES;
            [self.videoCamera stop];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Done"
                                                            message:@"20 picture have been taken."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    });
    
}
- (void) deleteAllWithFirstName: (NSString*)fName forFamilyName:(NSString*)lName
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Faces" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"firstName ==nil AND familyName == nil"];
    
    //fetchRequest.predicate = [NSPredicate predicateWithFormat:@"firstName == %@ AND familyName == %@",fName,lName];
    
    NSError *error;
    NSArray *listToBeDeleted = [context executeFetchRequest:fetchRequest error:&error];
    
    for(Face *c in listToBeDeleted)
    {
        [context deleteObject:c];
    }
    error = nil;
    [context save:&error];
}
- (bool)learnFace:(const std::vector<cv::Rect> &)faces forImage:(cv::Mat&)image
{
    //Face *fac = [[Face alloc]init];
    if (faces.size() != 1) {
        [self noFaceToDisplay];
        return NO;
    }
    
    // We only care about the first face
    cv::Rect face = faces[0];
    
    // Learn it
    
    NSLog(@"PERSON ID = %d",label.intValue);
    cv::Mat faceData1 = [self pullStandardizedFace:face fromImage:image];
    NSData *serialized = [DataR serializeCvMat:faceData1];
    NSString *patientId;
    patientId = [NSString stringWithFormat:@"%f",[[NSDate date]timeIntervalSince1970]];
    //[faceData setValue:@"quevola" forKey:@"personId"];

   // [faceData setValue:[NSNumber numberWithInt:fac->CLASSTYPE] forKey:OBJECTTYPE];
    //[faceData setValue:[NSNumber numberWithInt:fac->commands] forKey:OBJECTCOMMAND];
    [pictures addObject:serialized];
    
    //if(self.numPicsTaken == 19) {
    [faceData setValue:serialized forKey:@"photo"];
    [faceData setValue:label forKey:@"label"];
    [faceData setValue:firstName forKey:@"firstName"];
    [faceData setValue:familyName forKey:@"familyName"];
    [faceData setValue:patientId  forKey:PATIENTID];
     MobileClinicFacade* mobileFacade = [[MobileClinicFacade alloc]init];
    
    [mobileFacade createAndCheckInFace:faceData onCompletion:^(NSDictionary *object, NSError *error) {
    
        if(object)
            NSLog(@"there is an objet");
        else
                  NSLog(@"there is no object");
    }];//}
    /*BaseObject *obj =[[BaseObject alloc] init];
    
    [obj tryAndSendData:faceData withErrorToFire:^(id<BaseObjectProtocol> data, NSError *error) {
        
    } andWithPositiveResponse:^(id data) {
        
    }];*/


    //[self.faceRecognizer learnFace:face ofPersonName:[self.personName uppercaseString] fromImage:image];
    
    return YES;
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
        self.featureLayer.hidden = YES;
    });
}

- (void)highlightFace:(CGRect)faceRect
{
    if (self.featureLayer == nil) {
        self.featureLayer = [[CALayer alloc] init];
        self.featureLayer.borderColor = [[UIColor redColor] CGColor];
        self.featureLayer.borderWidth = 4.0;
        [self.imageView.layer addSublayer:self.featureLayer];
    }
    
    self.featureLayer.hidden = NO;
    self.featureLayer.frame = faceRect;
}

- (IBAction)cameraButtonClicked:(id)sender
{
    
   /* NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSNumber *timeStampObj = [NSNumber numberWithDouble: timeStamp];
    self.label =timeStampObj;*/
    
    [self deleteAllWithFirstName:firstName forFamilyName:familyName];
    
    //[_nameField resignFirstResponder];
    if (self.videoCamera.running){
        self.switchCameraButton.hidden = YES;
        
        [self.Register setTitle:@"Register" forState:UIControlStateNormal];
        self.featureLayer.hidden = YES;
        
        [self.videoCamera stop];
        
        //self.instructionsLabel.text = [NSString stringWithFormat:@"Make sure %@ is holding the phone. When you are ready, press start. Or select images from your library.", self.personName];
        
    } else {
        self.imageScrollView.hidden = YES;
        
        [self.Register setTitle:@"Stop" forState:UIControlStateNormal];
        self.switchCameraButton.hidden = NO;
       
        // First, forget all previous pictures of this person
        //[self.faceRecognizer forgetAllFacesForPersonID:[self.personID integerValue]];
        
        // Reset the counter, start taking pictures
        self.numPicsTaken = 0;
        [self.videoCamera start];
        
        //self.instructionsLabel.text = @"Taking pictures...";
    }
}


- (IBAction)switchCameraButtonClicked:(id)sender
{
    [self.videoCamera stop];
    
    if (self.videoCamera.defaultAVCaptureDevicePosition == AVCaptureDevicePositionFront) {
        self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    } else {
        self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    }
    
    [self.videoCamera start];
}

- (IBAction)savePerson:(id)sender
{
    //FaceRecognizer *faceRecognizer = [[FaceRecognizer alloc] init];
    //[faceRecognizer newPersonWithName:self.nameField.text];
    
    /*[self.navigationController popViewControllerAnimated:YES];*/
}

@end

