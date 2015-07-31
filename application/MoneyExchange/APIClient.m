//
//  APIClient.m
//  Test1
//
//  Created by Pavel Deminov on 17/07/15.
//  Copyright (c) 2015 Company. All rights reserved.
//

#import "APIClient.h"
#import "AFNetworking.h"

static NSString *const kAPIAccess = @"f64c2ff461190109776e535ed14ce64a";
static NSString *const kMethodAPILive = @"live";
static NSString *const kMethodAPIHistory = @"historical";

@interface APIClient () {
     NSString *_APIURL;
}

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;

@end;
@implementation APIClient



#pragma mark - Singleton

+ (instancetype)sharedInstance
{
    static APIClient *sharedInstance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[APIClient alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        _APIURL = @"http://apilayer.net/api/";
    }
    return self;
}

- (void)apiLiveWithcompletionHandler:(void (^)(BOOL succes, NSError *error))completionHandler {
    
    NSDictionary *params = @{@"access_key" : kAPIAccess};
    
    [self.manager GET:[NSString stringWithFormat:kMethodAPILive]
           parameters:params
              success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"%@", responseObject);
         
         //         if (![[responseObject valueForKey:kSuccess] boolValue])
         //         {
         //             completionHandler(NO, nil, [self errorForResponseObject:responseObject]);
         //
         //             return;
         //         }
         
         completionHandler(YES, nil);
     }
              failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"%@", operation.responseString);
         
         completionHandler(NO,error);
     }];
    
    
    
}

- (void)getRates:(NSString*)source outputCurrency:(NSString*)output WithcompletionHandler:(void (^)(BOOL succes,NSDictionary *quotes, NSError *error))completionHandler {
    
    NSDictionary *params = @{@"access_key" : kAPIAccess,@"source" : source,@"currencies" : output};
    
    [self.manager GET:[NSString stringWithFormat:kMethodAPILive]
           parameters:params
              success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"%@", responseObject);
         
         //         if (![[responseObject valueForKey:kSuccess] boolValue])
         //         {
         //             completionHandler(NO, nil, [self errorForResponseObject:responseObject]);
         //
         //             return;
         //         }
         completionHandler(YES,responseObject[@"quotes"], nil);
     }
              failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"%@", operation.responseString);
         
         completionHandler(NO,nil,error);
     }];
    
    
    
}

- (void)getRates:(NSString*)source outputCurrency:(NSString*)output FromDate:(NSDate*)date  WithcompletionHandler:(void (^)(BOOL succes,NSDictionary *quotes, NSError *error))completionHandler {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormat stringFromDate:date];
    NSDictionary *params = @{@"access_key" : kAPIAccess,@"source" : source,@"currencies" : output,@"date":dateString};
    
    [self.manager GET:[NSString stringWithFormat:kMethodAPIHistory]
           parameters:params
              success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"%@", responseObject);
         
         //         if (![[responseObject valueForKey:kSuccess] boolValue])
         //         {
         //             completionHandler(NO, nil, [self errorForResponseObject:responseObject]);
         //
         //             return;
         //         }
         completionHandler(YES,responseObject[@"quotes"], nil);
     }
              failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"%@", operation.responseString);
         
         completionHandler(NO,nil,error);
     }];
    
    
    
}



- (AFHTTPRequestOperationManager *)manager
{
    if (_manager == nil) {
        if (!_APIURL) {
            @throw [NSException exceptionWithName:NSObjectNotAvailableException reason:@"API URL is not set yet, call updateMainConfigWithCompletition: before using APICLient" userInfo:nil];
        }
        _manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:_APIURL]];
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
        _manager.securityPolicy.allowInvalidCertificates = YES;
        //_manager.shouldUseCredentialStorage = NO;
        [_manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    }
//    DLog(@"Authorization: %@",self.tokenInfo.accessToken);
//    [_manager.requestSerializer setValue:self.tokenInfo.isValidToken ? self.tokenInfo.accessToken : @"" forHTTPHeaderField:@"Authorization"];
    
    return _manager;
}



@end
