//
//  UserObject.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 1/27/13.
//  Copyright (c) 2013 Florida International University. All rights reserved.
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

+(NSString *)DatabaseName{
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

-(void)setupObject{
    
    self->COMMONID =  USERNAME;
    self->CLASSTYPE = kPatientType;
    self->COMMONDATABASE = DATABASE;
}

-(void)linkDatabase{
    user = (Users*)self->databaseObject;
}

#pragma mark - User Login & Creation
#pragma mark -

-(void)UpdateObjectAndShouldLock:(BOOL)shouldLock witData:(NSMutableDictionary *)dataToSend AndInstructions:(NSInteger)instruction onCompletion:(ObjectResponse)response{
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
-(UserTypes)getUsertypeForCurrentUser{
  
    NSArray* users = [self FindObjectInTable:DATABASE withName:[BaseObject getCurrentUserName] forAttribute:USERNAME];
   
    if (users.count > 0) {
        Users* localUser = users.lastObject;
        return localUser.userType.integerValue;
    }
    
    return -1;
}

-(void)getUsersFromServer:(ObjectResponse)withResponse
{
    NSMutableDictionary* dataToSend = [[NSMutableDictionary alloc]initWithCapacity:2];
    [dataToSend setValue:[NSNumber numberWithInt:kPullAllUsers] forKey:OBJECTCOMMAND];
    [dataToSend setValue:[NSNumber numberWithInt:kUserType] forKey:OBJECTTYPE];
    [self SendData:dataToSend toServerWithErrorMessage:@"Could not connect to server. Validating against cache" andResponse:withResponse];

}

-(NSArray *)FindAllObjectsLocally
{
    return [self convertListOfManagedObjectsToListOfDictionaries:[self FindObjectInTable:DATABASE withCustomPredicate:nil andSortByAttribute:FIRSTNAME]];
}

@end
