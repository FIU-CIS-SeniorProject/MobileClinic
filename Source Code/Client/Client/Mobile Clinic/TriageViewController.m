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
//  TriageViewController.m
//  Mobile Clinic
//
//  Created by sebastian a zanlongo on 2/18/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//
#import "TriageViewController.h"
#import "TriagePatientViewController.h"

@interface TriageViewController ()

@end

@implementation TriageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UINavigationBar *bar = [self.navigationController navigationBar];
    [bar setTintColor:[UIColor orangeColor]];
    
    // Rotate table horizontally (-90 degrees)
    CGAffineTransform transform = CGAffineTransformMakeRotation(-1.5707963);
    _tableView.rowHeight = 768;
    _tableView.transform = transform;
    
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _tableView.frame = self.view.frame;
    [_tableView setShowsVerticalScrollIndicator:NO];
    
    // Create controllers for each view (Search & Register)
    _registerControl = [self getViewControllerFromiPadStoryboardWithName:@"registerPatientViewController"];
    //    [_registerControl view];
    _searchControl = [self getViewControllerFromiPadStoryboardWithName:@"searchPatientViewController"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

// Transfers the patient's data to the next view controller
- (void)transferPatientData:(NSMutableDictionary *)note
{
    _patientData = [NSMutableDictionary dictionaryWithDictionary:note];
    
    TriagePatientViewController *newView = [self getViewControllerFromiPadStoryboardWithName:@"triagePatientViewController"];

    [newView setPatientData:_patientData];
    [self.navigationController pushViewController:newView animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self setTableView:nil];
    [self setToolBar:nil];
    [super viewDidUnload];
}

// Defines number of sections
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// Defines number of cells in table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

// Defines the cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * registerCellIdentifier = @"registerCell";
    static NSString * searchCellIdentifier = @"searchCell";
    
    if(indexPath.item == 0)
    {
        RegisterPatientTableCell * cell = [tableView dequeueReusableCellWithIdentifier:registerCellIdentifier];
        
        if(!cell)
        {
            cell = [[RegisterPatientTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:registerCellIdentifier];
            cell.viewController = _registerControl;
        }
        
        [_segmentedControl setEnabled:YES forSegmentAtIndex:0];
        
        _segmentedControl.selectedSegmentIndex = 0;
        
        return [self setupCell:cell forRow:indexPath];
        
    }
    else
    {
        SearchPatientTableCell * cell = [tableView dequeueReusableCellWithIdentifier:searchCellIdentifier];
        
        if(!cell)
        {
            cell = [[SearchPatientTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:searchCellIdentifier];
            cell.viewController = _searchControl;
        }
        
        [_segmentedControl setEnabled:YES forSegmentAtIndex:1];
        _segmentedControl.selectedSegmentIndex = 1;
        return [self setupCell:cell forRow:indexPath];
    }
}

-(UITableViewCell*)setupCell:(id)cell forRow:(NSIndexPath*)path
{
    // Rotate view vertically on the screen
    CGAffineTransform transform = CGAffineTransformMakeRotation(1.5707963);
    [cell viewController].view.transform = transform;
    [cell viewController].view.frame = CGRectMake(50, 0, 916, 768);
    
    // Removes previous view (for memory mgmt)
    for(UIView *mView in [[cell contentView] subviews])
    {
        [mView removeFromSuperview];
    }
    
    // Populate view in cell
    [cell addSubview: [cell viewController].view];
    
    // This is where the information that the screen handler uses to manipulate the screens
    [[cell viewController] setScreenHandler:^(id object, NSError *error)
    {
        // TODO: check & show error message
        _patientData = [NSMutableDictionary dictionaryWithDictionary:object];
        
        TriagePatientViewController *newView = [self getViewControllerFromiPadStoryboardWithName:@"triagePatientViewController"];

        [newView setPatientData:_patientData];
        
        [newView setScreenHandler:^(id object, NSError *error)
        {
            [self.navigationController popViewControllerAnimated:YES];
            if (error)
            {
                [FIUAppDelegate getNotificationWithColor:AJNotificationTypeRed Animation:AJLinedBackgroundTypeAnimated WithMessage:error.localizedDescription inView:self.view];
            }
            [[cell viewController]resetData];
        }];
        
        [self.navigationController pushViewController:newView animated:YES];
        
        if (error)
        {
            [FIUAppDelegate getNotificationWithColor:AJNotificationTypeRed Animation:AJLinedBackgroundTypeAnimated WithMessage:error.localizedDescription inView:newView.view];
        }
    }];
    
    // NOT SURE WHAT THIS DOES
    _segmentedControl.selectedSegmentIndex = 1;
    
    return cell;
}

// Allows user to user segment to switch views (cells)
- (IBAction) segmentedControlIndexChanged
{
    switch (self.segmentedControl.selectedSegmentIndex)
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

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)offset
{
    int cellHeight = 768;
    
    if(((int)offset->y) % (cellHeight) > cellHeight/2)
    {
        *offset = CGPointMake(offset->x, offset->y + (cellHeight - (((int)offset->y) % (cellHeight))));
        self.segmentedControl.selectedSegmentIndex = 1;
    }
    else
    {
        *offset = CGPointMake(offset->x, offset->y - (((int)offset->y) % (cellHeight)));
        self.segmentedControl.selectedSegmentIndex = 0;
    }
}

// Hides keyboard when whitespace is pressed
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
@end