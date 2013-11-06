//
//  CameraFacade.m
//  StudentConnect
//
//  Created by Michael Montaque on 12/24/12.
//  Copyright (c) 2012 Florida International University. All rights reserved.
//

#import "CameraFacade.h"

@implementation CameraFacade

-(id)initWithView:(UIViewController *)view{
    self = [super self];
    if (self) {
        currentView = view;
        camera = [[UICamera alloc]initInView:currentView];
        [camera setDelegate:self];
    }
    return self;
}
-(void)TakePictureWithCompletion:(TakePicture)Completed{
    if (!camera) {
        camera = [[UICamera alloc]initInView:currentView];
        [camera setDelegate:self];
    }
    [camera takeAPicture:Completed];
}
-(void)TakeVideoWithCompletion:(TakePicture)Completed{
    if (!camera) {
        camera = [[UICamera alloc]initInView:currentView];
        [camera setDelegate:self];
    }
    [camera takeAVideo:Completed];
}
-(void)ShowAlbumWithCompletion:(TakePicture)Completed{
    if (!camera) {
        camera = [[UICamera alloc]initInView:currentView];
        [camera setDelegate:self];
    }
    [camera takePictureFromAlbum:Completed];
}
-(void)cameraCancelledOperation{

}
@end
