//
//  CredentialStore.h
//  chitchat
//
//  Created by Scott Vanderlind on 6/5/14.
//  Copyright (c) 2014 Scott Vanderlind. All rights reserved.
//

@interface CredentialStore : NSObject

- (BOOL)isLoggedIn;
- (void)clearSavedCredentials;
- (NSString *)authToken;
- (void)setAuthToken:(NSString *)authToken;

@end