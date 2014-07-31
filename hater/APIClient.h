//
//  APIClient.h
//  chitchat
//
//  Created by Scott Vanderlind on 6/5/14.
//  Copyright (c) 2014 Scott Vanderlind. All rights reserved.
//

#import "AFNetworking.h"

@interface APIClient : AFHTTPRequestOperationManager

+ (id)sharedClient;
+ (BOOL)validateResponse:(AFHTTPRequestOperation *)operation;
+ (NSString *)baseUrl;
+ (NSString *)mediaUrl;


@end