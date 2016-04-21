//
//  HomeTableViewController.h
//  Calorie
//
//  Created by 杨凡 on 16/4/16.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UIScrollView *ADScrollView;//广告图片

- (IBAction)chooseLocationAction:(UIButton *)sender forEvent:(UIEvent *)event;

- (IBAction)searchAction:(UIBarButtonItem *)sender;

@property (weak, nonatomic) IBOutlet UIButton *chooseLocationButton;

- (IBAction)leftButton:(UIBarButtonItem *)sender;

@end
