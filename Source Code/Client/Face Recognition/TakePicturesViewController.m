//
//  TakePicturesViewController.m
//  Mobile Clinic
//
//  Created by Humberto Suarez on 12/3/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import "TakePicturesViewController.h"

@interface TakePicturesViewController ()

@end

@implementation TakePicturesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*- (IBAction)addPicture1:(id)sender
{
    if (!facade) {
        facade = [[CameraFacade alloc]initWithView:self];
    }
    
    // Added Indeterminate Loader
   // MBProgressHUD *progress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
   // [progress setMode:MBProgressHUDModeIndeterminate];
    
    [facade TakePictureWithCompletion:^(id img) {
        
        if(img) {
            // Reduce Image Size
            UIImage* image = img;
            
            UIImage* scaled = [image imageByScalingAndCroppingForSize:CGSizeMake(150, 150)];
            
            [self.picture1 setImage:scaled];
            
        }
        
     //   [progress hide:YES];
    }];
}

/*- (IBAction)addPicture2:(id)sender
{
    if (!facade) {
        facade = [[CameraFacade alloc]initWithView:self];
    }
    
    // Added Indeterminate Loader
   // MBProgressHUD *progress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
   // [progress setMode:MBProgressHUDModeIndeterminate];
    
    [facade TakePictureWithCompletion:^(id img) {
        
        if(img) {
            // Reduce Image Size
            UIImage* image = img;
            
            UIImage* scaled = [image imageByScalingAndCroppingForSize:CGSizeMake(150, 150)];
            
            [self.picture2 setImage:scaled];
            
            
        }
        
     //   [progress hide:YES];
    }];
}

- (IBAction)addPicture4:(id)sender
{
    if (!facade) {
        facade = [[CameraFacade alloc]initWithView:self];
    }
    
    // Added Indeterminate Loader
   // MBProgressHUD *progress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
   // [progress setMode:MBProgressHUDModeIndeterminate];
    
    [facade TakePictureWithCompletion:^(id img) {
        
        if(img) {
            // Reduce Image Size
            UIImage* image = img;
            
            UIImage* scaled = [image imageByScalingAndCroppingForSize:CGSizeMake(150, 150)];
            
            [self.picture3 setImage:scaled];
            
            
        }
        
     //   [progress hide:YES];
    }];
}

- (IBAction)addPicture3:(id)sender
{
    if (!facade) {
        facade = [[CameraFacade alloc]initWithView:self];
    }
    
    // Added Indeterminate Loader
   // MBProgressHUD *progress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
   // [progress setMode:MBProgressHUDModeIndeterminate];
    
    [facade TakePictureWithCompletion:^(id img) {
        
        if(img) {
            // Reduce Image Size
            UIImage* image = img;
            
            UIImage* scaled = [image imageByScalingAndCroppingForSize:CGSizeMake(150, 150)];
            
            [self.picture4 setImage:scaled];
            
            
        }
        
     //   [progress hide:YES];
    }];
}*/
@end
