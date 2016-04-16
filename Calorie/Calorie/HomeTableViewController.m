//
//  HomeTableViewController.m
//  Calorie
//
//  Created by 杨凡 on 16/4/16.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "HomeTableViewController.h"

#import "TitleTableViewCell.h"
#import "HotClubTableViewCell.h"

#import <MapKit/MapKit.h>

@interface HomeTableViewController () <CLLocationManagerDelegate>{
    BOOL sportOver;
    CGFloat jing;
    CGFloat wei;
}

@property(nonatomic, strong)NSMutableArray *sportTypeArray;
@property(nonatomic, strong)CLLocationManager *locationManager;

@end

@implementation HomeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //取消tableview下划线
//    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self initailAllControl];
    
    //初始化CLLocation
    [self initailCLLocation];
    
    //网络请求拿去运动类型
    [self getSportType];
    
    //获取附近热门会所
    [self getHotClub];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        TitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"titleCell" forIndexPath:indexPath];
        if (sportOver) {
            [cell.sportTypeBtn1 setTitle:_sportTypeArray[0][@"name"] forState:UIControlStateNormal];
            [cell.sportTypeBtn2 setTitle:_sportTypeArray[1][@"name"] forState:UIControlStateNormal];
            [cell.sportTypeBtn3 setTitle:_sportTypeArray[2][@"name"] forState:UIControlStateNormal];
            [cell.sportTypeBtn4 setTitle:_sportTypeArray[3][@"name"] forState:UIControlStateNormal];
            [cell.sportTypeBtn5 setTitle:_sportTypeArray[4][@"name"] forState:UIControlStateNormal];
            [cell.sportTypeBtn6 setTitle:_sportTypeArray[5][@"name"] forState:UIControlStateNormal];
            [cell.sportTypeBtn7 setTitle:_sportTypeArray[6][@"name"] forState:UIControlStateNormal];
            [cell.sportTypeBtn8 setTitle:_sportTypeArray[7][@"name"] forState:UIControlStateNormal];
            sportOver = NO;
        }
        return cell;
    }else{
        HotClubTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"clubCell" forIndexPath:indexPath];
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 203;
    }
    return 150;
}

#pragma mark - private

- (void)initailAllControl{
    sportOver = NO;
    _sportTypeArray = [NSMutableArray new];
    
    jing = 0;
    wei = 0;
    
}

- (void)initailCLLocation{
    _locationManager = [[CLLocationManager alloc]init];
    _locationManager.delegate = self;
    //表示每移动对少距离可以被识别
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    //表示把地球分割的精度，分割成边长为多少的小方块
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    //判断有没有决定过要不要使用定位功能(如果没有就执行if语句的操作)
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
#ifdef __IPHONE_8_0
        [_locationManager requestWhenInUseAuthorization];
#endif
    }
    //开始持续获取设备坐标，更新位置
    [_locationManager startUpdatingLocation];
    dispatch_time_t time =  dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        [_locationManager stopUpdatingLocation];
    });
}

#pragma mark - privateNet

- (void)getSportType{
    
    __weak HomeTableViewController *weakSelf = self;
    
    NSString *netUrl = @"/homepage/category";
    NSInteger page = 1;
    NSInteger perPage = 10;
    
    NSDictionary *parameters = @{
                                 @"page":@(page),
                                 @"perPage":@(perPage)
                                 };
    
    //网络请求
    [RequestAPI getURL:netUrl withParameters:parameters success:^(id responseObject) {
        if ([responseObject[@"resultFlag"] integerValue] == 8001) {
            NSDictionary *result = responseObject[@"result"];
            //数据解析得到name
            _sportTypeArray = result[@"models"];
            //NSLog(@"%@",_sportTypeArray);
            sportOver = YES;
            [weakSelf.tableView reloadData];
        }else{
            [Utilities popUpAlertViewWithMsg:@"请保持网络畅通,稍后试试吧" andTitle:@"" onView:self];
        }
    } failure:^(NSError *error) {
        [Utilities popUpAlertViewWithMsg:@"请保持网络畅通" andTitle:@"" onView:self];
    }];
}

- (void)getHotClub{
    NSString *nerUrl = @"/homepage/choice";
    
    //参数配置
    NSString *city = @"0510";
    CGFloat setJing = jing;
    CGFloat setWei  = wei;
    NSInteger page = 1;
    NSInteger perPage = 10;
    
    NSDictionary *parameters = @{
                                 @"city":city,
                                 @"jing":@(setJing),
                                 @"wei":@(setWei),
                                 @"page":@(page),
                                 @"perPage":@(perPage)
                                 };
    [RequestAPI getURL:nerUrl withParameters:parameters success:^(id responseObject) {
        if ([responseObject[@"resultFlag"] integerValue] == 8001) {
            NSLog(@"%@",responseObject);
        }
    } failure:^(NSError *error) {
        [Utilities popUpAlertViewWithMsg:@"请保持网络畅通" andTitle:@"" onView:self];
    }];
    
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation{
    if (newLocation.coordinate.latitude == oldLocation.coordinate.latitude && newLocation.coordinate.longitude == oldLocation.coordinate.longitude) {
        jing = newLocation.coordinate.longitude;
        wei = newLocation.coordinate.latitude;
        [manager stopUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    [Utilities popUpAlertViewWithMsg:@"获取位置失败" andTitle:@"" onView:self];
}

/** 定位服务状态改变时调用*/
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        {
            NSLog(@"用户还未决定授权");
            break;
        }
        case kCLAuthorizationStatusRestricted:
        {
            NSLog(@"访问受限");
            break;
        }
        case kCLAuthorizationStatusDenied:
        {
            // 类方法，判断是否开启定位服务
            if ([CLLocationManager locationServicesEnabled]) {
                NSLog(@"定位服务开启，被拒绝");
            } else {
                NSLog(@"定位服务关闭，不可用");
            }
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways:
        {
            NSLog(@"获得前后台授权");
            break;
        }
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            NSLog(@"获得前台授权");
            break;
        }
        default:
            break;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
