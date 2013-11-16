//
//  PatientTable.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 2/27/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
//

#import "PatientTable.h"
#define INNER   @"Inner"
#import "DataProcessor.h"
#import "NSString+Validation.h"
#import "SystemBackup.h"
@interface PatientTable (){
    NSMutableDictionary* selectedVisit;
}
@property(strong)NSArray* patientArray;
@property(strong)NSArray* AllVisitArray;
@property(strong)NSArray* visitArray;
@end

id currentTable;

@implementation PatientTable
@synthesize patientArray,visitArray,patientTableView,visitTableView,AllVisitArray,progressIndicator;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self refreshPatients:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshPatients:) name:UPDATEPATIENT object:nil];
    }
    return self;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    
    NSDictionary* commonDictionary;
    
    id obj;
    
    // If Patient Table
    if([aTableView isEqualTo:patientTableView])
        // Get the patient Dictionary
        commonDictionary =  [patientArray objectAtIndex:rowIndex];
    
    else //If Visitation Table
        commonDictionary = [visitArray objectAtIndex:rowIndex];
    
    // get the value based on table identifier
    obj = [commonDictionary objectForKey:aTableColumn.identifier];
    
    
    if([aTableColumn.identifier isEqualToString:ISOPEN]){
        return ([obj boolValue])?@"In Queue":@"Closed";
    }else if ([aTableColumn.identifier isEqualToString:TRIAGEIN]){
        return [[NSDate convertSecondsToNSDate:obj] convertNSDateToMonthDayYearTimeString];
    }else{
        return obj;
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    if([aTableView isEqualTo:patientTableView])
        return patientArray.count;
    else
        return visitArray.count;
}

-(void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    
    NSDictionary* commonDictionary;
    
    if([tableView isEqualTo:patientTableView]){
        commonDictionary =  [patientArray objectAtIndex:row];
        
    }else{
        commonDictionary = [visitArray objectAtIndex:row];
    }
    
    NSString* lockedBy = [commonDictionary objectForKey:ISLOCKEDBY];
    
    if (lockedBy.length > 0) {
 
        [cell setBackgroundColor:[NSColor redColor]];
    }else{
        [cell setBackgroundColor:[NSColor whiteColor]];
    }
    
}

-(BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row{
    
    
    
    if([tableView isEqualTo:patientTableView]){
        // Clear the Records
        [_visitDocumentation setString:@""];
        
        [visitTableView deselectAll:nil];
        
        //Disable Print Button
        [_printButton setEnabled:NO];
        NSDictionary* patient = [patientArray objectAtIndex:row];
        
        id photo = [patient objectForKey:PICTURE];
        
        // Set Photo
        if (!photo) {
            [_patientPhoto setImage:[NSImage imageNamed:@"PatientData"]];
        }else{
            [_patientPhoto setImage:[[NSImage alloc]initWithData:photo]];
        }
        
        visitArray = [NSArray arrayWithArray:[[[VisitationObject alloc]init]FindAllObjectsUnderParentID:[patient objectForKey:PATIENTID]]];
        
        [visitTableView reloadData];
        
    }else{
        // Enable Print Button
        [_printButton setEnabled:YES];
        [self showDetails:[NSNumber numberWithInteger:row]];
    }
    
    return YES;
}

-(void)controlTextDidChange:(NSNotification *)obj{
   
    NSTextField* textfield = [obj object];
    
    NSString* criteria =  textfield.stringValue;

    if (criteria.length > 0) {
      [self refreshPatients:[NSPredicate predicateWithFormat:@"%K beginswith[c] %@ || %K beginswith[c] %@",FIRSTNAME,criteria,FAMILYNAME,criteria]];
    }else{
        [self findPatientWithCriteria:nil];
    }
    
}

- (IBAction)showDetails:(id)sender {
    
    NSInteger* visitRow = [sender integerValue];
    
    if(visitRow >= 0){
        
        NSDictionary* vRecord = [visitArray objectAtIndex:visitRow];
        
        NSDictionary* pRecord = [patientArray objectAtIndex:patientTableView.selectedRow];
        
        NSArray* array = [NSArray arrayWithArray:[[[PrescriptionObject alloc]init]FindAllObjectsUnderParentID:[vRecord objectForKey:VISITID]]];
        
        NSString* titleString = [NSString stringWithFormat:@"Prescribed Medication: \n\n"];
        
        NSMutableAttributedString* title = [[NSMutableAttributedString alloc]initWithString:titleString];
        
        [title addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"HelveticaNeue-Bold" size:20.0] range:[titleString rangeOfString:titleString]];
        
        //[title setAlignment:NSCenterTextAlignment range:[titleString rangeOfString:titleString]];
        
        NSMutableAttributedString* prescriptString = [[NSMutableAttributedString alloc]initWithAttributedString:title];
        
        for (NSDictionary* dict in array) {
            [prescriptString appendAttributedString:[[[PrescriptionObject alloc]init]printFormattedObject:dict]];
        }
        
        [self displayRecordsForPatient:[[[PatientObject alloc]init]printFormattedObject:pRecord] visit:[[[VisitationObject alloc]init]printFormattedObject:vRecord] andPrescription:prescriptString];
    }
}

-(void)displayRecordsForPatient:(NSAttributedString*)pInfo visit:(NSAttributedString*)vInfo andPrescription:(NSAttributedString*)prInfo{
    
    NSMutableAttributedString* info = [[NSMutableAttributedString alloc]initWithAttributedString:pInfo];
    
    [info appendAttributedString:vInfo];
    [info appendAttributedString:prInfo];
    
    [info addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:NSForegroundColorAttributeName,[NSColor blackColor], nil] range:[info.string rangeOfString:info.string]];
    [_visitDocumentation setString:@""];
    [_visitDocumentation insertText:info];
    
}

- (IBAction)refreshPatients:(id)sender {
    [progressIndicator startAnimation:self];
    patientArray = [self findPatientWithCriteria:([sender isKindOfClass:[NSPredicate class]])?sender:nil];
    [_visitDocumentation setString:@""];
    visitArray = nil;
    [patientTableView reloadData];
    [visitTableView reloadData];
    [progressIndicator stopAnimation:self];
}

-(NSArray*)findPatientWithCriteria:(NSPredicate*)criteria{
    
    NSArray* array = [NSArray arrayWithArray:[[[PatientObject alloc]init]FindAllObjectsUnderParentID:nil]];
    
    if (criteria != nil) {
     return [array filteredArrayUsingPredicate:criteria];
    }
    
    return array;
   
}

- (IBAction)unblockPatients:(id)sender {
    
    NSMutableDictionary* patient = [patientList objectAtIndex:selectedRow];
    
    [patient setValue:@"" forKey:ISLOCKEDBY];
    
    [[[PatientObject alloc]initWithCachedObjectWithUpdatedObject:patient]saveObject:^(id<BaseObjectProtocol> data, NSError *error) {
        //TODO: Code to change color of object Here
    }];
    
}

- (IBAction)getPatientsFromCloud:(id)sender
{
    [progressIndicator startAnimation:self];
    
    [[[PatientObject alloc]init] pullFromCloud:^(id cloudResults, NSError *error)
    {
        if (!cloudResults && error)
        {
            [NSApp presentError:error];
        }
        else
        {
            [[[PatientObject alloc]init] pushToCloud:^(id cloudResults, NSError *error)
            {
                if (error)
                {
                    [NSApp presentError:error];
                }
                else
                {
                    [self refreshPatients:nil];
                }
            }];
        }
        [progressIndicator stopAnimation:self];
    }];
}

- (IBAction)exportPatientData:(id)sender {
    NSSavePanel* savePnl = [NSSavePanel savePanel];
    
    // Set array of file types
    NSArray *fileTypesArray;
    fileTypesArray = [NSArray arrayWithObjects:@"json", nil];
    
    // Enable options in the dialog.
    [savePnl setAllowsOtherFileTypes:NO];
    [savePnl setAllowedFileTypes:fileTypesArray];
    
    // Display the dialog box.  If the OK pressed,
    // process the files.
    if ( [savePnl runModal] == NSOKButton ) {
        
        // Gets list of all files selected
        NSURL *file = [savePnl URL];
        
        NSLog(@"Saving to: %@",file.path);
    }
    
}

- (IBAction)importFile:(id)sender {
    
    // Create a File Open Dialog class.
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    // Set array of file types
    NSArray *fileTypesArray;
    fileTypesArray = [NSArray arrayWithObjects:@"json", nil];
    
    // Enable options in the dialog.
    [openDlg setCanChooseFiles:YES];
    [openDlg setAllowedFileTypes:fileTypesArray];
    [openDlg setAllowsMultipleSelection:NO];
    
    // Display the dialog box.  If the OK pressed,
    // process the files.
    if ( [openDlg runModal] == NSOKButton ) {
        
        // Gets list of all files selected
        NSArray *files = [openDlg URLs];
        
        // Loop through the files and process them.
        NSError* err = nil;
        
        NSDictionary* objects = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:files.lastObject] options:0 error:&err];
        
        if (objects.allKeys.count > 0) {
            [SystemBackup installFromBackup:objects];
            NSLog(@"Imported Object: %@", objects);
        }else{
            NSLog(@"Could not import selected file");
        }
    }
}

- (IBAction)CloseSelectedPatient:(id)sender {
    
    NSInteger pRow = [patientTableView selectedRow];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UPDATEPATIENT object:nil];
    
    if (pRow > -1) {
        NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:[patientArray objectAtIndex:pRow]];
        
        [dict setValue:[NSNumber numberWithBool:NO] forKey:ISOPEN];
        
        PatientObject* pObject = [[PatientObject alloc]initWithCachedObjectWithUpdatedObject:dict];
        
        [pObject saveObject:^(id<BaseObjectProtocol> data, NSError *error) {
            
        }];
    }

        for (NSMutableDictionary* dict in visitArray) {
            [dict setValue:[NSNumber numberWithBool:NO] forKey:ISOPEN];
            
            VisitationObject* vObject = [[VisitationObject alloc]initWithCachedObjectWithUpdatedObject:dict];
            
            [vObject saveObject:^(id<BaseObjectProtocol> data, NSError *error) {
                
            }];

        }
    
    [self refreshPatients:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshPatients:) name:UPDATEPATIENT object:nil];
}

-(void)addJsonFileToDatabase:(id<BaseObjectProtocol>)base fromArray:(NSArray*)array{
    
    //TODO: Add a completed dialog here
    
    /*
     [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
     
     [base setValueToDictionaryValues:obj];
     
     
     [base saveObject:^(id<BaseObjectProtocol> data, NSError *error) {
     
     }];
     }];
     */
}

- (IBAction)printPatient:(id)sender{
    
    if (_visitDocumentation.string.length > 0) {
        
        NSPrintOperation *op = [NSPrintOperation printOperationWithView:_visitDocumentation];
        
        NSPrintInfo* pi = [[NSPrintInfo alloc]init];
        [pi setBottomMargin:1];
        [pi setTopMargin:1];
        [pi setLeftMargin:1];
        [pi setRightMargin:1];
        [pi setVerticallyCentered:NO];
        [pi setHorizontallyCentered:NO];
        [pi setOrientation:NSPortraitOrientation];
        [pi setScalingFactor:1];
        
        [pi setPaperName:@"Letter"];
        [op setPrintInfo:pi];
        [op setShowsPrintPanel:YES];
        
        if (op)
            [op runOperation];
        else{
            //TODO: Show error Dialog here
            NSLog(@"Failed to open print dialog");
        }
    }else{
        
    }
}
@end
