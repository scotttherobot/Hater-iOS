//
//  APIClient.h
//  chitchat
//
//  Created by Scott Vanderlind on 6/5/14.
//  Copyright (c) 2014 Scott Vanderlind. All rights reserved.
//

#import "AFNetworking.h"

@interface APIClient : AFHTTPRequestOperationManager


- (void)registerPushToken:(NSString *)token;

+ (id)sharedClient;
+ (BOOL)validateResponse:(AFHTTPRequestOperation *)operation;
+ (NSString *)baseUrl;
+ (NSString *)mediaUrl;

@property (strong, nonatomic) NSString *pushToken;

@end