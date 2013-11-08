//
//  TriagePatientViewController.m
//  Mobile Clinic
//
//  Created by sebastian a zanlongo on 2/18/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import "TriagePatientViewController.h"
#import "TriageViewController.h"

@interface TriagePatientViewController ()

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
	// Do any additional setup after loading the view.
    
    UINavigationBar *bar =[self.navigationController navigationBar];
    [bar setTintColor:[UIColor orangeColor]];
    
    // Rotate table horizontally (90 degrees)
    CGAffineTransform transform = CGAffineTransformMakeRotation(-1.5707963);
    _tableView.rowHeight = 768;
    _tableView.transform = transform;
    [_tableView setShowsVerticalScrollIndicator:NO];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    // Create controllers for each view (Previous Visits & current visit)
    _control1 = [self getViewControllerFromiPadStoryboardWithName:@"currentVisitViewController"];
    _control2 = [self getViewControllerFromiPadStoryboardWithName:@"previousVisitsViewController"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    [self.tableView reloadData];
}

- (void)keyboardDidShow:(NSNotification *)notif {
}

- (void)keyboardDidHide:(NSNotification *)notif {
}

- (void)viewWillAppear:(BOOL)animated {
    _patientNameField.text = [_patientData objectForKey:FIRSTNAME];
    _familyNameField.text = [_patientData objectForKey:FAMILYNAME];
    _villageNameField.text = [_patientData objectForKey:VILLAGE];
    
    if ([_patientData objectForKey:DOB] == 0) {
        _patientAgeField.text = @"Unknown";
    } else {
        _patientAgeField.text = [NSString stringWithFormat:@"%i",[[NSDate convertSecondsToNSDate:[_patientData objectForKey:DOB]]getNumberOfYearsElapseFromDate]];

    }
    
    NSString* gender = ([[_patientData objectForKey:SEX]integerValue]==0)?@"Female":@"Male";
    _patientSexField.text = gender;
    
    id data = [_patientData objectForKey:PICTURE];
    [_patientPhoto setImage:[UIImage imageWithData:([data isKindOfClass:[NSData class]])?data:nil]];
    
    [_control1 view];
    [_control1 setPatientData:_patientData];
    [_control2 view];
    [_control2 setPatientData:_patientData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setToolBar:nil];
    [self setPatientNameField:nil];
    [self setFamilyNameField:nil];
    [self setVillageNameField:nil];
    [self setPatientAgeField:nil];
    [self setPatientSexField:nil];
    [self setPatientPhoto:nil];
    [super viewDidUnload];
}

// Hides keyboard when whitespace is pressed
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * currentVisitCellIdentifier = @"currentVisitCell";
    static NSString * previousVisitsCellIdentifier = @"previousVisitsCell";
    
    if(indexPath.item == 0) {
        CurrentVisitTableCell * cell = [tableView dequeueReusableCellWithIdentifier:currentVisitCellIdentifier];
        
        if (!cell) {
            cell = [[CurrentVisitTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:currentVisitCellIdentifier];
            cell.viewController = _control1;
        }
        
        CGAffineTransform transform = CGAffineTransformMakeRotation(1.5707963);
        cell.viewController.view.transform = transform;
        cell.viewController.view.frame = CGRectMake(0, 0, 744, 768);
        
        for(UIView *mView in [cell.contentView subviews]){
            [mView removeFromSuperview];
        }
        
        [cell addSubview:cell.viewController.view];
        [cell.viewController setScreenHandler:handler];
        
        [_segmentedControl setEnabled:YES forSegmentAtIndex:0];
        _segmentedControl.selectedSegmentIndex = 0;
        
        return cell;
    }else{
        PreviousVisitsTableCell * cell = [tableView dequeueReusableCellWithIdentifier:previousVisitsCellIdentifier];
        
        if(!cell){
            cell = [[PreviousVisitsTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:previousVisitsCellIdentifier];
            cell.viewController = _control2;
        }
        
        CGAffineTransform transform = CGAffineTransformMakeRotation(1.5707963);
        cell.viewController.view.transform = transform;
        cell.viewController.view.frame = CGRectMake(0, 0, 744, 768);
        
        for(UIView *mView in [cell.contentView subviews]){
            [mView removeFromSuperview];
        }
        
        [cell addSubview: cell.viewController.view];
        
        [_segmentedControl setEnabled:YES forSegmentAtIndex:1];
        _segmentedControl.selectedSegmentIndex = 1;
        
        return cell;
    }
}

- (void)setScreenHandler:(ScreenHandler)myHandler {
    handler = myHandler;
}

- (IBAction) segmentedControlIndexChanged {
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            break;
        case 1:
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            break;
        default:
            break;
    }

    [self.tableView reloadData];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)offset {
    int cellHeight = 768;
    
    if(((int)offset->y) % (cellHeight) > cellHeight/2){
        *offset = CGPointMake(offset->x, offset->y + (cellHeight - (((int)offset->y) % (cellHeight))));
        self.segmentedControl.selectedSegmentIndex = 1;
    }else{
        *offset = CGPointMake(offset->x, offset->y - (((int)offset->y) % (cellHeight)));
//        self.segmentedControl.selectedSegmentIndex = 0;
    }
}

@end
