//
//  EditVisit.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 5/8/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//
@protocol EditVisitDelegate <NSObject>

-(void)updatedVisit:(NSMutableDictionary*)updatedVisit;
@end
#import <UIKit/UIKit.h>

@interface EditVisit : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *systolicField;
@property (weak, nonatomic) IBOutlet UITextField *diastolicField;
@property (weak, nonatomic) IBOutlet UITextField *heartField;
@property (weak, nonatomic) IBOutlet UITextField *respirationField;
@property (weak, nonatomic) IBOutlet UITextField *tempField;
@property (weak, nonatomic) IBOutlet UITextField *weight;
@property (weak, nonatomic) IBOutlet UITextField *conditionTitleField;
@property (strong, nonatomic) IBOutlet UITextView *conditionsTextbox;
@property (strong, nonatomic) NSMutableDictionary* visitData;
@property (weak, nonatomic) id<EditVisitDelegate>delegate;
- (IBAction)saveandClose:(id)sender;

@end
