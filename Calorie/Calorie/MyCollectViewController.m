//
//  MyCollectViewController.m
//  Calorie
//
//  Created by Z on 16/4/18.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "MyCollectViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface MyCollectViewController ()<CLLocationManagerDelegate>{
    CGFloat jing;
    CGFloat wei;
}
@property(nonatomic,strong)CLLocationManager *locMgr;
@end

@implementation MyCollectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _locMgr=[[CLLocationManager alloc]init];
    //设置代理
    _locMgr.delegate=self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark-GetUserCollect

- (void) getUserCoolect{
    NSString *memberId = [[StorageMgr singletonStorageMgr]objectForKey:@"memberId"];
    NSDictionary *dic = @{@"memberId":memberId,
                         @"jing":@(jing),
                         @"wei":@(wei),
                         @"favouriteId":@1,
                            };
    [RequestAPI getURL:@"/mySelfController/memberScore" withParameters:dic success:^(id responseObject) {
        NSLog(@"obj === %@",responseObject);
        if ([responseObject[@"resultFlag"]]) {
            <#statements#>
        }
        
    } failure:^(NSError *error) {
        [Utilities popUpAlertViewWithMsg:@"系统繁忙,定位失败" andTitle:nil onView:self];
    }];
}

#pragma mark-CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    //locations数组里边存放的是CLLocation对象，一个CLLocation对象就代表着一个位置
    CLLocation *loc = [locations firstObject];
    
    //维度：loc.coordinate.latitude
    //经度：loc.coordinate.longitude
    jing = loc.coordinate.longitude;
    wei = loc.coordinate.latitude;
    NSLog(@"latitude = %f",loc.coordinate.latitude);
    NSLog(@"longitude = %f",loc.coordinate.longitude);
    NSString *longitude = [NSString stringWithFormat:@"%f",jing];
    NSString *latitude = [NSString stringWithFormat:@"%f",wei];
    if (longitude.length == 0 || latitude.length == 0) {
        jing = 120;
        wei = 120;
        [self getUserCoolect];
    }else{
        [self getUserCoolect];
    }
    //停止更新位置（如果定位服务不需要实时更新的话，那么应该停止位置的更新）
//    [_locMgr stopUpdatingLocation];
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
                [Utilities popUpAlertViewWithMsg:@"您未对本程序授权定位，您可前往设置打开本app的定位，可更好的为您服务" andTitle:@"" onView:self];
            } else {
                NSLog(@"定位服务关闭，不可用");
                [Utilities popUpAlertViewWithMsg:@"定位服务关闭，不可用" andTitle:@"" onView:self];
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
@end
