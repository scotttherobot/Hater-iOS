//
//  EnemiesViewController.m
//  hater
//
//  Created by Scott Vanderlind on 7/30/14.
//  Copyright (c) 2014 Scott Vanderlind. All rights reserved.
//

#import "EnemiesViewController.h"
#import "LoginViewController.h"
#import "EnemiesCollectionViewCell.h"
#import "SVProgressHUD.h"
#import "APIClient.h"

@interface EnemiesViewController ()

@end

@implementation EnemiesViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"Hater";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"+"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(addEnemy:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"refresh"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(getFriends:)];

    
    [self getFriends:nil];
    
}

- (void)addEnemy:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add Enemy"
                                                    message:@"Enter the username of your enemy."
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Okay", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alert show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"index %d", buttonIndex);
    if (buttonIndex == 1) {
        NSString *username = [[alertView textFieldAtIndex:0] text];
        id params = @{
                      @"username": username
                      };
        
        [[APIClient sharedClient] POST:@"enemies/" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if([APIClient validateResponse:operation]) {
                [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Added user %@!", username]];
                [self getFriends:nil];
            } else {
                // We probably need to reauth.
                NSLog(@"Hit the reauth block\n");
                [LoginViewController presentModallyFromViewController:self];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Something failed"];
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/*
 * Collection view things
 */
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"Count is %lu\n", (unsigned long)[_enemiesRoster count]);
    return [_enemiesRoster count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSObject *friend = [_enemiesRoster objectAtIndex:indexPath.row];
    
    static NSString *cellIdentifier = @"EnemyCell";
    EnemiesCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.usernameLabel.text = [friend valueForKey:@"username"];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject *enemy = [_enemiesRoster objectAtIndex:indexPath.row];
    NSLog(@"enemy %@ %@\n", [enemy valueForKey:@"username"], [enemy valueForKey:@"id"]);
    
    id params = @{
                  @"target_user": [enemy valueForKey:@"id"],
                  @"insult_id": @"3"
                  };
    
    [[APIClient sharedClient] POST:@"hate/" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if([APIClient validateResponse:operation]) {
            [SVProgressHUD showSuccessWithStatus:@"Hate sent!"];
        } else {
            // We probably need to reauth.
            NSLog(@"Hit the reauth block\n");
            [LoginViewController presentModallyFromViewController:self];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Something failed"];
    }];
    
}

/*
 * API Doings
 */

- (void)getFriends:(id)sender {
    [SVProgressHUD show];
    [[APIClient sharedClient] GET:@"enemies/" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if([APIClient validateResponse:operation]) {
            [SVProgressHUD showSuccessWithStatus:@"Done"];
            _enemiesRoster = (NSArray*)responseObject;
            NSLog(@"response: %@\n", responseObject);
            NSLog(@"roster: %@\n", _enemiesRoster);
            [_enemiesCollection reloadData];
            //[_enemiesCollection reloadData];
        } else {
            // We probably need to reauth.
            NSLog(@"Hit the reauth block\n");
            [LoginViewController presentModallyFromViewController:self];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Something failed"];
        NSLog(@"%@\n", error);
        if (operation.response.statusCode == 403) {
            [LoginViewController presentModallyFromViewController:self];
        }
    }];
}

@end
