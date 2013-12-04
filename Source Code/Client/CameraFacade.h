//
//  CameraFacade.h
//  StudentConnect
//
//  Created by Michael Montaque on 12/24/12.
//  Copyright (c) 2012 Florida International University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UICamera.h"
@interface CameraFacade : NSObject<UICameraDelegate>{
    UIViewController* currentView;
    UICamera* camera;
}

-(id)initWithView:(UIViewController*)view;
-(void)TakePictureWithCompletion:(TakePicture)Completed;
-(void)ShowAlbumWithCompletion:(TakePicture)Completed;
-(void)TakeVideoWithCompletion:(TakePicture)Completed;
@end
