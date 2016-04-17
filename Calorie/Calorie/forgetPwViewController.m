//
//  forgetPwViewController.m
//  Calorie
//
//  Created by xyl on 16/4/17.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "forgetPwViewController.h"
#import "SignInViewController.h"
@interface forgetPwViewController ()<UITextFieldDelegate>

@end

@implementation forgetPwViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    
    _firstPwTF.delegate = self;
    _secondPwTF.delegate = self;
    //默认获取 textfield 焦点
    [_firstPwTF becomeFirstResponder];
    
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

- (IBAction)setPwAction:(UIButton *)sender forEvent:(UIEvent *)event {
    NSString *userTel = [[StorageMgr singletonStorageMgr] objectForKey:@"phone"];
    NSString *codeNum = [[StorageMgr singletonStorageMgr] objectForKey:@"code"];
    NSLog(@"userTel = %@",userTel);
    NSLog(@"codeNum = %@",codeNum);
    NSString *exponent = [[StorageMgr singletonStorageMgr] objectForKey:@"exponent"];
    NSString *modulus = [[StorageMgr singletonStorageMgr] objectForKey:@"modulus"];
    //MD5将原始密码进行MD5加密
    NSString *MD5Pwd = [_firstPwTF.text getMD5_32BitString];
    //将MD5加密过后的密码进行RSA非对称加密
    NSString *RSAPwd = [NSString encryptWithPublicKeyFromModulusAndExponent:MD5Pwd.UTF8String modulus:modulus exponent:exponent];
    
    if (_firstPwTF.text.length == 0 || _secondPwTF.text.length ==0) {
        [Utilities popUpAlertViewWithMsg:@"请填写密码" andTitle:nil onView:self];
        return;
    }
    if (![_firstPwTF.text isEqualToString:_secondPwTF.text]) {
        [Utilities popUpAlertViewWithMsg:@"两次输入的密码需要相同" andTitle:nil onView:self];
        return;
    }
    if (_firstPwTF.text.length < 6 || _firstPwTF.text.length > 16) {
        [Utilities popUpAlertViewWithMsg:@"请设置6-16位的密码" andTitle:nil onView:self];
        return;
    }
    
    [[StorageMgr singletonStorageMgr]addKey:@"Username" andValue:userTel];
    [[StorageMgr singletonStorageMgr]addKey:@"Password" andValue:_firstPwTF.text];
    //现将同名 键 在单例化全局变量中删除   以保证该键的唯一性
    [[StorageMgr singletonStorageMgr]removeObjectForKey:@"SignUpSuccessfully"];
    //在初始化一个同名 键 为yes  表示注册成功
    [[StorageMgr singletonStorageMgr]addKey:@"SignUpSuccessfully" andValue:@YES];
    
    SignInViewController *signIn = [Utilities getStoryboard:@"Main" instanceByIdentity:@"signInVc"];
    [self.navigationController pushViewController:signIn animated:YES];
    
//    NSDictionary *dic = @{@"userTel":userTel,
//                        @"userPsw":RSAPwd,
//                        @"codeNum":codeNum,
//                        @"deviceId":[Utilities uniqueVendor]
//                        };
//    [RequestAPI postURL:@"/register/forgetPassword" withParameters:dic success:^(id responseObject) {
//        if ([responseObject[@"resultFlag"] integerValue] == 8001) {
//            //这里进行跳转
//        }else{
//            [Utilities popUpAlertViewWithMsg:@"服务器繁忙，请稍后再试" andTitle:nil onView:self];
//        }
//    } failure:^(NSError *error) {
//        NSLog(@"error = %@",[error userInfo]);
//    }];
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
