//
//  EditVisit.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 5/8/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import "EditVisit.h"
#import "MobileClinicFacade.h"
@interface EditVisit ()

@end

@implementation EditVisit

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
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_weight setText:[[_visitData objectForKey:WEIGHT]description]];
    [_tempField setText:[_visitData objectForKey:TEMPERATURE]];
    [_heartField setText:[_visitData objectForKey:HEARTRATE]];
    [_respirationField setText:[_visitData objectForKey:RESPIRATION]];
    NSString* bp = [_visitData objectForKey:BLOODPRESSURE];
    NSArray* pressure = [bp componentsSeparatedByString:@"/"];
    [_systolicField setText:[pressure objectAtIndex:0]];
    [_diastolicField setText:[pressure lastObject]];
    [_conditionTitleField setText:[_visitData objectForKey:CONDITIONTITLE]];
    [_conditionsTextbox setText:[_visitData objectForKey:ASSESSMENT]];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidUnload {
    [self setWeight:nil];
    [self setSystolicField:nil];
    [self setDiastolicField:nil];
    [self setHeartField:nil];
    [self setRespirationField:nil];
    [self setConditionTitleField:nil];
    [self setConditionsTextbox:nil];
    [super viewDidUnload];
}
- (IBAction)saveandClose:(id)sender {
   
    
    /** This will should HUD in tableview to show alert the user that the system is working */
    [self showIndeterminateHUDInView:self.view withText:@"Saving..." shouldHide:NO afterDelay:0 andShouldDim:YES];
    
    MobileClinicFacade* mobileFacade = [[MobileClinicFacade alloc]init];
    
    [_visitData setValue:[NSNumber numberWithInt:[_weight.text intValue]] forKey:WEIGHT];
    [_visitData setValue:[NSString stringWithFormat: @"%@/%@", _systolicField.text, _diastolicField.text] forKey:BLOODPRESSURE];
    [_visitData setValue:_heartField.text forKey:HEARTRATE];
    [_visitData setValue:_respirationField.text forKey:RESPIRATION];
    [_visitData setValue:_tempField.text forKey:TEMPERATURE];

    
    [mobileFacade updateVisitRecord:_visitData andShouldUnlock:NO andShouldCloseVisit:NO onCompletion:^(NSDictionary *object, NSError *error){
        if (!object) {
            [FIUAppDelegate getNotificationWithColor:AJNotificationTypeOrange Animation:AJLinedBackgroundTypeAnimated WithMessage:error.localizedDescription inView:self.view];
        }else{
            [_delegate updatedVisit:_visitData];
        }
        /** This will remove the HUD since the search is complete */
        [self HideALLHUDDisplayInView:self.view];
    }];
}
@end
