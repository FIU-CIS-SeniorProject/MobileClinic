//
//  RegisterPatientViewController.h
//  Mobile Clinic
//
//  Created by sebastian a zanlongo on 2/18/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MobileClinicFacade.h"
#import "CameraFacade.h"
#import "StationViewHandlerProtocol.h"
#import "GenericCellProtocol.h"
#import <Foundation/Foundation.h>
#import "RegisterFaceViewController.h"



@interface RegisterPatientViewController : UIViewController<GenericCellProtocol, UITableViewDataSource, UITableViewDelegate,faceViewDelegate>{
    
    ScreenHandler handler;
    CameraFacade *facade;
    BOOL shouldDismiss;
}
@property (nonatomic) UIImage *returnedImage;

@property (weak, nonatomic) id	<GenericCellManager> delegate;
@property (weak, nonatomic) IBOutlet UITextField *patientNameField;
@property (weak, nonatomic) IBOutlet UITextField *familyNameField;
@property (weak, nonatomic) IBOutlet UITextField *villageNameField;
@property (weak, nonatomic) IBOutlet UIButton *patientAgeField;
@property (weak, nonatomic) IBOutlet UIImageView *patientPhoto;
@property (weak, nonatomic) IBOutlet UISegmentedControl *patientSexSegment;
@property (weak, nonatomic) IBOutlet UIButton *createPatientButton;
@property (weak, nonatomic) IBOutlet UIButton *registerFingerprintsButton;

@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (strong, nonatomic) IBOutlet UITextField *firstNameField;
@property (strong, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITableView *searchResultTableView;
@property (strong, nonatomic) UIButton *patientFound;

- (IBAction)registerFingerprintsButton:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *registerView;

- (IBAction)patientPhotoButton:(id)sender;

- (IBAction)createPatient:(id)sender;
- (IBAction)searchByFingerprintButton:(id)sender;
- (BOOL)validateRegistration;
- (void)setPatientArray:(NSArray*)patientArray;
- (IBAction)searchByNameButton:(id)sender ;
- (IBAction)startOver:(id)sender;

- (IBAction)getAgeOfPatient:(id)sender;

- (void)resetData;





@end
