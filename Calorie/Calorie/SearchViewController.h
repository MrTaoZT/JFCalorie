//
//  SearchViewController.h
//  Calorie
//
//  Created by Z on 16/4/19.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)searchButton:(UIButton *)sender forEvent:(UIEvent *)event;
- (IBAction)cityButtonAction:(UIButton *)sender forEvent:(UIEvent *)event;
- (IBAction)typeAction:(UIButton *)sender forEvent:(UIEvent *)event;
- (IBAction)perPageAction:(UIButton *)sender forEvent:(UIEvent *)event;

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIButton *cityBtn;
@property (weak, nonatomic) IBOutlet UIButton *typeBtn;
@property (weak, nonatomic) IBOutlet UIButton *perPageBtn;

@property(nonatomic)CGFloat jing;
@property(nonatomic)CGFloat wei;

@end
