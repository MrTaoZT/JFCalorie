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
#import <UIImageView+WebCache.h>

@interface LeftViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong,nonatomic)NSMutableArray *objectForShow;
@property (strong, nonatomic)NSURL *url;

@end

@implementation LeftViewController

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
   
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //判断用户是否登录
    [self signInOrSignUp];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _objectForShow = [NSMutableArray new];
    //取消tableview下划线
    //    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //去掉tableView的滚动条
    self.tableView.showsVerticalScrollIndicator = NO;
   
    _tableView.delegate = self;
    _tableView.dataSource = self;

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(weatherShow:) name:@"setCity" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)signInOrSignUp{
    [_objectForShow removeAllObjects];
    //值如果是YES  则是登录了  else  NO则是未登录
    if([[[StorageMgr singletonStorageMgr]objectForKey:@"inOrUp"] boolValue]){
        
        PFQuery *query = [PFUser query];
        NSString *str = [Utilities getUserDefaults:@"imgURL"];
        if (str.length != 0) {
            NSLog(@"1");
            NSURL *url = [NSURL URLWithString:str];
            _url = url;
            [_headImg sd_setImageWithURL:_url];
        }else{
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (!error) {
                NSLog(@"2");
                _objectForShow = [NSMutableArray arrayWithArray:objects];
               PFFile *file = _objectForShow.firstObject[@"userImage"];
                NSLog(@"____________查询成功objectForShow = %@",file.url);
                _url = [NSURL URLWithString:file.url];
                [_headImg sd_setImageWithURL:_url];
                [Utilities removeUserDefaults:@"imgURL"];
                [Utilities setUserDefaults:@"imgURL" content:file.url];
            }
        }];
        }
        _nickName.text = [Utilities getUserDefaults:@"Username"];
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
        
        NavigationViewController *navView = [Utilities getStoryboard:@"Main" instanceByIdentity:@"nav"];
        //这里是当登录退出时  将全局变量SignUpSuccessfully  设置成yes   当调到  登录页面就会运行  viewWillA里的方法
        [[StorageMgr singletonStorageMgr]removeObjectForKey:@"SignUpSuccessfully"];
        [[StorageMgr singletonStorageMgr]addKey:@"SignUpSuccessfully" andValue:@YES];
        //接着给全局变量 键Username 值（_nickName.text）   这样登录退出后就会有用户名显示
        [[StorageMgr singletonStorageMgr]addKey:@"Username" andValue:_nickName.text];
        //缓存到 键为Username的值   homeTabVc  中能用到
        [Utilities removeUserDefaults:@"Username"];
        [Utilities setUserDefaults:@"Username" content:_nickName.text];
        [self presentViewController:navView animated:YES completion:nil];
    }else{
        [Utilities popUpAlertViewWithMsg:@"您当前未登录，请点击头像登录哦！" andTitle:nil onView:self];
    }
}

- (void)weatherShow:(NSNotification *)city{
    NSString *cityName = city.userInfo[@"city"];
    NSString *appID = @"529615526ff3a9a5dca577698b0be231";
    NSString *urlStr = @"http://api.openweathermap.org/data/2.5/weather";
    if (cityName.length == 0) {
        _weather.text = @"";
        _city.text = @"";
    }
    NSDictionary *dic = @{@"q":cityName, @"appid":appID};
    
    [[AppAPIClient sharedClient] GET:urlStr parameters:dic progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *mainDic = responseObject[@"main"];
        NSString *weatherStr = mainDic[@"temp_max"];
        NSInteger num = [weatherStr integerValue];
        NSString *weatherStrLast = [NSString stringWithFormat:@"%ld°C",(num - 273)];
        _weather.text = weatherStrLast;
        _city.text = cityName;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@",[error userInfo]);
    }];
}
@end
