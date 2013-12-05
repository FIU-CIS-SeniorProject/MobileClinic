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
//  UserObject.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 1/27/13.
//  Modified by Kevin Diaz on 11/23/13.
//

/* NOTE ABOUT THIS CLASS
 * Make user you call super for any of the methods that are part of the BaseObjectProtocol
 */

// These are elements within the database
// This prevents hardcoding
#define DATABASE    @"Users"

#import "Users.h"
#import "UserObject.h"
#import "NSString+Validation.h"
#import "BaseObject+Protected.h"

@implementation UserObject

+(NSString *)DatabaseName
{
    return DATABASE;
}

- (id)init
{
    [self setupObject];
    return [super init];
}

-(id)initAndMakeNewDatabaseObject
{
    [self setupObject];
    return [super initAndMakeNewDatabaseObject];
}

- (id)initAndFillWithNewObject:(NSDictionary *)info
{
    [self setupObject];
    return [super initAndFillWithNewObject:info];
}

-(id)initWithCachedObjectWithUpdatedObject:(NSDictionary *)dict
{
    [self setupObject];
    return [super initWithCachedObjectWithUpdatedObject:dict];
}

-(void)setupObject
{
    self->COMMONID =  USERNAME;
    self->CLASSTYPE = kUserType;
    self->COMMONDATABASE = DATABASE;
}

-(void)linkDatabase
{
    user = (Users*)self->databaseObject;
}

#pragma mark - BaseObjectProtocol Methods
#pragma mark -

//TODO: Add error creator to base object
/* The super needs to be called first */
-(NSDictionary *)consolidateForTransmitting
{
    NSMutableDictionary* consolidate = [[NSMutableDictionary alloc]initWithDictionary:[super consolidateForTransmitting]];
    
    [consolidate setValue:[NSNumber numberWithInt:kUserType] forKey:OBJECTTYPE];
    
    return consolidate;
}

-(void)ServerCommand:(NSDictionary *)dataToBeRecieved withOnComplete:(ServerCommand)response
{
    [super ServerCommand:nil withOnComplete:response];
    [self unpackageFileForUser:dataToBeRecieved];
    [self CommonExecution];
}

/* Depending on the RemoteCommands it will execute a different Command */
-(void)CommonExecution
{
    switch (self->commands)
    {
        case kAbort:
            NSLog(@"Error: User Object Misconfiguration handled by baseObject");
            break;
        case kPullAllUsers: 
            [self sendSearchResults:[self FindAllObjects]];
            break;
        case kLoginUser:
            [self ValidateAndLoginUser];
            break;
        case kLogoutUser:
            break;
        default:
            [self sendInformation:nil toClientWithStatus:kErrorBadCommand andMessage:@"Server recieved a bad command"];
            break;
    }
}

#pragma mark - COMMON OBJECT Methods
#pragma mark -

-(NSArray *)FindAllObjects
{
    return [self convertListOfManagedObjectsToListOfDictionaries:[self FindObjectInTable:DATABASE withCustomPredicate:nil andSortByAttribute:USERNAME]];
}

-(NSArray *)FindAllObjectsUnderParentID:(NSString *)parentID
{
    return [self FindAllObjects];
}

-(NSString *)printFormattedObject:(NSDictionary *)object
{
    return @"Not Implemented Yet";
}

#pragma mark- Public Methods
#pragma mark-

//TODO: Not implemented??
-(void)pushToCloud:(CloudCallback)onComplete
{
    onComplete(nil,[[NSError alloc]initWithDomain:COMMONDATABASE code:kErrorObjectMisconfiguration userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"This feature is not implemented",NSLocalizedFailureReasonErrorKey, nil]]);
}

-(void)pullFromCloud:(CloudCallback)onComplete{
    
    //TODO: Remove Hard Dependencies
    [self makeCloudCallWithCommand:DATABASE withObject:nil onComplete:^(id cloudResults, NSError *error)
    {
        if (!error)
        {
            NSArray* users = [cloudResults objectForKey:@"data"];
            
            NSArray* allError = [self SaveListOfObjectsFromDictionary:users];
            
            if (allError.count > 0)
            {
                error = [[NSError alloc]initWithDomain:COMMONDATABASE code:kErrorObjectMisconfiguration userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Object was misconfigured",NSLocalizedFailureReasonErrorKey, nil]];
                onComplete(self,error);
                return;
            }
        }
        onComplete((!error)?self:nil,error);
    }];
}

#pragma mark - Private Methods
#pragma mark -

//TODO: Same user object used twice?
-(void)ValidateAndLoginUser
{
    // Initially set it to an error, for efficiency.
    [status setStatus:kError];
    
    NSArray* userArray = [self FindObjectInTable:DATABASE withName:user.userName forAttribute:USERNAME];
    
    NSArray* filtered = [userArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K == %@",USERNAME,user.userName]];
    
    // Checks if username exists (should return 1 or 0 value)
    if (filtered.count == 0 || filtered.count > 1)
    {
        // Its good to send a message
        [status setErrorMessage:@"Username doesnt Exist or was incorrect"];
        // Let the status object send this information
        NSLog(@"Username doesnt Exist or was incorrect");
    }
    else
    {
        // Validate with information inside database
        user = [filtered objectAtIndex:0];
        
        if (![user.password isEqualToString:user.password])
        {
            // Its good to send a message
            [status setErrorMessage:@"User Password is incorrect"];
            NSLog(@"User Password is incorrect");
        }
        else if (!user.status.boolValue)
        {
            // Its good to send a message
            [status setErrorMessage:@"Please contact your Application Administator to Activate your Account"];
            NSLog(@"User is inactive");
        }
        
        // status will hold a copy of this user data
        [status setData:[self consolidateForTransmitting]];
        
        // Indicates that this was a success
        [status setStatus:kSuccess];
        
        // Its good to send a message
        [status setErrorMessage:@"Login Successfull"];
    }
    
    commandPattern([status consolidateForTransmitting]);
}

//TODO: Allow login even without cloud connection
//-(void)loginWithUsername:(NSString*)username andPassword:(NSString*)password onCompletion:(void(^)(id <BaseObjectProtocol> data, NSError* error, Users* userA))onSuccessHandler
-(void)loginWithUsername:(NSString*)username andPassword:(NSString*)password onCompletion:(void(^)(id <BaseObjectProtocol> data, NSError* error, NSDictionary* userDict))onSuccessHandler
{
    username = [username lowercaseString];
    
    // Try to find user from username in local DB
    NSArray* userArray = [[self FindAllObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K == %@", USERNAME, username]];
    NSDictionary* theUser;
    
    // if we find the user locally then....
    if (userArray.count == 1)
    {
        theUser = [userArray objectAtIndex:0];
        
        // Check if the user has permissions
        if ([[theUser valueForKey:STATUS] boolValue] && [[theUser valueForKey:USERTYPE] integerValue] == 3)
        {
            // Check credentials against the found user
            if ([[theUser valueForKey:PASSWORD] isEqualToString:password])
            {
                //return with success
                onSuccessHandler(self,nil, theUser);
            }
            // If incorrect password then throw an error
            else
            {
                onSuccessHandler(Nil,[self createErrorWithDescription:@"Username & Password combination is incorrect" andErrorCodeNumber:kErrorIncorrectLogin inDomain:self->COMMONDATABASE], theUser);
            }
        }
        // If the user doesn't have permission, throw an error
        else
        {
            onSuccessHandler(Nil,[self createErrorWithDescription:@"You do not have permission to login. Please contact you application administrator" andErrorCodeNumber:kErrorPermissionDenied inDomain:self->COMMONDATABASE], theUser);
        }
    }
    // if we cannot find the user, throw an error
    else
    {
        onSuccessHandler(Nil,[self createErrorWithDescription:@"The user does not exist" andErrorCodeNumber:kErrorUserDoesNotExist inDomain:self->COMMONDATABASE], theUser);
    }
}

-(NSArray *)covertAllSavedObjectsToJSON
{
    NSArray* allPatients= [self FindObjectInTable:COMMONDATABASE withCustomPredicate:[NSPredicate predicateWithFormat:@"%K == YES",ISDIRTY] andSortByAttribute:USERNAME];
    NSMutableArray* allObject = [[NSMutableArray alloc]initWithCapacity:allPatients.count];
    
    for (NSManagedObject* obj in allPatients)
    {
        [allObject addObject:[obj dictionaryWithValuesForKeys:[obj attributeKeys]]];
    }
    return  allObject;
}
@end