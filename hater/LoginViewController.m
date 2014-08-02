//
//  LoginViewController.m
//  chitchat
//
//  Created by Scott Vanderlind on 6/3/14.
//  Copyright (c) 2014 Scott Vanderlind. All rights reserved.
//

#import "LoginViewController.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "APIClient.h"
#import "CredentialStore.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

+ (void)presentModallyFromViewController:(UIViewController *)viewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginVC = (LoginViewController *)[storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:loginVC];
    [viewController presentViewController:navController animated:YES completion:nil];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Check Token"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(logToken:)];
     [loginId becomeFirstResponder];
    // Do any additional setup after loading the view.
}

- (void)logToken:(id)sender {
    NSString *token = [[[CredentialStore alloc] init] authToken];
    NSLog(@"Token is currently %@\n", token);
    self.statusLabel.text = token;
}
                                              
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**********
 * Deal with logging in when the button is pushed.
 **********/
- (IBAction)doLogin:(id)sender {
    [SVProgressHUD show];
    
    id params = @{
                  @"username": loginId.text,
                  @"password": password.text
                 };
    
    [[APIClient sharedClient] POST:@"login/" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *errs = [responseObject objectForKey:@"errors"];
        NSLog(@"%@", responseObject);
        if ([errs count] != 0) {
            // There were errors! Show them.
            [SVProgressHUD showErrorWithStatus:[errs componentsJoinedByString:@"\n"]];
        } else {
            NSString *key = [responseObject objectForKey:@"api_token"];
            [[[CredentialStore alloc] init] setAuthToken:key];
            [SVProgressHUD showSuccessWithStatus:@"You are now logged in!"];
            [self dismissViewControllerAnimated:YES completion:nil];
            
            id pushParams = @{
                          @"device_type": @"IOS",
                          @"token": [[APIClient sharedClient] pushToken]
                          };
            // Now that we are logged in, let's register our push token for this device.
            [[APIClient sharedClient] POST:@"devices/" parameters:pushParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
                // This is all happening in the background, so let's assume it worked.
                [SVProgressHUD showSuccessWithStatus:@"Successfully enrolled for push."];
                NSLog(@"push enrollment %@", responseObject);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [SVProgressHUD showErrorWithStatus:@"Failed to enroll device for push notifications."];
                NSLog(@"push enrollment failure %@", responseObject);
            }];

        }
        self.statusLabel.text = [responseObject objectForKey:@"status"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.statusLabel.text = @"Oh no!";
        [SVProgressHUD dismiss];
    }];
    
    //NSString *statusStr = [[loginId.text stringByAppendingString:@" "] stringByAppendingString:password.text];
    //self.statusLabel.text = statusStr;
}


/***********
 * Set up the login fields
 ***********/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
 
    if (indexPath.row == 0) {
        loginId = [[UITextField alloc] initWithFrame:CGRectMake(5, 0, 280, 21)];
        loginId.placeholder = @"username";
        loginId.autocorrectionType = UITextAutocorrectionTypeNo;
        loginId.delegate = self;
        [loginId setClearButtonMode:UITextFieldViewModeWhileEditing];
        cell.accessoryView = loginId;
        [loginTable addSubview:loginId];
    } else if (indexPath.row == 1) {
        password = [[UITextField alloc] initWithFrame:CGRectMake(5, 0, 280, 21)];
        password.placeholder = @"password";
        password.secureTextEntry = YES;
        password.autocorrectionType = UITextAutocorrectionTypeNo;
        password.delegate = self;
        [password setClearButtonMode:UITextFieldViewModeWhileEditing];
        cell.accessoryView = password;
        [loginTable addSubview:password];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**************
 * Signup stuff
 **************/
- (IBAction)signup:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Register"
                                                    message:@"Choose a username and password."
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Okay", nil];
    [alert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    [alert show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"index %d", buttonIndex);
    if (buttonIndex == 1) {
        NSString *newusername = [[alertView textFieldAtIndex:0] text];
        NSString *newpassword = [[alertView textFieldAtIndex:1] text];
        id params = @{
                      @"username": newusername,
                      @"password": newpassword
                      };
        
        [[APIClient sharedClient] POST:@"users/" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Signed up as user %@!", newusername]];
            loginId.text = newusername;
            password.text = newpassword;
            [self doLogin:nil];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Something failed."];
        }];
    }
}

@end
