//
//  FaceRecognizer.mm
//  Mobile Clinic
//
//  Created by Humberto Suarez on 10/22/13.
//  Copyright (c) 2013 Steven Berlanga. All rights reserved.
//

#import "FaceRecognizer.h"
#import "DataR.h"
#import "Face.h"
#import <sqlite3.h>
#import <CoreData/CoreData.h>
#import "DatabaseDriver.h"

NSManagedObjectContext* context1;
NSDictionary* faceD;

@implementation FaceRecognizer
@synthesize database;

- (id)init
{
    self = [ super init];
    database = [Database sharedInstance];
    context1 = database.managedObjectContext;
    if (self) {
        //[self loadDatabase];
    }
    
    return self;
}

- (id)initWithEigenFaceRecognizer
{
    self = [self init];
    _model = cv::createEigenFaceRecognizer(9,1200.0);
    
    return self;
}

- (id)initWithFisherFaceRecognizer
{
    self = [self init];
    //_model = cv::createFisherFaceRecognizer();
    
    return self;
}

- (id)initWithLBPHFaceRecognizer
{
    self = [self init];
    //_model = cv::createLBPHFaceRecognizer();
    
    return self;
}

- (void)loadDatabase
{
    /*if (sqlite3_open([[self dbPath] UTF8String], &_db) != SQLITE_OK) {
        NSLog(@"Cannot open the database.");
    }
    [self getAllPeople];
    [self createTablesIfNeeded];*/
}

/*- (NSString *)dbPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:@"training-data.sqlite"];
}

- (int)newPersonWithName:(NSString *)name
 {
 const char *newPersonSQL = "INSERT INTO people (name) VALUES (?)";
 sqlite3_stmt *statement;
 
 if (sqlite3_prepare_v2(_db, newPersonSQL, -1, &statement, nil) == SQLITE_OK) {
 sqlite3_bind_text(statement, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
 sqlite3_step(statement);
 }
 
 sqlite3_finalize(statement);
 
 return sqlite3_last_insert_rowid(_db);
 }
 
- (NSMutableArray *)getAllPeople
{
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    const char *findPeopleSQL = "SELECT personid,name FROM person ORDER BY name";//"SELECT id, name FROM people ORDER BY name";
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(_db, findPeopleSQL, -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSNumber *personID = [NSNumber numberWithInt:sqlite3_column_int(statement, 0)];
            NSString *personName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
            NSLog(@"person name: %@ person id: %@",personName,personID);
            [results addObject:@{@"id": personID, @"name": personName}];
        }
    }
    
    sqlite3_finalize(statement);
 
    return results;
}
*/
- (BOOL)trainModel
{
    std::vector<cv::Mat> images;
    std::vector<int> labels;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Faces" inManagedObjectContext:context1];
    [fetchRequest setEntity:entity];
   
    NSError *error = nil;
    NSArray *array = [context1 executeFetchRequest:fetchRequest error:&error];
    if(array ==nil)
    {
        NSLog(@"Problem ! @%",error);
    }
    
    for(Face *c in array)
    {
         int label = c.label.intValue;
         NSData *imageD = c.photo;
         cv::Mat faceData = [DataR dataToMat:imageD
                                      width:[NSNumber numberWithInt:100]
                                     height:[NSNumber numberWithInt:100]];
         images.push_back(faceData);
         labels.push_back(label);
    }
    if (images.size() > 0 && labels.size() > 0) {
        _model->train(images, labels);
        return YES;
    }
    else {
        return NO;
    }
}

- (void)forgetAllFacesForPersonID:(int)personID
{
   /* const char* deleteSQL = "DELETE FROM person WHERE personid = ?";
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(_db, deleteSQL, -1, &statement, nil) == SQLITE_OK) {
        sqlite3_bind_int(statement, 1, personID);
        sqlite3_step(statement);
    }
    
    sqlite3_finalize(statement);*/
}
/*
- (void)learnFace:(cv::Rect)face ofPersonName:(NSString *)name fromImage:(cv::Mat&)image//(int)personID fromImage:(cv::Mat&)image
{
    cv::Mat faceData = [self pullStandardizedFace:face fromImage:image];
    NSData *serialized = [DataR serializeCvMat:faceData];
    int pid =4;
   
    const char* insertSQL = "INSERT INTO person (name, image, personid) VALUES (?, ?,?)";//"INSERT INTO images (person_id, image) VALUES (?, ?)";
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(_db, insertSQL, -1, &statement, nil) == SQLITE_OK) {
        sqlite3_bind_text(statement,1,[name UTF8String], -1, SQLITE_TRANSIENT);//(statement, 1, name);//personID);
        sqlite3_bind_blob(statement, 2, serialized.bytes, serialized.length, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 3, pid);
        sqlite3_step(statement);
        //NSLog(@"person id %i",personID);
    }

    sqlite3_finalize(statement);
}
*/
- (cv::Mat)pullStandardizedFace:(cv::Rect)face fromImage:(cv::Mat&)image
{
    // Pull the grayscale face ROI out of the captured image
    cv::Mat onlyTheFace;
    cv::cvtColor(image(face), onlyTheFace, CV_RGB2GRAY);
    // Standardize the face to 100x100 pixels
    cv::resize(onlyTheFace, onlyTheFace, cv::Size(100, 100), 0, 0);
    return onlyTheFace;
}

- (NSDictionary *)recognizeFace:(cv::Rect)face inImage:(cv::Mat&)image
{
    int predictedLabel = -1;
    double confidence = 0.0;
    
    _model->predict([self pullStandardizedFace:face fromImage:image], predictedLabel, confidence);
    
    NSString *firstName = @"";
    NSString *familyName =@"";
    if(predictedLabel )

   if (predictedLabel != -1) {
      
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Faces" inManagedObjectContext:context1];
        [fetchRequest setEntity:entity];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@" label == %i",predictedLabel];
        NSError *error = nil;
        NSArray *array = [context1 executeFetchRequest:fetchRequest error:&error];
        if(array ==nil)
        {
            NSLog(@"Problem ! @%",error);
        }
       
        for(Face *c in array)
        {
            firstName = c.firstName;
            familyName = c.familyName;
        }
        }
           return @{
             @"personID": [NSNumber numberWithInt:predictedLabel],
             @"firstName": firstName,
             @"familyName": familyName,
             @"confidence": [NSNumber numberWithDouble:confidence]
             };
}

- (void)createTablesIfNeeded
{
   /* // People table
    const char *peopleSQL = "CREATE TABLE IF NOT EXISTS people ("
    "'id' integer NOT NULL PRIMARY KEY AUTOINCREMENT, "
    "'name' text NOT NULL)";
    
    if (sqlite3_exec(_db, peopleSQL, nil, nil, nil) != SQLITE_OK) {
        NSLog(@"The people table could not be created.");
    }
    
    // Images table
    const char *imagesSQL = "CREATE TABLE IF NOT EXISTS images ("
    "'id' integer NOT NULL PRIMARY KEY AUTOINCREMENT, "
    "'person_id' integer NOT NULL, "
    "'image' blob NOT NULL)";
    
    if (sqlite3_exec(_db, imagesSQL, nil, nil, nil) != SQLITE_OK) {
        NSLog(@"The images table could not be created.");
    }*/
}

@end
