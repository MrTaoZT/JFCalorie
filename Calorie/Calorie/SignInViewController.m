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
#import "TabBarViewController.h"
#import <ECSlidingViewController/ECSlidingViewController.h>
#import "LeftViewController.h"

@interface SignInViewController ()<UITextFieldDelegate>
@property (strong,nonatomic) ECSlidingViewController *slidingVc;

@end

@implementation SignInViewController

//视图已经出现时调用
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
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
    self.navigationController.navigationBar.hidden = YES;
    //协议
    _usernameTF.delegate = self;
    _passwordTF.delegate = self;
    
    //默认获取 textfield 焦点
    [_usernameTF becomeFirstResponder];
    
    _headImg.image = [UIImage imageNamed:@"headImgBG"];
    
    [self setMD5RSA];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Action

- (IBAction)signInAction:(UIButton *)sender forEvent:(UIEvent *)event {
    //调试
//    [self setMD5RSA];
    NSString *exponent = [[StorageMgr singletonStorageMgr] objectForKey:@"exponent"];
    NSString *modulus = [[StorageMgr singletonStorageMgr] objectForKey:@"modulus"];
    //MD5将原始密码进行MD5加密
    NSString *MD5Pwd = [_passwordTF.text getMD5_32BitString];
    //将MD5加密过后的密码进行RSA非对称加密
    NSString *RSAPwd = [NSString encryptWithPublicKeyFromModulusAndExponent:MD5Pwd.UTF8String modulus:modulus exponent:exponent];
    
    NSLog(@"user = %@",_usernameTF.text);
    NSLog(@"pw = %@",RSAPwd);

    if(_usernameTF.text.length == 0){
        [Utilities popUpAlertViewWithMsg:@"请填写用户名" andTitle:nil onView:self];
        return;
    }
    if(_passwordTF.text.length == 0){
        [Utilities popUpAlertViewWithMsg:@"请填写密码" andTitle:nil onView:self];
        return;
    }
    NSDictionary *dic = @{@"userName":_usernameTF.text,
                          @"password":RSAPwd,
                          @"deviceType":@7001,
                          @"deviceId":[Utilities uniqueVendor]};
    UIActivityIndicatorView *aiv = [Utilities getCoverOnView:self.view];
    [RequestAPI postURL:@"/login" withParameters:dic success:^(id responseObject) {
        NSLog(@"%@",responseObject);
        if ([responseObject[@"resultFlag"] integerValue] == 8001) {
            //这里跳转到首页
            LeftViewController * leftVc = [Utilities getStoryboard:@"Home" instanceByIdentity:@"LeftVc"];
            TabBarViewController * tabView = [Utilities getStoryboard:@"Home" instanceByIdentity:@"TabView"];
            //----------------------侧滑开始 center----------------------
            //初始化侧滑框架,并且设置中间显示的页面
            _slidingVc = [ECSlidingViewController slidingWithTopViewController:tabView];
            //设置侧滑 的  耗时
            _slidingVc.defaultTransitionDuration = 0.25f;
            //设置 控制侧滑的手势   (这里同时对触摸 和 拖拽相应)
            _slidingVc.topViewAnchoredGesture = ECSlidingViewControllerAnchoredGesturePanning | ECSlidingViewControllerAnchoredGestureTapping;
            //设置上述手势的识别范围
            [tabView.view addGestureRecognizer:_slidingVc.panGesture];
            //----------------------侧滑开始 left----------------------
            _slidingVc.underLeftViewController = leftVc;
            //设置侧滑的开闭程度   (peek都是设置中间的页面出现的宽度 )
            _slidingVc.anchorRightPeekAmount = UI_SCREEN_W / 4;
            
            //删除防止重名
            [[StorageMgr singletonStorageMgr]removeObjectForKey:@"inOrUp"];
            //添加 此键  放进全局变量   ，之后来判断用户是否登录进入的侧滑
            [[StorageMgr singletonStorageMgr]addKey:@"inOrUp" andValue:@YES];
            
            [[StorageMgr singletonStorageMgr]removeObjectForKey:@"LeftUsername"];
            [[StorageMgr singletonStorageMgr]addKey:@"LeftUsername" andValue:_usernameTF.text];
            
            [Utilities removeUserDefaults:@"OrLogin"];
            [Utilities removeUserDefaults:@"AddUserAndPw"];
            //缓存  键名  能判断用户上一次是否登录
            [Utilities setUserDefaults:@"OrLogin" content:@YES];
            [Utilities setUserDefaults:@"AddUserAndPw" content:@NO];
            //删除之前缓存到的用户和密码
            [Utilities removeUserDefaults:@"Username"];
            [Utilities removeUserDefaults:@"Password"];
            //缓存到用户登录的账号密码
            [Utilities setUserDefaults:@"Username" content:_usernameTF.text];
            [Utilities setUserDefaults:@"Password" content:_passwordTF.text];
            
            [aiv stopAnimating];
            [self.navigationController pushViewController:_slidingVc animated:YES];
            
        }else{
            [aiv stopAnimating];
            //这还要修改
            [Utilities popUpAlertViewWithMsg:@"用户名或密码错误" andTitle:nil onView:self];
            _passwordTF.text = @"";
            [self setMD5RSA];
        }
    } failure:^(NSError *error) {
        [aiv stopAnimating];
        [Utilities popUpAlertViewWithMsg:@"您的用户名或密码错误" andTitle:nil onView:self];
        _passwordTF.text = @"";
        [self setMD5RSA];
    }];

}

- (IBAction)forgetPwAction:(UIButton *)sender forEvent:(UIEvent *)event {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CodeViewController *codeVc = [storyboard instantiateViewControllerWithIdentifier:@"CodeVc"];
    [self.navigationController pushViewController:codeVc animated:YES];
}

- (IBAction)signUpAction:(UIButton *)sender forEvent:(UIEvent *)event {
     SignUpViewController *signUpVc = [Utilities getStoryboard:@"Main" instanceByIdentity:@"SignUpVc"];
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

#pragma mark - setMD5RSA

- (void)setMD5RSA{
    //获取模数指数
    NSDictionary *dic = @{@"deviceType":@7001,
                          @"deviceId":[Utilities uniqueVendor]
                          };
    
    [RequestAPI getURL:@"/login/getKey" withParameters:dic success:^(id responseObject) {
        NSLog(@"responseObject : %@",responseObject);
        if ([responseObject[@"resultFlag"] integerValue] == 8001) {
            NSDictionary *resultDict = responseObject[@"result"];
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
@end
