//
//  EnemiesViewController.h
//  hater
//
//  Created by Scott Vanderlind on 7/30/14.
//  Copyright (c) 2014 Scott Vanderlind. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EnemiesViewController : UIViewController

@property (nonatomic, strong) NSArray *enemiesRoster;
@property (weak, nonatomic) IBOutlet UICollectionView *enemiesCollection;

@end
