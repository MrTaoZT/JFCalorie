//
//  MyMessageViewController.h
//  Calorie
//
//  Created by xyl on 16/4/17.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyMessageViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *headImg;//头像
@property (weak, nonatomic) IBOutlet UILabel *userID;//用户ID
@property (weak, nonatomic) IBOutlet UITextField *nickName;//昵称
@property (weak, nonatomic) IBOutlet UISegmentedControl *gender;//性别
@property (weak, nonatomic) IBOutlet UITextField *cardID;//身份证
@property (weak, nonatomic) IBOutlet UITextField *birthday;//生日



@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightButton;//编辑
- (IBAction)rightAction:(UIBarButtonItem *)sender;
- (IBAction)returnAction:(UIBarButtonItem *)sender;//返回

- (IBAction)birthdayAction:(UITextField *)sender forEvent:(UIEvent *)event;//生日事件
@end
