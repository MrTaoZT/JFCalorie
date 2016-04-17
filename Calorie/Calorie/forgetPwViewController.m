//
//  forgetPwViewController.m
//  Calorie
//
//  Created by xyl on 16/4/17.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "forgetPwViewController.h"

@interface forgetPwViewController ()

@end

@implementation forgetPwViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)setPwAction:(UIButton *)sender forEvent:(UIEvent *)event {
    if (_firstPwTF.text.length == 0 || _secondPwTF.text.length ==0) {
        [Utilities popUpAlertViewWithMsg:@"请填写密码" andTitle:nil onView:self];
        return;
    }
    if (![_firstPwTF.text isEqualToString:_secondPwTF.text]) {
        [Utilities popUpAlertViewWithMsg:@"两次输入的密码需要相同" andTitle:nil onView:self];
        return;
    }
    if (_firstPwTF.text.length >= 6 || _firstPwTF.text.length <= 16) {
        [Utilities popUpAlertViewWithMsg:@"请设置6-16位的密码" andTitle:nil onView:self];
        return;
    }

}
@end
