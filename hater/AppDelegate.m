//
//  AppDelegate.m
//  hater
//
//  Created by Scott Vanderlind on 7/30/14.
//  Copyright (c) 2014 Scott Vanderlind. All rights reserved.
//

#import "AppDelegate.h"
#import "APIClient.h"
#import "TWMessageBarManager.h"
#import <AudioToolbox/AudioToolbox.h>

@interface AppDelegate ()
            

@end

@implementation AppDelegate
            

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Let's register for PUSH NOTIFICATIONS, BABY!
    //[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    
#ifdef __IPHONE_8_0
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:
                                            (UIUserNotificationTypeAlert
                                            |UIUserNotificationTypeBadge
                                            |UIUserNotificationTypeSound) categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
#else
    UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
#endif
    
    return YES;
}



#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}
#endif

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    // TOODO report this to the API and register the user for push.
    NSString* newToken = [[[NSString stringWithFormat:@"%@", deviceToken]
                           stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"My token is: %@", deviceToken);
    NSLog(@"My token as a string is: %@", newToken);

    [[APIClient sharedClient] registerPushToken:newToken];
    
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    NSLog(@"Received notification: %@", userInfo);
    if (true || application.applicationState == UIApplicationStateActive ) {
        NSString *message = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
        
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"New hate!"
                                                       description:message
                                                              type:TWMessageBarMessageTypeSuccess
                                                          duration:10.0];
        if([[UIDevice currentDevice].model isEqualToString:@"iPhone"])
        {
            // vibe and play the boo-doo-do-do sound
            AudioServicesPlaySystemSound (1352);
            AudioServicesPlayAlertSound (1109);
        }
        else
        {
            // Not an iPhone, so doesn't have vibrate
            // so play the boo-doo-do-do sound
            AudioServicesPlayAlertSound (1109);
        }
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
