//
//  MyCollectViewController.m
//  Calorie
//
//  Created by Z on 16/4/18.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "MyCollectViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "CollectSubpageTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ClubDetailViewController.h"
@interface MyCollectViewController ()<CLLocationManagerDelegate,UITableViewDataSource,UITableViewDelegate>{
    CGFloat jing;
    CGFloat wei;
    BOOL done;
    NSString *clubId;
    NSInteger count;
//    NSIndexPath *indexPath;
}
@property(nonatomic,strong)CLLocationManager *locMgr;
@property(nonatomic,strong)NSMutableArray *favorites;
@property(strong,nonatomic) NSMutableArray *deleteBooks;
@end

@implementation MyCollectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     // 设置tableView在编辑模式下可以多选，并且只需设置一次
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    [self getUserCoolect];
    
    done = NO;
    count = 2;
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    //初始化可变数组
    _favorites = [NSMutableArray new];
    _deleteBooks = [NSMutableArray new];
    
    _locMgr=[[CLLocationManager alloc]init];
    //设置代理
    _locMgr.delegate=self;
    
    //判断用户定位服务是否开启
    if ([CLLocationManager locationServicesEnabled]) {
        //开始定位用户的位置
        [_locMgr startUpdatingLocation];
        //每隔多少米定位一次（这里的设置为任何的移动）
        _locMgr.distanceFilter=kCLDistanceFilterNone;
        //设置定位的精准度，一般精准度越高，越耗电（这里设置为精准度最高的，适用于导航应用）
        _locMgr.desiredAccuracy=kCLLocationAccuracyBestForNavigation;
        }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - TabView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _favorites.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"1");
    CollectSubpageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (done) {
        NSDictionary *dic = _favorites[indexPath.row];
        NSURL *imageURL = dic[@"clubImage"];

        cell.clubName.text = dic[@"clubName"];
        cell.clubAddress.text = dic[@"clubAddress"];
        
        NSNumber *num = dic[@"distance"];
        cell.distance.text = [NSString stringWithFormat:@"%@米",num];
        [cell.clubImage sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@""]];
    }else{
        return cell;
    }
   
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if([_rightButton.title isEqualToString:@"编辑"]){
        //取消选中
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        ClubDetailViewController *clubDVc = [Utilities getStoryboard:@"Home" instanceByIdentity:@"ClubDetailView"];
        NSDictionary *dic = _favorites[indexPath.row];
        clubDVc.clubKeyId = dic[@"clubId"];
        [self.navigationController pushViewController:clubDVc animated:YES];
    }
    if ([_rightButton.title isEqualToString:@"确定"]) {
        
        [_deleteBooks addObject:[NSString stringWithFormat:@"%ld",indexPath.row]];
//        [_deleteBooks addObject:[_favorites objectAtIndex:indexPath.row]];
        NSLog(@"------------------%@",[NSString stringWithFormat:@"%ld",indexPath.row]);
        NSLog(@"--------------------------%@",_deleteBooks);
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    [_deleteBooks removeObject:[NSString stringWithFormat:@"%ld",indexPath.row]];
    NSLog(@"------------------%@",[NSString stringWithFormat:@"%ld",indexPath.row]);
    NSLog(@"--------------------------%@",_deleteBooks);
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 300;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
#pragma mark-GetUserCollect

- (void) getUserCoolect{
    
    NSString *memberId = [[StorageMgr singletonStorageMgr]objectForKey:@"memberId"];
    NSDictionary *dic = @{@"memberId":memberId,
                          @"jing":@(jing),
                          @"wei":@(wei),
                          @"favouriteId":@1
                          };
    
    [RequestAPI getURL:@"/mySelfController/getMyCollection" withParameters:dic success:^(id responseObject) {
                NSLog(@"obj === %@",responseObject);
        
        if ([responseObject[@"resultFlag"] integerValue] == 8001) {
            
            NSDictionary *result = responseObject[@"result"];
            _favorites = result[@"favorites"];
            NSLog(@"ffff%@",_favorites[0]);
            done = YES;
        }else {
            NSLog(@"错误码   修改！");
        }
        [_tableView reloadData];
    } failure:^(NSError *error) {
        [Utilities popUpAlertViewWithMsg:@"系统繁忙,定位失败" andTitle:nil onView:self];
        NSLog(@"error = %@",[error userInfo]);
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

        jing = 120.3;
        wei = 31.57;
        [self getUserCoolect];
    }else{

        [self getUserCoolect];
    }
    //停止更新位置（如果定位服务不需要实时更新的话，那么应该停止位置的更新）
    [_locMgr stopUpdatingLocation];
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
                [Utilities popUpAlertViewWithMsg:@"定位服务关闭，不可用" andTitle:nil onView:self];
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
- (IBAction)rightBtnAction:(UIBarButtonItem *)sender {
    
    if (count%2 == 0) {
        [_tableView setEditing:YES animated:YES];
        [_rightButton setTitle:@"确定"];
        count ++;
    }else{
        [_tableView setEditing:NO animated:YES];
        [_rightButton setTitle:@"编辑"];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"您确定要取消这些收藏吗" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *leftBtn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [_tableView setEditing:NO animated:YES];
            [_tableView setEditing:NO animated:YES];
            [_rightButton setTitle:@"编辑"];
            return ;
        }];
        UIAlertAction *rightBtn = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            for (int i = 0; i <= _deleteBooks.count - 1; i ++) {
                [_favorites removeObjectAtIndex:[_deleteBooks[i] integerValue]];
            }
            [_tableView reloadData];
        }];
        [alert addAction:leftBtn];
        [alert addAction:rightBtn];
        [self presentViewController:alert animated:YES completion:nil];
        count --;

    }
}

//-(void)deleteButtonPress:(UIButton*)sender
//{
//    //首先获得Cell：button的父视图是contentView，再上一层才是UITableViewCell
//    CollectSubpageTableViewCell *cell = (CollectSubpageTableViewCell*)sender.superview.superview;
//    
//    //然后使用indexPathForCell方法，就得到indexPath了~
//    indexPath = [_tableView indexPathForCell:cell];
//}
@end
