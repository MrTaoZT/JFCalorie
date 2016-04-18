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

@interface LeftViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation LeftViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
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

#pragma mark - TabView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell1" forIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    //取消选中
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
        {
            if ([[[StorageMgr singletonStorageMgr]objectForKey:@"inOrUp"] boolValue]) {
                MessageNavViewController *messageNav = [Utilities getStoryboard:@"Home" instanceByIdentity:@"MessageNav"];
                [self presentViewController:messageNav animated:YES completion:nil];
            }else{
                [Utilities popUpAlertViewWithMsg:@"您当前未登录，请点击头像登录哦！" andTitle:nil onView:self];
            }
        }
            break;
        case 1:
        {
            if ([[[StorageMgr singletonStorageMgr]objectForKey:@"inOrUp"] boolValue]) {
                MessageNavViewController *workNav = [Utilities getStoryboard:@"Home" instanceByIdentity:@"WorkNav"];
                [self presentViewController:workNav animated:YES completion:nil];
            }else{
                [Utilities popUpAlertViewWithMsg:@"您当前未登录，请点击头像登录哦！" andTitle:nil onView:self];
            }
        }
            break;
        case 2:
        {
            if ([[[StorageMgr singletonStorageMgr]objectForKey:@"inOrUp"] boolValue]) {
                MessageNavViewController *collectNav = [Utilities getStoryboard:@"Home" instanceByIdentity:@"CollectNav"];
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
    //值如果是YES  则是登录了  else  NO则是未登录
    if ([[[StorageMgr singletonStorageMgr]objectForKey:@"inOrUp"] boolValue]) {
        
        SignInViewController *signIn = [Utilities getStoryboard:@"Main" instanceByIdentity:@"signInVc"];
        [[StorageMgr singletonStorageMgr]addKey:@"SignUpSuccessfully" andValue:@YES];
        [[StorageMgr singletonStorageMgr]addKey:@"Username" andValue:_nickName.text];
        [[StorageMgr singletonStorageMgr] removeObjectForKey:@"LeftUsername"];
        [self presentViewController:signIn animated:YES completion:nil];
    }else{
        
        [Utilities popUpAlertViewWithMsg:@"您当前未登录，请点击头像登录哦！" andTitle:nil onView:self];
    }
}
@end
