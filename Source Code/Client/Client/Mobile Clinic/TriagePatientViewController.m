//
//  TriagePatientViewController.m
//  Mobile Clinic
//
//  Created by sebastian a zanlongo on 2/18/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import "TriagePatientViewController.h"
#import "CurrentVisitViewController.h"
#import "PreviousVisitsViewController.h"
#import "MobileClinicFacade.h"
@interface TriagePatientViewController (){
    MobileClinicFacade* mcf;
    CurrentVisitViewController* currentVisit;
}

@end

@implementation TriagePatientViewController

//@synthesize segmentedControl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    mcf = [[MobileClinicFacade alloc]init];
    
    [ColorMe ColorTint:_patientView.layer forCustomColor:[ColorMe colorFor:PALEORANGE]];
    
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setDelegateMethod:) name:SET_DELEGATE object:currentVisit];
	// Do any additional setup after loading the view.

}
-(void)setDelegateMethod:(NSNotification*)notif{
    currentVisit = notif.object;
    [currentVisit setDelegate:self];
    [currentVisit setPatientData:_patientData];
}
-(void)cancel{
    [_delegate cancel];
}

-(void)populateInformation{
    _patientNameField.text = [_patientData objectForKey:FIRSTNAME];
    _familyNameField.text = [_patientData objectForKey:FAMILYNAME];
    _villageNameField.text = [_patientData objectForKey:VILLAGE];
    _patientPhoto.image = [UIImage imageWithData:[_patientData objectForKey:PICTURE]];
    
    
    
    if ([_patientData objectForKey:DOB] == 0) {
        _patientAgeField.text = @"Unknown";
    } else {
        _patientAgeField.text = [NSString stringWithFormat:@"%i",[[NSDate convertSecondsToNSDate:[_patientData objectForKey:DOB]]getNumberOfYearsElapseFromDate]];
        
    }
    
    NSString* gender = ([[_patientData objectForKey:SEX]integerValue]==0)?@"Female":@"Male";
    _patientSexField.text = gender;
    
    // Populate patient info
    id data = [_patientData objectForKey:PICTURE];
    
    UIImage* img = ([data isKindOfClass:[NSData class]])?[UIImage imageWithData:data]:[UIImage imageNamed:@"userImage.jpeg"];
    [_patientPhoto setImage:img];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self setPatientNameField:nil];
    [self setFamilyNameField:nil];
    [self setVillageNameField:nil];
    [self setPatientAgeField:nil];
    [self setPatientSexField:nil];
    [self setPatientPhoto:nil];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setToolBar:nil];
    [self setPatientNameField:nil];
    [self setFamilyNameField:nil];
    [self setVillageNameField:nil];
    [self setPatientAgeField:nil];
    [self setPatientSexField:nil];
    [self setPatientPhoto:nil];
    [super viewDidUnload];
}


- (IBAction)toggleViews:(id)sender {
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            [currentVisit closePreviousVisit];
            break;
        case 1:
            [currentVisit showPreviousVisit];
            break;
        default:
            break;
    }
}

@end
