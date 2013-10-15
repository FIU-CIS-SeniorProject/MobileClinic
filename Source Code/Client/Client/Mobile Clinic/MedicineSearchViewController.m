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
//  MedicineSearchViewController.m
//  Mobile Clinic
//
//  Created by Steven Berlanga on 2/24/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//
#import "MedicineSearchViewController.h"
#import "MobileClinicFacade.h"

@interface MedicineSearchViewController ()
{
    NSMutableArray *medicationArray;
    NSMutableArray *searchResultArray;
}
@end

@implementation MedicineSearchViewController

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
    
    MobileClinicFacade *mobileFacade = [[MobileClinicFacade alloc]init];
    
    // Request all medications in database
    [mobileFacade findAllMedication:nil AndOnCompletion:^(NSArray *allObjectsFromSearch, NSError *error)
     {
        NSLog(@"All Medications:%@",allObjectsFromSearch.description);
        medicationArray = [NSArray arrayWithArray:allObjectsFromSearch];
        searchResultArray = [NSArray arrayWithArray:allObjectsFromSearch];
        
        //[searchResultArray filterUsingPredicate:[NSPredicate predicateWithFormat:@"%K != nil",MEDNAME]];
        [_tableView reloadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)moveBackToPrescription:(id)sender
{
    //    [self.prescriptionData setObject:[NSNumber numberWithInt:[self.tableView indexPathForSelectedRow].row] forKey:MEDICATIONID];
    //    [self.prescriptionData setObject:@"poo" forKey:MEDICATIONID];
    [[NSNotificationCenter defaultCenter] postNotificationName:MOVE_FROM_SEARCH_FOR_MEDICINE object:_prescriptionData];
}

- (void)viewDidUnload
{
    [self setMedicineField:nil];
    [self setTableView:nil];
    [super viewDidUnload];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //    return medicationArray.count;
    return searchResultArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MedicineSearchResultCell * cell = [tableView dequeueReusableCellWithIdentifier:@"medicineResult"];

    if(!cell)
    {
        cell = [[MedicineSearchResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"medicineResult"];
        UINib * mNib = [UINib nibWithNibName:@"MedicineSearchResultView" bundle:nil];
        cell = [mNib instantiateWithOwner:nil options:nil][0];
    }

    NSDictionary *medDic = [searchResultArray objectAtIndex:indexPath.row];
    
    cell.medicineName.text = [medDic objectForKey:MEDNAME];
    cell.medicineDose.text = [medDic objectForKey:DOSAGE];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Display get medication at the specified index
    NSDictionary *myDic = [searchResultArray objectAtIndex:indexPath.row];
    
    // get desired values
    NSString *medName = [myDic objectForKey:MEDNAME];
    NSString *dosage = [myDic objectForKey:DOSAGE];
    
    // Construct a text
    _medicineField.text = [NSString stringWithFormat:@"%@ %@", medName, dosage];
    
    // Create Prescription Dictionary
    // NSMutableDictionary *prescriptionData = [[NSMutableDictionary alloc] init];
    
    // !!!: should reconsider implementation
    // Save medicationId in Prescription dictionary
    [_prescriptionData setValue:[myDic objectForKey:MEDICATIONID] forKey:MEDICATIONID];
    
    // Send prescription back
    // [[NSNotificationCenter defaultCenter] postNotificationName:MOVE_FROM_SEARCH_FOR_MEDICINE object:_prescriptionData];
}

- (IBAction)searchMedicine:(id)sender
{
    searchResultArray = [NSArray arrayWithArray:medicationArray];

    if(![_medicineField.text isEqualToString:@""])
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", MEDNAME, _medicineField.text];
        searchResultArray = [NSMutableArray arrayWithArray:[searchResultArray filteredArrayUsingPredicate:predicate]];
    }
    
    [_tableView reloadData];
}

// Hides keyboard when whitespace is pressed
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
@end