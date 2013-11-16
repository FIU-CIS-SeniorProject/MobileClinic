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
//
#define ALL_USERS   @"all users"
#define DATABASE    @"Users"

#import "UserObject.h"
#import "StatusObject.h"
#import "NSString+Validation.h"
#import "BaseObject+Protected.h"
StatusObject* tempObject;
ObjectResponse classResponder;
NSString* tempUsername;
NSString* tempPassword;

@implementation UserObject

#pragma mark - Default Methods
#pragma mark -

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
-(id)initWithCachedObjectWithUpdatedObject:(NSDictionary *)dic
{
    [self setupObject];
    return [super initWithCachedObjectWithUpdatedObject:dic];
}

-(void)setupObject
{
    self->COMMONID =  USERNAME;
    self->CLASSTYPE = kPatientType;
    self->COMMONDATABASE = DATABASE;
}

-(void)linkDatabase
{
    user = (Users*)self->databaseObject;
}

#pragma mark - User Login & Creation
#pragma mark -

-(void)UpdateObjectAndShouldLock:(BOOL)shouldLock witData:(NSMutableDictionary *)dataToSend AndInstructions:(NSInteger)instruction onCompletion:(ObjectResponse)response
{
    [self UpdateObject:response shouldLock:shouldLock andSendObjects:dataToSend withInstruction:instruction];
}

-(void)loginWithUsername:(NSString*)username andPassword:(NSString*)password onCompletion:(void(^)(id <BaseObjectProtocol> data, NSError* error, Users* userA))onSuccessHandler
{
    username = [username lowercaseString];
    // Sync all the users from server to the client
    [self getUsersFromServer:^(id<BaseObjectProtocol> data, NSError *error)
    {
        // Try to find user from username in local DB
        BOOL didFindUser = [self loadObjectForID:username];
        
        // link databaseObject to convenience Object named "user" 
        [self linkDatabase];
        
        // if we find the user locally then....
        if (didFindUser)
        {
            // Check if the user has permissions
            if (user.status.boolValue)
            {
                // Check credentials against the found user
                if ([user.password isEqualToString:password])
                {
                    onSuccessHandler(self,nil, user);
                }
                // If incorrect password then throw an error
                else
                {
                    onSuccessHandler(Nil,[self createErrorWithDescription:@"Username & Password combination is incorrect" andErrorCodeNumber:kErrorIncorrectLogin inDomain:self->COMMONDATABASE], user);
                }
            }
            // If the user doesn't have permission, throw an error
            else
            {
                onSuccessHandler(Nil,[self createErrorWithDescription:@"You do not have permission to login. Please contact you application administrator" andErrorCodeNumber:kErrorPermissionDenied inDomain:self->COMMONDATABASE], user);
            }
        }
        // if we cannot find the user, throw an error
        else
        {
            onSuccessHandler(Nil,[self createErrorWithDescription:@"The user does not exists" andErrorCodeNumber:kErrorUserDoesNotExist inDomain:self->COMMONDATABASE], user);
        }
    }];
}

-(void)getUsersFromServer:(ObjectResponse)withResponse
{
    NSMutableDictionary* dataToSend = [[NSMutableDictionary alloc]initWithCapacity:2];
    [dataToSend setValue:[NSNumber numberWithInt:kPullAllUsers] forKey:OBJECTCOMMAND];
    [dataToSend setValue:[NSNumber numberWithInt:kUserType] forKey:OBJECTTYPE];
    [self SendData:dataToSend toServerWithErrorMessage:@"Could not connect to server. Validating against cache" andResponse:withResponse];
}

#pragma mark- Private Methods
#pragma mark-

-(NSArray *)FindAllObjectsLocally
{
    return [self convertListOfManagedObjectsToListOfDictionaries:[self FindObjectInTable:DATABASE withCustomPredicate:nil andSortByAttribute:USERNAME]];
}
@end