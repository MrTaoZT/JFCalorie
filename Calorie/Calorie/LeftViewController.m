//
//  LeftViewController.m
//  Calorie
//
//  Created by xyl on 16/4/17.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "LeftViewController.h"
#import "SignInViewController.h"
#import "NavigationViewController.h"
#import "MyMessageViewController.h"
#import "MyWorkViewController.h"
#import "MyCollectViewController.h"
#import "MessageNavViewController.h"
#import "WorkNavViewController.h"
#import "CollectNavViewController.h"
#import "MessageTableViewCell.h"
#import "WorkTableViewCell.h"
#import "CollectTableViewCell.h"

@interface LeftViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation LeftViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //判断用户上一次是否登录,且有没有退出登录
    [self lastOrLogin];
    //判断用户是否登录
    [self signInOrSignUp];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)signInOrSignUp{
    //值如果是YES  则是登录了  else  NO则是未登录
    if([[[StorageMgr singletonStorageMgr]objectForKey:@"inOrUp"] boolValue]){
        _headImg.image = [UIImage imageNamed:@"headImgBG"];
        _nickName.text = [[StorageMgr singletonStorageMgr] objectForKey:@"LeftUsername"];
    }else{
        _headImg.image = [UIImage imageNamed:@"headImgBG"];
        _nickName.text = @"未登录";
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(signIn)];
        [_headImg addGestureRecognizer:tap];
    }
}

- (void)lastOrLogin{
    //首先判断用户上次是否登录
    if([[Utilities getUserDefaults:@"OrLogin"] boolValue]){
        //如果登录了那么这里在判断  上一次是否按了退出按钮   yse  表示按了
        if ( [[Utilities getUserDefaults:@"AddUserAndPw"] boolValue]) {
//            [[StorageMgr singletonStorageMgr]removeObjectForKey:@"inOrUp"];
//            [StorageMgr singletonStorageMgr]addKey:@"" andValue:<#(id)#>
        }
    }
}
#pragma mark - TabView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
        {
            MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell1" forIndexPath:indexPath];
            return cell;
        }
            break;
        case 1:
        {
            WorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell2" forIndexPath:indexPath];
            return cell;
        }
            break;
        default:
        {
            CollectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell3" forIndexPath:indexPath];
            return cell;
        }
            break;
    }
//    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    //取消选中
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
        {
            if ([[[StorageMgr singletonStorageMgr]objectForKey:@"inOrUp"] boolValue]) {
                MessageNavViewController *messageNav = [Utilities getStoryboard:@"Sliding" instanceByIdentity:@"MessageNav"];
                [self presentViewController:messageNav animated:YES completion:nil];
            }else{
                [Utilities popUpAlertViewWithMsg:@"您当前未登录，请点击头像登录哦！" andTitle:nil onView:self];
            }
        }
            break;
        case 1:
        {
            if ([[[StorageMgr singletonStorageMgr]objectForKey:@"inOrUp"] boolValue]) {
                MessageNavViewController *workNav = [Utilities getStoryboard:@"Sliding" instanceByIdentity:@"WorkNav"];
                [self presentViewController:workNav animated:YES completion:nil];
            }else{
                [Utilities popUpAlertViewWithMsg:@"您当前未登录，请点击头像登录哦！" andTitle:nil onView:self];
            }
        }
            break;
        case 2:
        {
            if ([[[StorageMgr singletonStorageMgr]objectForKey:@"inOrUp"] boolValue]) {
                MessageNavViewController *collectNav = [Utilities getStoryboard:@"Sliding" instanceByIdentity:@"CollectNav"];
                [self presentViewController:collectNav animated:YES completion:nil];
            }else{
                [Utilities popUpAlertViewWithMsg:@"您当前未登录，请点击头像登录哦！" andTitle:nil onView:self];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - signIn

- (void)signIn{
    //因为 侧滑没有  导航体系  所以这边直接跳转到跳转类的导航条上
    NavigationViewController *navView = [Utilities getStoryboard:@"Main" instanceByIdentity:@"nav"];
    [self presentViewController:navView animated:YES completion:nil];
}

#pragma mark - signOut

- (IBAction)signOut:(UIButton *)sender forEvent:(UIEvent *)event {
    [Utilities removeUserDefaults:@"AddUserAndPw"];
    [Utilities setUserDefaults:@"AddUserAndPw" content:@NO];
    
    //值如果是YES  则是登录了  else  NO则是未登录
    if ([[[StorageMgr singletonStorageMgr]objectForKey:@"inOrUp"] boolValue]) {
        //缓存一个bool 类型 键名   可以判断下次登录是否自动显示账号密码
        [Utilities setUserDefaults:@"AddUserAndPw" content:@YES];
        
        SignInViewController *signIn = [Utilities getStoryboard:@"Main" instanceByIdentity:@"signInVc"];
        [[StorageMgr singletonStorageMgr]addKey:@"SignUpSuccessfully" andValue:@YES];
        [[StorageMgr singletonStorageMgr]addKey:@"Username" andValue:_nickName.text];
        [self presentViewController:signIn animated:YES completion:nil];
    }else{
        
        [Utilities popUpAlertViewWithMsg:@"您当前未登录，请点击头像登录哦！" andTitle:nil onView:self];
    }
}
@end
