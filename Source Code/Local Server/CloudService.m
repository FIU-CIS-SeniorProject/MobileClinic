//
//  CloudService.m
//  Mobile Clinic
//
//  Created by Michael Montaque on 3/15/13.
//  Edited by Kevin Diaz on 11/2013
//

#import "CloudService.h"
#import "CloudManagementObject.h"
#import "NSMutableData-AES.h"
#import <IOKit/IOKitLib.h>
//#import <CommonCrypto/CommonCryptor.h>

@interface CloudService()
{
    NSString *kURL;
    NSString *kAccessToken;
    BOOL isAuthenticated;
    NSString *kApiKey;
}
@end

@implementation CloudService

#pragma mark - Cloud API
#pragma mark-

+(CloudService *) cloud
{
    static CloudService *mApi = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mApi = [[self alloc]init];
    });
    
    return mApi;
}

-(NSString*)stringWithMachineSerialNumber
{
    NSString* result = nil;
    CFStringRef serialNumber = NULL;
    
    io_service_t platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault,IOServiceMatching("IOPlatformExpertDevice"));
    
    if (platformExpert)
    {
        CFTypeRef serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert,CFSTR(kIOPlatformSerialNumberKey),kCFAllocatorDefault,0);
        serialNumber = (CFStringRef)serialNumberAsCFString;
        IOObjectRelease(platformExpert);
    }
    
    if (serialNumber)
        result = (NSString*)CFBridgingRelease(serialNumber);
    else
        result = @"unknown";
    return result;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        //TODO: Use serialNumber as kApiKey when cloud allows for local server registration.
        NSString* serialNumber = [self stringWithMachineSerialNumber];
        NSLog(@"Serial Number: %@", serialNumber);
        
        //kApiKey = @"12345";
        kApiKey = serialNumber;
        kAccessToken = @"";
        isAuthenticated = NO;
        
        //TODO: gets url of active cloud server (causes infinite loop with init)
        //kURL = [[[CloudManagementObject alloc] init] GetActiveURL];
    
        //kURL = @"http://pure-island-5858.herokuapp.com/"; // Production Cloud
        kURL = @"http://still-citadel-8045.herokuapp.com/"; // Test Cloud
        
        //kURL = @"http://localhost:3000/"; // local host for testing the Cloud Server
        //kURL = @"http://staging-webapp.herokuapp.com/";
        //kURL = @"http://znja-webapp.herokuapp.com/api/";
        
        [self getAccessToken:^(BOOL success)
        {
            if(success)
            {
                NSLog(@"Connected To Cloud");
            }
            else
            {
                NSLog(@"Could Not Connect To Cloud");
            }
        }];
    }
    return self;
}

-(void)getAccessToken:(void(^)(BOOL success)) completion
{
    NSMutableDictionary * params = [[NSMutableDictionary alloc]init];
    [params setObject:kApiKey forKey:@"api_key"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURL *url = [NSURL  URLWithString:[NSString stringWithFormat:@"%@%@", kURL, @"auth/access_token"]];
        
        NSData *data;
        
        if (params)
        {
            NSData *json = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
            
            data = [[NSString stringWithFormat:@"%@%@",
                     @"&params=",[[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding] ]
                    dataUsingEncoding: NSUTF8StringEncoding];
        }
        else
        {
            data = [[NSString stringWithFormat:@"%@",@""] dataUsingEncoding: NSUTF8StringEncoding];
        }
        
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
        
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody: data];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
         {
             NSError *jsonError;
             //NSLog(@"CloudService: getAccessToken: sendAsynchronousRequest: %@", data);
             
             // If we get nil data, the application crashes on
             //JSONObjectWithData:data, alloc and init data
             if (data == nil)
             {
                 data = [[NSData alloc] init];
             }
             
             NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
             
             //if(!error) //Not getting an error from the cloud, getting "result: false" instead
             if (!jsonError && [[json objectForKey:@"result"] isEqualToString:@"true"])
             {
                
                 //read and print the server response for debug
                NSString *myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"CloudService.m: myString printed: %@", myString);
                
                if ((completion && json) || (completion && jsonError))
                {
                    if ([[json objectForKey:@"data"] isKindOfClass:[NSString class]])
                    {
                        completion(NO);
                    }
                    else
                    {
                        kAccessToken = [[json objectForKey:@"data"] objectForKey:@"access_token"];
                        NSLog(@"CloudService.m: AccessToken: %@", kAccessToken);
                        completion(YES);
                    }
                }
            }
            else if (!jsonError)
            {
                NSLog(@"Error data from Cloud: %@", [json objectForKey:@"data"]);
                completion(NO);
            }
            
        }];
        
    });
}

-(void)query:(NSString *)stringQuery parameters: (NSDictionary *)params completion:(void(^)(NSError *error, NSDictionary *result)) completion
{
    NSMutableDictionary *mDic = [[NSMutableDictionary alloc]initWithDictionary:params];
    [mDic setObject:kAccessToken forKey:@"access_token"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self queryWithPartialURL:[NSString stringWithFormat:@"api/%@", stringQuery] parameters:mDic completion:completion];
        
    });
}

-(void)query:(NSString *)stringQuery parameters: (NSDictionary *)params imageData:(NSData *)imageData completion:(void(^)(NSError *error, NSDictionary *result)) completion
{
    NSMutableDictionary *mDic = [[NSMutableDictionary alloc]initWithDictionary:params];
    [mDic setObject:kAccessToken forKey:@"access_token"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),  ^{
        
        [self queryWithPartialURL:[NSString stringWithFormat:@"api/%@", mDic] parameters:params imageData:imageData completion:completion];
        
    });
    
}

-(void)queryWithPartialURL:(NSString *)partialURL parameters: (NSDictionary *)params imageData:(NSData *)imageData completion:(void(^)(NSError *error, NSDictionary *result)) completion
{
    //    [[NSApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
    
    NSURL *url = [NSURL  URLWithString:[NSString stringWithFormat:@"%@%@", kURL, partialURL]];
    
    
    //////////////////////////////////////////////////////
    NSData *json = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    
    NSLog(@"%@", [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding]);
    
    //    NSDictionary *_params = [NSDictionary dictionaryWithObjectsAndKeys:
    //                             kAPI_Key , @"X-ApiKey", deviceID ,
    //                             @"X-DeviceID", accessToken ,
    //                             @"X-AccessToken",[[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding],
    //                             @"&X-UserToken=", userToken,
    //                             @"params", nil];
    
    
    NSString *POSTBoundary = @"0xKhTmLbOuNdArY";
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    //    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", POSTBoundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    //    for (NSString *param in _params) {
    //        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", POSTBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    //        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
    //        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [_params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    //    }
    
    // add image data
    //    NSData *imageData = UIImageJPEGRepresentation(imageToPost, 1.0);
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", POSTBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", @"file"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", POSTBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // TODO: encrypt "body"
    [body EncryptAES:@"EncryptKey"];
    
    //[NSData data] AESEncrypt
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%li", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // set URL
    [request setURL:url];
    
    [self sendAsyncRequest:request completion:completion];
}

-(void)queryWithPartialURL:(NSString *)partialURL parameters: (NSDictionary *)param completion:(void(^)(NSError *error, NSDictionary *result)) completion
{
    //    [[NSApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
    
    NSURL *url = [NSURL  URLWithString:[NSString stringWithFormat:@"%@%@", kURL, partialURL]];
    
    NSMutableData *body = [NSMutableData data];
    
    if (param) {
        NSData *json = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
        
        [body appendData:[[NSString stringWithFormat:@"%@%@",
                 @"&params=",[[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding] ]
                dataUsingEncoding: NSUTF8StringEncoding]];
    }
    else
    {
        [body appendData:[[NSString stringWithFormat:@"%@",@""] dataUsingEncoding: NSUTF8StringEncoding]];
    }
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    
    //TODO: encrypt body
    [body EncryptAES:@"EncryptKey"];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: body];
    
    [self sendAsyncRequest:request completion:completion];
}

-(void)sendAsyncRequest:(NSURLRequest *)request completion:(void(^)(NSError *error, NSDictionary *result)) completion
{
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        if(!error)
        {
            NSError *jsonError;
            
            //TODO: Decrypt Maybe?
            NSMutableData *body = [NSMutableData data];
            [body appendData: data];
            // decrypts boby
            [body DecryptAES:@"EncryptKey" andForData:body];
            
            //read and print the server response for debug
            NSString *myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"CloudService: SendAsyncRequest myString:%@", myString);
            
            NSDictionary *json;
            
            if (data)
            {
                json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
            }
            else
            {
                json = nil;
            }
            
            if ((completion && json) || (completion && jsonError)) {
                completion(jsonError, json);
            }
        }
        else
        {
            completion(error, nil);
        }
        
    }];
    
    //    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
    
}

#pragma mark- Cloud API Utilities
#pragma mark-
-(NSString *)convertDictionaryToString:(NSDictionary *) jsonParams
{
    NSData *jsonParamsData = [NSJSONSerialization dataWithJSONObject:jsonParams options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:jsonParamsData encoding:NSUTF8StringEncoding];
}

@end