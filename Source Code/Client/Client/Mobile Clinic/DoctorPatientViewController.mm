//
//  DoctorPatientViewController.m
//  Mobile Clinic
//
//  Created by sebastian a zanlongo on 2/18/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//
#import "DoctorPatientViewController.h"
#import "CurrentDiagnosisViewController.h"
#import "EditVisit.h"
#import "FaceDetector.h"
#import <opencv2/highgui/cap_ios.h>
#import "FaceObject.h"
#import "DatabaseDriver.h"

//#import <opencv2/highgui/cap_ios.h>
#import "DataR.h"
//#import "RegisterFaceViewController.h"

@interface DoctorPatientViewController ()<CancelDelegate,EditVisitDelegate,UIPopoverControllerDelegate>{

    CurrentDiagnosisViewController* newView;
    EditVisit* editCurrentVisitView;
    UIBarButtonItem* edit;
    UIPopoverController* pop;
     UIImage *imageFR;
    NSManagedObjectContext *context;
    CameraFacade* facade;
}

@end

@implementation DoctorPatientViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    edit =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editPatientAndVisitInfo)];
    [self.navigationItem setRightBarButtonItem:edit];
    // allows this class to set itself as the delegate for the first view in the container
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setDelegateMethod:) name:SET_DELEGATE object:newView];
    // toggles the edit button when going into medication search
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(toggleEditButton:) name:DISABLE_EDIT object:[[NSNumber alloc]init]];
   [ColorMe addGradientToLayer:self.view.layer colorOne:[ColorMe lightGray] andColorTwo:[ColorMe whitishColor]inFrame:self.view.bounds];
}

-(void)updatedVisit:(NSMutableDictionary *)updatedVisit{
    [_patientData setDictionary:updatedVisit];
    [pop dismissPopoverAnimated:YES];
    [self displayPatientData];
    [newView setPatientData:_patientData];
    [newView populateView];
    
}
-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    [edit setEnabled:YES];
}
-(BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController{
    return NO;
}
-(void)editPatientAndVisitInfo{
    if (!editCurrentVisitView) {
        editCurrentVisitView = [self getViewControllerFromiPadStoryboardWithName:@"EditVisit"];
        [editCurrentVisitView view];
        
    }
    pop = [[UIPopoverController alloc]initWithContentViewController:editCurrentVisitView];
    
    [pop setDelegate:self];
    
    [editCurrentVisitView setDelegate:self];
    
    [editCurrentVisitView setVisitData:_patientData];
    
    [pop presentPopoverFromBarButtonItem:edit permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}
-(void)setDelegateMethod:(NSNotification*)notif{
    newView = notif.object;
    [newView setDelegate:self];
    [newView setPatientData:_patientData];
}
- (void)viewWillAppear:(BOOL)animated {
    //set notifications that will be called when the keyboard is going to be displayed
    [super viewWillAppear:animated];
    
    // Display patient data
    [self displayPatientData];
  
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //remove the notifications that open the keyboard
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

// Display patient info & vitals
- (void)displayPatientData {
    // Extract patient name/village/etc from visit dictionary
    NSDictionary * patientDic = [_patientData objectForKey:OPEN_VISITS_PATIENT];

    // Populate patient info
    id data = [patientDic objectForKey:PICTURE];
    
    UIImage* img = ([data isKindOfClass:[NSData class]])?[UIImage imageWithData:data]:[UIImage imageNamed:@"userImage.jpeg"];
    [_patientPhoto setImage:img];
    
    [ColorMe addRoundedBlackBorderWithShadowInRect:_patientPhoto.layer];
    
    _patientNameField.text = [patientDic objectForKey:FIRSTNAME];
    _familyNameField.text = [patientDic objectForKey:FAMILYNAME];
    _villageNameField.text = [patientDic objectForKey:VILLAGE];
    _patientAgeField.text = [NSString stringWithFormat:@"%i",[[NSDate convertSecondsToNSDate:[patientDic objectForKey:DOB]]getNumberOfYearsElapseFromDate]];
    _patientSexField.text = ([[patientDic objectForKey:SEX]integerValue]==0)?@"Female":@"Male";
    
    // Populate patient's vitals from triage
    _patientWeightLabel.text = [NSString stringWithFormat:@"%.1f %@",[[_patientData objectForKey:WEIGHT]doubleValue], @"kg"];
    _patientBPLabel.text = [NSString stringWithFormat:@"%@ %@",[_patientData objectForKey:BLOODPRESSURE], @"mmHg"];
    _patientHRLabel.text = [NSString stringWithFormat:@"%@ %@",[_patientData objectForKey:HEARTRATE], @"bpm"];
    _patientRespirationLabel.text = [NSString stringWithFormat:@"%@ %@",[_patientData objectForKey:RESPIRATION], @"bpm"];
    _patientTempLabel.text = [NSString stringWithFormat:@"%@ %@",[_patientData objectForKey:TEMPERATURE], @"°C"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setPatientNameField:nil];
    [self setFamilyNameField:nil];
    [self setVillageNameField:nil];
    [self setPatientAgeField:nil];
    [self setPatientSexField:nil];
    [self setPatientPhoto:nil];
    [self setPatientWeightLabel:nil];
    [self setPatientBPLabel:nil];
    [self setPatientHRLabel:nil];
    [self setPatientRespirationLabel:nil];
    [self setToolBar:nil];
    [self setPatientTempLabel:nil];
    [super viewDidUnload];
}

#pragma mark - TableView Methods
#pragma mark -

- (IBAction)segmentClicked:(id)sender {
    switch (_segmentedControl.selectedSegmentIndex) {
        case 0:
           
            break;
        case 1:
            
            break;
        default:
            break;
    }

}


// Hides keyboard when whitespace is pressed
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - Keyboard/View Movement
#pragma mark -
//the Y position of the cell will be at 216


//method to move the view up/down whenever the keyboard is shown/dismissed

-(void)toggleEditButton:(NSNotification*)notif{
    [edit setEnabled:[notif.object boolValue]];
}
-(void)cancel{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:SET_DELEGATE object:newView];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:DISABLE_EDIT object:[[NSNumber alloc]init]];
    
    [_delegate DoctorPatientViewUpdateAndClose];
}


- (IBAction)verify:(id)sender
{
    //[self resetData];
    FaceDetector *faceDetector =[[FaceDetector alloc]init];
    if (!facade) {
        facade = [[CameraFacade alloc]initWithView:self];
    }
    
    // Added Indeterminate Loader
    //MBProgressHUD *progress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    //[progress setMode:MBProgressHUDModeIndeterminate];
    
    [facade TakePictureWithCompletion:^(id img) {
        
        if(img) {
            // Reduce Image Size
            
            imageFR = img;
            cv::Mat image1 = [DataR cvMatFromUIImage:imageFR];
            const std::vector<cv::Rect> faces = [faceDetector facesFromImage:image1];
            if (faces.size() == 1) {
                
                
                
                NSDictionary* faceData = [[NSMutableDictionary alloc]init];
                cv::Rect face = faces[0];
                
                // By default highlight the face in red, no match found
                
                cv::Mat faceData1 = [self pullStandardizedFace:face fromImage:image1];
                NSData *serialized = [DataR serializeCvMat:faceData1];
                MobileClinicFacade* mobileFacade = [[MobileClinicFacade alloc]init];
                FaceObject *deleteObject = [[FaceObject alloc]initAndMakeNewDatabaseObject];
                
                context = deleteObject.database.managedObjectContext;
                [self deleteAllFromDatabase];
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
                                          NSString *fname1 = [pat objectForKey:@"firstName"];
                                          NSString *lname1 = [pat objectForKey:@"familyName"];
                                          NSString* messageString = [NSString stringWithFormat:@"First Name: %@ \n Family Name: %@",fname1,lname1];
                                          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Match Found!"
                                                                                          message:messageString
                                                                                         delegate:nil
                                                                                cancelButtonTitle:@"OK"
                                                                                otherButtonTitles:nil];
                                          [alert show];
                                      }
                                      else
                                      {
                                          NSLog(@"Imheerereereererere 1");
                                      }
                                      
                                  }];
                             }
                             else
                             {
                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Done"
                                                                                 message:@"No match was found. Please try again!"
                                                                                delegate:nil
                                                                       cancelButtonTitle:@"OK"
                                                                       otherButtonTitles:nil];
                                 [alert show];
                             }
                         }
                         
                         
                     }else{
                         NSLog(@"Imheerereereererere 1");
                     }
                     
                 }];
            }//end size
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Done"
                                                                message:@"No faces were found on the picure. Please try again"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                
            }
            
        }//end img
        
       // [progress hide:YES];
    }];
}
- (cv::Mat)pullStandardizedFace:(cv::Rect)face fromImage:(cv::Mat&)image
{
    // Pull the grayscale face ROI out of the captured image
    cv::Mat onlyTheFace;
    //cv::cvtColor(image(face), onlyTheFace, CV_RGB2GRAY);
    // Standardize the face to 100x100 pixels
    cv::resize(image(face), onlyTheFace, cv::Size(100, 100), 0, 0);
    return onlyTheFace;
}
- (void) deleteAllFromDatabase
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Faces" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    //fetchRequest.predicate = [NSPredicate predicateWithFormat:@"firstName ==nil AND familyName == nil"];
    
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
@end
