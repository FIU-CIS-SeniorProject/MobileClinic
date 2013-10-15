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
//  UICamera.m
//  StudentConnect
//
//  Created by Michael Montaque on 5/25/12.
//  Copyright (c) 2012 Florida International University. All rights reserved.
//

#import "UICamera.h"

BOOL isPhoto;

@implementation UICamera

@synthesize usePopover,delegate,library,CAMERA;

-(id)initWithPopover:(BOOL)shouldPop button:(CGRect)rect popoverController:(UIPopoverController*)popover inView:(UIViewController*)newView
{
    self =[super init];
    
    if (self)
    {
        //  library = [[ALAssetsLibrary alloc]init];
        multiThread = dispatch_queue_create("mainScreen", NULL);
        button= rect;
        usePopover = shouldPop;
        pop = popover;
        view = newView;
        CAMERA = @"camera";
    }
    return self;
}

-(id)initInView:(id)newView
{
    self =[super init];
    
    if (self)
    {
        //  library = [[ALAssetsLibrary alloc]init];
        multiThread = dispatch_queue_create("mainScreen", NULL);
        usePopover = NO;
        view = newView;
        CAMERA = @"camera";
    }
    return self;
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if ([view conformsToProtocol:@protocol(UIPopoverControllerDelegate)])
    {
        [popoverController setDelegate:view];
    }
    camera(nil);
}

-(BOOL)checkCameraStatus
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        NSLog(@"Camera is not Available");
        
        UIAlertView *alrt = [[UIAlertView alloc]initWithTitle:@"NO Camera" message:@"Camera is either not ready or this device does not have one. If it has one please ensure that it is not in use." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alrt show];
        return NO;
    }
    return YES;
}

-(void)initiateVideo
{
    //check for working camera
    if ([self checkCameraStatus])
    {
        isPhoto=NO;
        dispatch_async(multiThread, ^{
            // Create image picker controller
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            
            // Set source to the camera
            imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
            
            [imagePicker setMediaTypes:[NSArray arrayWithObject:(NSString *)kUTTypeMovie]];
            [imagePicker setVideoQuality:UIImagePickerControllerQualityTypeMedium];
            [imagePicker setVideoMaximumDuration:60];
            [imagePicker setCameraCaptureMode:UIImagePickerControllerCameraCaptureModeVideo];
            
            // Delegate is self
            [imagePicker setDelegate:self];
            
            // Allow editing of image ?
            [imagePicker setEditing:YES animated:YES];
            
            if (usePopover)
            {
                [imagePicker setContentSizeForViewInPopover:CGSizeMake(460,320)];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!usePopover)
                {
                    [view presentViewController:imagePicker animated:YES completion:nil];
                }
                else
                {
                    pop = [[UIPopoverController alloc]initWithContentViewController:imagePicker];
                    [pop setDelegate:self];
                    [pop presentPopoverFromRect:button
                                         inView:view.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                }
            });
        });
    }
    else
    {
        camera(nil);
    }
}

-(void)initiatePhotogragh
{
    //check for working camera
    if ([self checkCameraStatus])
    {
        isPhoto = YES;
        
        dispatch_async(multiThread, ^{
            // Create image picker controller
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            
            // Set source to the camera
            imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
            
            // Delegate is self
            [imagePicker setDelegate:self];
            
            // Allow editing of image ?
            [imagePicker setEditing:NO animated:YES];
            
            if (usePopover)
            {
                [imagePicker setContentSizeForViewInPopover:CGSizeMake(460,320)];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Show image picker
                if (!usePopover)
                {
                    [view presentViewController:imagePicker animated:YES completion:nil];
                }
                else
                {
                    pop = [[UIPopoverController alloc]initWithContentViewController:imagePicker];
                    [pop setDelegate:self];
                    [pop presentPopoverFromRect:button
                                         inView:view.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                }
            });
        });
    }
    else
    {
        camera(nil);
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (usePopover)
    {
        [pop dismissPopoverAnimated:YES];
    }
    else
    {
        [view dismissViewControllerAnimated:YES completion:nil];
    }
    camera(nil);
}

-(void)takeAPicture:(TakePicture)picture
{
    camera = picture;
    [self initiatePhotogragh];
}

-(void)takeAVideo:(TakePicture)data
{
    camera = data;
    [self initiateVideo];
}

-(void)takePictureFromAlbum:(TakePicture)picture
{
    camera = picture;
    [self showPhotoAlbum];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (usePopover)
    {
        [pop dismissPopoverAnimated:YES];
    }
    else
    {
        [view dismissViewControllerAnimated:YES completion:nil];
    }
    
    //multithread to speed up saving
    dispatch_async(multiThread, ^{
        
        UIImage *originalImage, *editedImage, *imageToSave;
        if (!isPhoto)
        {
            NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
            NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
            camera(videoData);
        }
        else
        {
            editedImage = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
            originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
            
            if (editedImage)
            {
                imageToSave = editedImage;
            }
            else
            {
                imageToSave = originalImage;
            }
            
            UIImage* img = [imageToSave fixImageOrientation];
            
            //put back into main thread to miniize time taken to display photo
            dispatch_async(dispatch_get_main_queue(), ^{
                camera(img);
            });
        }
    });
}

-(void)showPhotoAlbum
{
    UIImagePickerController *pickerLibrary = [[UIImagePickerController alloc] init];
    
    isPhoto = YES;
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        [pickerLibrary setSourceType: UIImagePickerControllerSourceTypePhotoLibrary];
        [pickerLibrary setDelegate:self];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            pop = [[UIPopoverController alloc]initWithContentViewController:pickerLibrary];
            [pop setDelegate:self];
            [pop presentPopoverFromRect:button inView:view.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            
            usePopover = YES;
        }
        else
        {
            [view presentViewController:pickerLibrary animated:YES completion:nil];
            usePopover = NO;
        }
    }
    else
    {
        camera(nil);
    }
}
@end