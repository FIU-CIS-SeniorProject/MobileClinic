//
//  MedicineSearchViewController.m
//  Mobile Clinic
//
//  Created by Steven Berlanga on 2/24/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import "MedicineSearchViewController.h"
#import "MobileClinicFacade.h"

@interface MedicineSearchViewController () {
    NSMutableArray *searchResultArray;
    NSArray* mainArray;
    NSMutableSet* timeOfDaySet;
    
}
@end

@implementation MedicineSearchViewController

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
   
    [_tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"tornMid.png"]]];
    
    [ColorMe addBorder:_tableView.layer withWidth:1 withColor:[UIColor blackColor]];
    
    [ColorMe addGradientToLayer:self.view.layer colorOne:[ColorMe lightGray] andColorTwo:[ColorMe whitishColor]inFrame:self.view.bounds];
    
    
    MobileClinicFacade *mobileFacade = [[MobileClinicFacade alloc]init];
    
    /** This will should HUD in tableview to show alert the user that the system is working */
    [self showIndeterminateHUDInView:_tableView withText:@"Loading" shouldHide:NO afterDelay:0 andShouldDim:NO];
    
    // Request all medications in database
    [mobileFacade findAllMedication:nil AndOnCompletion:^(NSArray *allObjectsFromSearch, NSError *error) {
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"medName" ascending:YES];
        
        NSArray *sortDescriptorArray = [NSArray arrayWithObject:sortDescriptor];
        
        mainArray = [[NSArray arrayWithArray:allObjectsFromSearch] sortedArrayUsingDescriptors:sortDescriptorArray];
        
        [self searchMedicine:nil];
        /** This will remove the HUD since the search is complete */
        [self HideALLHUDDisplayInView:_tableView];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)AddTimeOfDay:(id)sender {
    if (!timeOfDaySet) {
        timeOfDaySet = [[NSMutableSet alloc]initWithCapacity:4];
    }
    
NSString* time = [self getTimeOfDay:[sender tag]];

if([timeOfDaySet containsObject:time]){
    [timeOfDaySet removeObject:time];
}else{
    [timeOfDaySet addObject:time];
}
[self updateTimeOfDayLabel];

}
-(void)updateTimeOfDayLabel{
    NSMutableString* text = [[NSMutableString alloc]initWithCapacity:7];

    for (NSString* day in timeOfDaySet) {
        [text appendFormat:@"%@, ",day];
    }
    
    [_timeOfDay setText:text];
}
- (IBAction)moveBackToPrescription:(id)sender {
    
    if ([self validatePrescription]) {
    // Create a timestamp for Prescribe Time
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        
    NSString *dateStamp = [DateFormatter stringFromDate:[NSDate date]];
    
        [_prescriptionData setObject:[NSNumber numberWithInteger:(int)_durationIncrementer.value] forKey:TABLEPERDAY];
    
        [_prescriptionData setObject:_timeOfDay.text forKey:TIMEOFDAY];
    
        [_prescriptionData setObject:dateStamp forKey:PRESCRIBETIME];
        
        [_prescriptionData setObject:_dosage.text forKey:INSTRUCTIONS];

        [_delegate addPrescription:_prescriptionData];
    }
}
-(void)resetView{
    [_durationIncrementer setValue:30];
    [_drugName setText:@""];
    if (timeOfDaySet) {
        [timeOfDaySet removeAllObjects];
    }
    [_timeOfDay setText:@""];
    [self alterAmountOfTablets:_durationIncrementer];
    _prescriptionData = nil;
    [_dosage setText:@""];

    
}

- (IBAction)alterAmountOfTablets:(id)sender {
    
    UIStepper* step = sender;
    
    [_duration setText:[NSString stringWithFormat:@"%i Days",(int)step.value]];
}

- (BOOL)validatePrescription {
    BOOL inputIsValid = YES;
    NSString *errorMsg;
    
    if([_drugName.text isEqualToString:@""] || _drugName.text == nil) {
        errorMsg = @"Missing medication";
        inputIsValid = NO;
    } else if([_dosage.text isEqualToString:@""] || _duration.text == nil) {
        errorMsg = @"Missing Dosage";
        inputIsValid = NO;
    } else if([_timeOfDay.text isEqualToString:@""] || _timeOfDay.text == nil) {
        errorMsg = @"Choose time of day";
        inputIsValid = NO;
    }
    
    // Display error message on invalid input
    if(inputIsValid == NO){
        UIAlertView *validateDiagnosisAlert = [[UIAlertView alloc] initWithTitle:nil message:errorMsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [validateDiagnosisAlert show];
    }
    
    return inputIsValid;
}

- (NSString *)getTimeOfDay:(int)num {
    switch (num) {
        case 0:
            return @"Morning";
            break;
        case 1:
            return @"Mid-Afternoon";
            break;
        case 2:
            return @"Midday";
            break;
        case 3:
            return @"Evening";
            break;
        default:
            return @"";
            break;
    }
}

- (void)viewDidUnload {
    [self setMedicineField:nil];
    [self setTableView:nil];
    [super viewDidUnload];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return searchResultArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        UINib * mNib = [UINib nibWithNibName:@"MedicineSearchResultView" bundle:nil];
        cell = [mNib instantiateWithOwner:nil options:nil][0];
    }

    NSDictionary *medDic = [searchResultArray objectAtIndex:indexPath.row];
    
    cell.detailTextLabel.text = [medDic objectForKey:MEDNAME];
    
    [cell.textLabel setText:[NSString stringWithFormat:@"%i",indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // Display get medication at the specified index
    NSDictionary *myDic = [searchResultArray objectAtIndex:indexPath.row];

    // Construct a text
    _drugName.text = [myDic objectForKey:MEDNAME];
    
    // Store Medication ID and name
    if (!_prescriptionData) {
        _prescriptionData = [[NSMutableDictionary alloc]init];
    }
    
    [_prescriptionData setValue:[myDic objectForKey:MEDICATIONID] forKey:MEDICATIONID];
    
    [_prescriptionData setValue:[myDic objectForKey:MEDNAME] forKey:MEDNAME];
    
}

- (IBAction)searchMedicine:(id)sender {

    NSPredicate *predicate;
    
    if(![_medicineField.text isEqualToString:@""]){
        predicate = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", MEDNAME, _medicineField.text];
    }else{
        predicate= [NSPredicate predicateWithFormat:@"%K != %@", MEDNAME, @""];
    }
    searchResultArray = [NSMutableArray arrayWithArray:[mainArray filteredArrayUsingPredicate:predicate]];
    
    [_tableView reloadData];
    
    [_medicineField resignFirstResponder];
}

// Hides keyboard when whitespace is pressed
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
