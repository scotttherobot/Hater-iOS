//
//  LoginViewController.h
//  chitchat
//
//  Created by Scott Vanderlind on 6/3/14.
//  Copyright (c) 2014 Scott Vanderlind. All rights reserved.
//

#import <UIKit/UIKit.h>

UITextField *loginId;
UITextField *password;
UITableView *loginTable;

@interface LoginViewController : UIViewController <UITextFieldDelegate>
- (IBAction)doLogin:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

+ (void)presentModallyFromViewController:(UIViewController *)viewController;

@end
