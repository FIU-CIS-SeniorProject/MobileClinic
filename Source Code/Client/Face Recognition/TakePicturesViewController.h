//
//  TakePicturesViewController.h
//  Mobile Clinic
//
//  Created by Humberto Suarez on 12/3/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraFacade.h"

@interface TakePicturesViewController : UIViewController
{
     CameraFacade *facade;
}

- (IBAction)addPicture1:(id)sender;
- (IBAction)addPicture2:(id)sender;
- (IBAction)addPicture4:(id)sender;
- (IBAction)addPicture3:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *picture1;
@property (weak, nonatomic) IBOutlet UIImageView *picture2;
@property (weak, nonatomic) IBOutlet UIImageView *picture3;
@property (weak, nonatomic) IBOutlet UIImageView *picture4;

@end
