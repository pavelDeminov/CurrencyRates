//
//  APIClient.h
//  Test1
//
//  Created by Pavel Deminov on 17/07/15.
//  Copyright (c) 2015 Company. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIClient : NSObject


+ (instancetype)sharedInstance;

- (void)apiLiveWithcompletionHandler:(void (^)(BOOL succes, NSError *error))completionHandler;
- (void)getRates:(NSString*)source outputCurrency:(NSString*)output WithcompletionHandler:(void (^)(BOOL succes,NSDictionary *quotes, NSError *error))completionHandler;
- (void)getRates:(NSString*)source outputCurrency:(NSString*)output FromDate:(NSDate*)date  WithcompletionHandler:(void (^)(BOOL succes,NSDictionary *quotes, NSError *error))completionHandler;

@end
