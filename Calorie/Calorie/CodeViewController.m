//
//  CodeViewController.m
//  Calorie
//
//  Created by xyl on 16/4/17.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "CodeViewController.h"
#import "forgetPwViewController.h"
@interface CodeViewController (){
    //用于Code的计数
    NSInteger count;
}
@property (strong,nonatomic) NSTimer *timer;
@end

@implementation CodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    count = 60;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Action

- (IBAction)codeAction:(UIButton *)sender forEvent:(UIEvent *)event {
    
    NSDictionary *dic = @{@"userTel":_phoneTF.text,
                          @"type":@2};
    //判断用户是否输入手机号  再判断用户手机号是否为11位
    if (_phoneTF.text.length == 0) {
        [Utilities popUpAlertViewWithMsg:@"请输入您的手机号" andTitle:nil onView:self];
        return;
    }
    if (_phoneTF.text.length == 11) {
        [RequestAPI getURL:@"/register/verificationCode" withParameters:dic success:^(id responseObject) {
            NSLog(@"%@",responseObject);
             [self setTime];
            if ([responseObject[@"resultFlag"] integerValue] == 8001) {
                //定时器
               
            }else{
                [Utilities popUpAlertViewWithMsg:@"服务器繁忙，请稍后再试！" andTitle:nil onView:self];
 
            }
        } failure:^(NSError *error) {
            NSLog(@"error = %@",[error userInfo]);
            
        }];
    }else{
        [Utilities popUpAlertViewWithMsg:@"手机号码的位数必须为11位" andTitle:nil onView:self];
    }

}

- (IBAction)jumpForgetPwAction:(UIButton *)sender forEvent:(UIEvent *)event {
    NSDictionary *dic = @{@"userTel":_phoneTF.text,
                          @"codeNum":_codeTF.text};
    forgetPwViewController *forgetVc = [Utilities getStoryboard:@"Main" instanceByIdentity:@"ForgetPwVc"];
    
    [self presentViewController:forgetVc animated:YES completion:nil];
//    [RequestAPI getURL:@"/register/checkVerificationCode" withParameters:dic success:^(id responseObject) {
//        if ([responseObject[@"resultFlag"] integerValue] == 8001) {
//            forgetPwViewController *forgetVc = [Utilities getStoryboard:@"Main" instanceByIdentity:@"ForgetVc"];
//            [self.navigationController pushViewController:forgetVc animated:YES];
//        }else{
//            [Utilities popUpAlertViewWithMsg:@"验证码错误" andTitle:nil onView:self];
//        }
//    } failure:^(NSError *error) {
//        NSLog(@"error = %@",[error userInfo]);
//    }];
}

#pragma mark - Timer

- (void)setTime{
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(changeTime) userInfo:nil repeats:YES];
}

- (void)changeTime{
    NSString *str = @"秒";
    if (count > 0) {
        [_codeBtn setTitle:[NSString stringWithFormat:@"%ld%@",count,str] forState:UIControlStateNormal];
        _codeBtn.userInteractionEnabled = NO;
        count --;
    }else{
        [_codeBtn setTitle:@"重新发送" forState:UIControlStateNormal];
        _codeBtn.userInteractionEnabled = YES;
        count = 60;
    }
}

@end
