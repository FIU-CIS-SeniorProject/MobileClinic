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
//  GenericStartViewController.m
//  Mobile Clinic
//
//  Created by sebastian a zanlongo on 3/6/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//
#import "GenericStartViewController.h"
#import "TriagePatientViewController.h"
#import "DoctorPatientViewController.h"
#import "PharmacyPatientViewController.h"
#import "PatientDashboardViewController.h"

@interface GenericStartViewController ()

@property (strong, nonatomic) UIPopoverController * pop;
@end

@implementation GenericStartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.stationChosen = ((StationNavigationController *)self.navigationController).stationChosen;
    
    // Rotate table horizontally (-90 degrees)
    CGAffineTransform transform = CGAffineTransformMakeRotation(-1.5707963);
    _tableView.rowHeight = 768;
    _tableView.transform = transform;
    
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    CGRect newFrame = self.view.frame;
    newFrame.origin.y -= 18;
    _tableView.frame = newFrame;
    [_tableView setShowsVerticalScrollIndicator:NO];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    UINavigationBar *bar = [self.navigationController navigationBar];
    [self.navigationItem setTitle:@"Triage"];
    UIBarButtonItem * menu = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(popOverMenu)];
    
    [self.navigationItem setLeftBarButtonItem:menu];
    
    _searchControl = [self getViewControllerFromiPadStoryboardWithName:@"searchPatientViewController"];
    [_segmentedControl setTitle:@"Search" forSegmentAtIndex:1];
    
    UIBarButtonItem *stationMenu = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(popOverMenu)];
    UIBarButtonItem *dashboard = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(pushDashboard)];
    
    [self.navigationItem setLeftBarButtonItem:stationMenu];
    [self.navigationItem setRightBarButtonItem:dashboard];
    
    _searchControl = [self getViewControllerFromiPadStoryboardWithName:@"searchPatientViewController"];
    [_segmentedControl setTitle:@"Search" forSegmentAtIndex:1];
    
    //set up according to station chosen
    switch ([[self stationChosen] intValue])
    {
        case 1:
            [bar setTintColor:[UIColor orangeColor]];
            _registerControl = [self getViewControllerFromiPadStoryboardWithName:@"registerPatientViewController"];
            [_segmentedControl setTitle:@"Register" forSegmentAtIndex:0];
            break;
        case 2:
            [bar setTintColor:[UIColor blueColor]];
            _queueControl = [self getViewControllerFromiPadStoryboardWithName:@"registerPatientViewController"];
            [_segmentedControl setTitle:@"Queue" forSegmentAtIndex:0];
            break;
        case 3:
            [bar setTintColor:[UIColor greenColor]];
            _queueControl = [self getViewControllerFromiPadStoryboardWithName:@"registerPatientViewController"];
            [_segmentedControl setTitle:@"Queue" forSegmentAtIndex:0];
            break;
        default:
            break;
    }
}

- (void)pushDashboard
{
    PatientDashboardViewController *viewController = [self getViewControllerFromiPadStoryboardWithName:@"patientDashboardViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)popOverMenu
{
    if(self.pop != nil)
    {
       [self.pop dismissPopoverAnimated:YES];
        self.pop = nil;
        return;
    }
    
    // get datepicker view
    MenuViewController *menuPicker = [self getViewControllerFromiPadStoryboardWithName:@"menuPopover"];
    self.pop = [[UIPopoverController alloc]initWithContentViewController:menuPicker];
    
    // set how the screen should return
    // set the age to the date the screen returns
    [menuPicker setScreenHandler:^(id object, NSError *error)
    {
        [self.pop dismissPopoverAnimated:YES];
    }];
    
    // show the screen beside the button
    CGRect leftBarFrame = CGRectMake(0, 5, 10, 15);
    [self.pop presentPopoverFromRect:leftBarFrame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

//define number of sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//define number of cells in table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

//defines the cells in table
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * registerCellIdentifier = @"registerCell";
    static NSString * searchCellIdentifier = @"searchCell";
    
    if(indexPath.item == 0 && [[self stationChosen] intValue] == 1)
    {
        RegisterPatientTableCell * cell = [tableView dequeueReusableCellWithIdentifier:registerCellIdentifier];
        if(!cell)
        {
            cell = [[RegisterPatientTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:registerCellIdentifier];
            cell.viewController = _registerControl;
        }
        
        _segmentedControl.selectedSegmentIndex = 0;
        
        return [self setupCell:cell forRow:indexPath];
        
    }
    else if(indexPath.item == 1)
    {
        SearchPatientTableCell * cell = [tableView dequeueReusableCellWithIdentifier:searchCellIdentifier];
        
        if(!cell)
        {
            cell = [[SearchPatientTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:searchCellIdentifier];
            cell.viewController = _searchControl;
        }
        _segmentedControl.selectedSegmentIndex = 1;
        
        return [self setupCell:cell forRow:indexPath];
    }
}

- (UITableViewCell*)setupCell:(id)cell forRow:(NSIndexPath*)path
{
    // Rotate view vertically on the screen
    CGAffineTransform transform = CGAffineTransformMakeRotation(1.5707963);
    [cell viewController].view.transform = transform;
    [cell viewController].view.frame = CGRectMake(50, 0, 930, 768);
    
    // Removes previous view (for memory mgmt)
    for(UIView *mView in [[cell contentView] subviews])
    {
        [mView removeFromSuperview];
    }
    
    // Populate view in cell
    [cell addSubview: [cell viewController].view];
    
    [[cell viewController] setScreenHandler:^(id object, NSError *error)
    {
        _patientData = [NSMutableDictionary dictionaryWithDictionary:object];
        
        id newView;
        
        switch ([[self stationChosen] intValue])
        {
            case 1:
                newView = [self getViewControllerFromiPadStoryboardWithName:@"triagePatientViewController"];
                break;
            case 2:
                newView = [self getViewControllerFromiPadStoryboardWithName:@"doctorPatientViewController"];
                break;
            case 3:
                newView = [self getViewControllerFromiPadStoryboardWithName:@"pharmacyPatientViewController"];
                break;
            default:
                break;
        }
        
        [newView setPatientData:_patientData];
        
        [newView setScreenHandler:^(id object, NSError *error)
        {
            [self.navigationController popViewControllerAnimated:YES];
            
            if (!object && error)
            {
                [FIUAppDelegate getNotificationWithColor:AJNotificationTypeRed Animation:AJLinedBackgroundTypeAnimated WithMessage:error.localizedDescription inView:self.view];
            }
            
            [[cell viewController]resetData];
        }];
        [self.navigationController pushViewController:newView animated:YES];
    }];
    return cell;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)offset
{
    int cellHeight = 768;
    
    if(((int)offset->y) % (cellHeight) > cellHeight/2)
    {
        *offset = CGPointMake(offset->x, offset->y + (cellHeight - (((int)offset->y) % (cellHeight))));
        _segmentedControl.selectedSegmentIndex = 1;
    }
    else
    {
        *offset = CGPointMake(offset->x, offset->y - (((int)offset->y) % (cellHeight)));
        //_segmentedControl.selectedSegmentIndex = 0;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setToolbar:nil];
    [self setSegmentedControl:nil];
    [super viewDidUnload];
}

- (IBAction)segmentClicked:(id)sender
{
    switch (_segmentedControl.selectedSegmentIndex)
    {
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

// Hides keyboard when whitespace is pressed
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
@end