//
//  PharmacyViewController.m
//  Mobile Clinic
//
//  Created by sebastian a zanlongo on 2/18/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import "PharmacyViewController.h"
#import "PharmacyPatientViewController.h"

@interface PharmacyViewController ()

@end

@implementation PharmacyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
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
    
    UINavigationBar *bar =[self.navigationController navigationBar];
    [bar setTintColor:[UIColor colorWithRed:52.0/225 green:186.0/225 blue:91.0/225 alpha:.7]];
    
    CGAffineTransform transform = CGAffineTransformMakeRotation(-1.5707963);
    _tableView.rowHeight = 768;
    _tableView.transform = transform;
    _tableView.frame = self.view.frame;
    [_tableView setShowsVerticalScrollIndicator:NO];
    
    // Create controller for search
    _control = [self getViewControllerFromiPadStoryboardWithName:@"searchPatientViewController"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transferPatientData:) name:SEARCH_FOR_PATIENT object:_patientData];
}

// Transfers the patient's data to the next view controller
- (void)transferPatientData:(NSNotification *)note
{
    _patientData = note.object;
    
    PharmacyPatientViewController *newView = [self getViewControllerFromiPadStoryboardWithName:@"pharmacyPatientViewController"];

    newView.patientData = _patientData;
    
    [self.navigationController pushViewController:newView animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *searchCellIdentifier = @"searchCell";
    
    SearchPatientTableCell * cell = [tableView dequeueReusableCellWithIdentifier:searchCellIdentifier];
    
    if(!cell){
        cell = [[SearchPatientTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:searchCellIdentifier];
        cell.viewController = _control;
    }
    
//    CGAffineTransform transform = CGAffineTransformMakeRotation(1.5707963);
//    cell.viewController.view.transform = transform;
//    
//    cell.viewController.view.frame = CGRectMake(50, 0, 916, 768);
//    
//    // Removes previous view (for memory mgmt)
//    for(UIView *mView in [cell.contentView subviews]){
//        [mView removeFromSuperview];
//    }
//
//    [cell addSubview: cell.viewController.view];
    
    return [self setupCell:cell forRow:indexPath];
//    return cell;
}

- (UITableViewCell*)setupCell:(id)cell forRow:(NSIndexPath*)path {
    // Rotate view vertically on the screen
    CGAffineTransform transform = CGAffineTransformMakeRotation(1.5707963);
    [cell viewController].view.transform = transform;
    [cell viewController].view.frame = CGRectMake(50, 0, 916, 768);
    
    // Removes previous view (for memory mgmt)
    for(UIView *mView in [[cell contentView] subviews]) {
        [mView removeFromSuperview];
    }
    
    // Populate view in cell
    [cell addSubview: [cell viewController].view];
    
    [[cell viewController] setScreenHandler:^(id object, NSError *error) {
        _patientData = object;
        
//        PharamcyPrescriptionViewController *newView = [self getViewControllerFromiPadStoryboardWithName:@"pharmacyPatientViewController"];
        
        DoctorPrescriptionViewController *newView = [self getViewControllerFromiPadStoryboardWithName:@"pharmacyPatientViewController"];
        
        newView.patientData = _patientData;
        
        [newView setScreenHandler:^(id object, NSError *error) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
        [self.navigationController pushViewController:newView animated:YES];
        
        if (error) {
            [FIUAppDelegate getNotificationWithColor:AJNotificationTypeRed Animation:AJLinedBackgroundTypeAnimated WithMessage:error.localizedDescription inView:newView.view
             ];
        }
    }];
    
    return cell;
}

- (void)setScreenHandler:(ScreenHandler)myHandler {
    handler = myHandler;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)offset {
    int cellHeight = 768;
    
    if(((int)offset->y) % (cellHeight) > cellHeight/2){
        *offset = CGPointMake(offset->x, offset->y + (cellHeight - (((int)offset->y) % (cellHeight))));
    }else
        *offset = CGPointMake(offset->x, offset->y - (((int)offset->y) % (cellHeight)));
}

@end
