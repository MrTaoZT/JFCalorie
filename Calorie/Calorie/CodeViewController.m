//
//  CodeViewController.m
//  Calorie
//
//  Created by xyl on 16/4/17.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "CodeViewController.h"
#import "forgetPwViewController.h"
@interface CodeViewController ()<UITextFieldDelegate>{
    //用于Code的计数
    NSInteger count;
}
@property (strong,nonatomic) NSTimer *timer;
@end

@implementation CodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    
    _phoneTF.delegate = self;
    _codeTF.delegate = self;
    //默认获取 textfield 焦点
    [_phoneTF becomeFirstResponder];
    
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
    //从单例化全局变量中删除数据
    [[StorageMgr singletonStorageMgr] removeObjectForKey:@"phone"];
    [[StorageMgr singletonStorageMgr] removeObjectForKey:@"code"];

    [[StorageMgr singletonStorageMgr] addKey:@"phone" andValue:_phoneTF.text];
    [[StorageMgr singletonStorageMgr] addKey:@"code" andValue:_codeTF.text];

    forgetPwViewController *forgetVc = [Utilities getStoryboard:@"Main" instanceByIdentity:@"ForgetPwVc"];
    [self.navigationController pushViewController:forgetVc animated:YES];
    
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

#pragma mark - TextField

- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

//当文本输入框中输入的内容变化是调用该方法，返回值为NO不允许调用
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return YES;
}

@end
