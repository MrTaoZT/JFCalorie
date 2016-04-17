//
//  LeftViewController.m
//  Calorie
//
//  Created by xyl on 16/4/17.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "LeftViewController.h"
#import "SignInViewController.h"
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
        _nickName.text = @"18379151744";
    }else{
        _headImg.image = [UIImage imageNamed:@"headImgBG"];
        _nickName.text = @"未登录";
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(signIn)];
        [_headImg addGestureRecognizer:tap];
    }
}

#pragma mark - TabView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    //取消选中
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - signIn

- (void)signIn{
    SignInViewController *signIn = [Utilities getStoryboard:@"Main" instanceByIdentity:@"signInVc"];
    //这里用push 跳转到 signIn
}
@end
