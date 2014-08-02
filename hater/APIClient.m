//
//  APIClient.m
//  chitchat
//
//  Created by Scott Vanderlind on 6/5/14.
//  Copyright (c) 2014 Scott Vanderlind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIClient.h"
#import "CredentialStore.h"

#define BASE_URL @"http://soysauce.land:3000/api/"
#define MEDIA_URL @"http://soysauce.land:3000/public/"
#define AUTH_HEADER @"Authorization"

@implementation APIClient

+ (id)sharedClient {
    static APIClient *__instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseUrl = [NSURL URLWithString:BASE_URL];
        __instance = [[APIClient alloc] initWithBaseURL:baseUrl];
    });
    return __instance;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        [self setAuthTokenHeader];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tokenChanged:)
                                                     name:@"token-changed"
                                                   object:nil];
    }
    return self;
}

- (void)registerPushToken:(NSString *)token
{
    self.pushToken = token;
}

- (void)setAuthTokenHeader {
    CredentialStore *store = [[CredentialStore alloc] init];
    NSString *authToken = [store authToken];
    NSLog(@"Auth token is now %@\n", authToken);
    [self.requestSerializer setValue:authToken forHTTPHeaderField:AUTH_HEADER];
}

- (void)tokenChanged:(NSNotification *)notification {
    NSLog(@"Token Changed Notification Caught\n");
    [self setAuthTokenHeader];
}

+ (BOOL)validateResponse:(AFHTTPRequestOperation *)operation {
    // Basically, just make sure we're authenticated.
    if (operation.response.statusCode != 401) {
        return YES;
    }
    return NO;
}

+ (NSString *)baseUrl {
    return BASE_URL;
}

+ (NSString *)mediaUrl {
    return MEDIA_URL;
}

@end


