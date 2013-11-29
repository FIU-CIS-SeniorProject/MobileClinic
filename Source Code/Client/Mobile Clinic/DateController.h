//
//  DateController.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 2/11/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScreenNavigationDelegate.h"
@interface DateController : UIViewController{
    ScreenHandler handler;
}

@property (weak, nonatomic) IBOutlet UITextField *dateLbl;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

- (IBAction)saveNewDate:(id)sender;
- (void)setScreenHandler:(ScreenHandler)screenDelegate;
@end
