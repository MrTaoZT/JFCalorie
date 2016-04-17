//
//  SignUpViewController.m
//  Calorie
//
//  Created by xyl on 16/4/17.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController ()
@property (strong,nonatomic) NSTimer *timer;
@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //获取模数指数
    NSDictionary *dic = @{@"deviceType":@7001,
                          @"deviceId":[Utilities uniqueVendor]
                          };
    
    [RequestAPI getURL:@"/login/getKey" withParameters:dic success:^(id responseObject) {
        NSLog(@"responseObject : %@",responseObject);
        if ([responseObject[@"resultFlag"] integerValue] == 8001) {
            NSDictionary *resultDict = responseObject[@"result"];
            NSLog(@"resultDict = %@",resultDict);
            NSString *exponent = resultDict[@"exponent"];
            NSString *modulus = resultDict[@"modulus"];
            //从单例化全局变量中删除数据
            [[StorageMgr singletonStorageMgr] removeObjectForKey:@"exponent"];
            [[StorageMgr singletonStorageMgr] removeObjectForKey:@"modulus"];
            
            [[StorageMgr singletonStorageMgr] addKey:@"exponent" andValue:exponent];
            [[StorageMgr singletonStorageMgr] addKey:@"modulus" andValue:modulus];
        }else{
            NSLog(@"resultFailed");
        }
        
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Action

- (IBAction)signUpAction:(UIButton *)sender forEvent:(UIEvent *)event {

}
- (IBAction)codeAction:(UIButton *)sender forEvent:(UIEvent *)event {
    
    NSDictionary *dic = @{@"userTel":_phoneTF.text,
                        @"type":@1,};
    //判断用户是否输入手机号  再判断用户手机号是否为11位
    if (_phoneTF.text.length == 0) {
        [Utilities popUpAlertViewWithMsg:@"请输入您的手机号" andTitle:nil onView:self];
        return;
    }
    if (_phoneTF.text.length == 11) {
        [RequestAPI getURL:@"/register/verificationCode" withParameters:dic success:^(id responseObject) {
            if ([responseObject[@"resultFlag"] integerValue] == 8001) {
                //定时器
            }
        } failure:^(NSError *error) {
            NSLog(@"error = %@",[error userInfo]);
            [Utilities popUpAlertViewWithMsg:@"服务器繁忙，请稍后再试！" andTitle:nil onView:self];
        }];
    }else{
        [Utilities popUpAlertViewWithMsg:@"手机号码的位数必须为11位" andTitle:nil onView:self];
    }
}

#pragma mark - Timer

- (void)setTime{
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(changeTime) userInfo:nil repeats:YES];
}

- (void)changeTime{
    
}
@end
