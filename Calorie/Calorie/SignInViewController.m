//
//  SignInViewController.m
//  Calorie
//
//  Created by 杨凡 on 16/4/16.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "SignInViewController.h"
#import "SignUpViewController.h"
#import "CodeViewController.h"
@interface SignInViewController ()<UITextFieldDelegate>

@end

@implementation SignInViewController

//视图已经出现时调用
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //判断当前登录页面是否是  注册成功  跳转过来的
    if([[[StorageMgr singletonStorageMgr]objectForKey:@"SignUpSuccessfully"] boolValue]){
        //需要把 这个键的  值  重新设置成  no   （！！！！！！！！！！！！）
        [[StorageMgr singletonStorageMgr]removeObjectForKey:@"SignUpSuccessfully"];
        [[StorageMgr singletonStorageMgr]addKey:@"SignUpSuccessfully" andValue:@NO];
        //从单例化全局变量中提取用户名和密码
        NSString *username = [[StorageMgr singletonStorageMgr] objectForKey:@"Username"];
        NSString *password = [[StorageMgr singletonStorageMgr] objectForKey:@"Password"];
        //清除用完的用户名和密码
        [[StorageMgr singletonStorageMgr] removeObjectForKey:@"Username"];
        [[StorageMgr singletonStorageMgr] removeObjectForKey:@"Password"];
        _usernameTF.text = username;
        _passwordTF.text = password;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //协议
    _usernameTF.delegate = self;
    _passwordTF.delegate = self;
    
    //默认获取 textfield 焦点
    [_usernameTF becomeFirstResponder];
    
    _headImg.image = [UIImage imageNamed:@"headImgBG"];
    
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

- (IBAction)signInAction:(UIButton *)sender forEvent:(UIEvent *)event {
    NSString *exponent = [[StorageMgr singletonStorageMgr] objectForKey:@"exponent"];
    NSString *modulus = [[StorageMgr singletonStorageMgr] objectForKey:@"modulus"];
    //MD5将原始密码进行MD5加密
    NSString *MD5Pwd = [_passwordTF.text getMD5_32BitString];
    //将MD5加密过后的密码进行RSA非对称加密
    NSString *RSAPwd = [NSString encryptWithPublicKeyFromModulusAndExponent:MD5Pwd.UTF8String modulus:modulus exponent:exponent];
    
    NSDictionary *dic = @{@"userName":_usernameTF.text,
                        @"password":RSAPwd,
                        @"deviceType":@7001,
                        @"deviceId":[Utilities uniqueVendor]};
    
    if(_usernameTF.text.length == 0){
        [Utilities popUpAlertViewWithMsg:@"请填写用户名" andTitle:nil onView:self];
        return;
    }
    if(_passwordTF.text.length == 0){
        [Utilities popUpAlertViewWithMsg:@"请填写密码" andTitle:nil onView:self];
        return;
    }
    [RequestAPI postURL:@"/login" withParameters:dic success:^(id responseObject) {
        if ([responseObject[@"resultFlag"] integerValue] == 8001) {
            //这里跳转到首页
        }
    } failure:^(NSError *error) {
        [Utilities popUpAlertViewWithMsg:@"您的用户名或密码错误" andTitle:nil onView:self];
    }];

}

- (IBAction)forgetPwAction:(UIButton *)sender forEvent:(UIEvent *)event {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CodeViewController *codeVc = [storyboard instantiateViewControllerWithIdentifier:@"CodeVc"];
    [self.navigationController pushViewController:codeVc animated:YES];
}

- (IBAction)signUpAction:(UIButton *)sender forEvent:(UIEvent *)event {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SignUpViewController *signUpVc = [storyboard instantiateViewControllerWithIdentifier:@"SignUpVc"];
    [self.navigationController pushViewController:signUpVc animated:YES];
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
