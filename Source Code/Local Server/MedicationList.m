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
//  MedicationList.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 3/16/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//
#import "MedicationList.h"

@interface MedicationList ()
@property(strong)NSArray* allMedication;
@end

@implementation MedicationList
@synthesize allMedication;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setupView:nil];
    }
    
    return self;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    NSDictionary* medication = [allMedication objectAtIndex:rowIndex];
    
    return [medication objectForKey:aTableColumn.identifier]; 
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    NSInteger list = allMedication.count;
    return list;
}

-(BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row{

    return YES;
}

- (IBAction)destructiveResync:(id)sender
{
    [[[MedicationObject alloc]init] pullFromCloud:^(id cloudResults, NSError *error)
    {
        if (error)
        {
            [NSApp presentError:error];
        }
        
        [self setupView:nil];
    }];
}

- (IBAction)setupView:(id)sender
{
    allMedication = [NSArray arrayWithArray:[[[MedicationObject alloc]init] FindAllObjects]];
    [_tableView reloadData];
}
@end