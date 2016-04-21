//
//  MyCollectViewController.h
//  Calorie
//
//  Created by Z on 16/4/18.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyCollectViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightButton;
- (IBAction)rightBtnAction:(UIBarButtonItem *)sender;

- (IBAction)leftButton:(UIBarButtonItem *)sender;
@end
