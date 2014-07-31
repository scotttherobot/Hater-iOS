//
//  CredentialStore.m
//  chitchat
//
//  Created by Scott Vanderlind on 6/5/14.
//  Copyright (c) 2014 Scott Vanderlind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CredentialStore.h"

#define AUTH_TOKEN_KEY @"chitchattoken"
//#define SERVICE_NAME @"ChitChat"

@implementation CredentialStore

- (BOOL)isLoggedIn {
    return [self authToken] != nil;
}

- (void)clearSavedCredentials {
    [self setAuthToken:nil];
}

- (NSString *)authToken {
    return [self secureValueForKey:AUTH_TOKEN_KEY];
}

- (void)setAuthToken:(NSString *)authToken {
    [self setSecureValue:authToken forKey:AUTH_TOKEN_KEY];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"token-changed" object:self];
}

- (void)setSecureValue:(NSString *)value forKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (value) {
        [defaults setObject:value forKey:key];
        NSLog(@"Set value %@ for key %@\n", value, key);
    } else {
        [defaults setObject:nil forKey:key];
        NSLog(@"Deleted password for key %@\n", key);
    }
    [defaults synchronize];
}

- (NSString *)secureValueForKey:(NSString *)key {
    NSString *token = nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    token = [defaults valueForKey:key];
    NSLog(@"Returned %@ to caller\n", token);
    return token;
}

@end

