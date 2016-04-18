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

#import <UIImageView+WebCache.h>
#import <UIButton+WebCache.h>

#import "SportTypeTableViewController.h"
#import "ClubDetailViewController.h"

@interface HomeTableViewController () <CLLocationManagerDelegate>{
    BOOL sportOver;
    BOOL hotClubOver;
}

@property(nonatomic)CGFloat jing;
@property(nonatomic)CGFloat wei;

@property(nonatomic)NSInteger hotClubPage;
@property(nonatomic)NSInteger totalPage;

@property(nonatomic, strong)NSString *city;

//运动类型
@property(nonatomic, strong)NSMutableArray *sportTypeArray;
//热门俱乐部数据
@property(nonatomic, strong)NSMutableArray *hotClubInfoArray;

//位置管理
@property(nonatomic, strong)CLLocationManager *locationManager;

//刷新器
@property(nonatomic, strong)UIRefreshControl *refresh;

//页码控制
@property(nonatomic, strong)UIPageControl *pageControl;

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
    
    //网络请求运动类型
    [self getSportType];
    
    //获取附近热门会所
    //[self getHotClub];
    
    //user
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (hotClubOver) {
        return _hotClubInfoArray.count + 1;
    }else{
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        TitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"titleCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (sportOver) {
            [cell.sportTypeBtn1 sd_setBackgroundImageWithURL:_sportTypeArray[0][@"frontImgUrl"] forState:UIControlStateNormal];
            [cell.sportTypeBtn2 sd_setBackgroundImageWithURL:_sportTypeArray[1][@"frontImgUrl"] forState:UIControlStateNormal];
            [cell.sportTypeBtn3 sd_setBackgroundImageWithURL:_sportTypeArray[2][@"frontImgUrl"] forState:UIControlStateNormal];
            [cell.sportTypeBtn4 sd_setBackgroundImageWithURL:_sportTypeArray[3][@"frontImgUrl"] forState:UIControlStateNormal];
            [cell.sportTypeBtn5 sd_setBackgroundImageWithURL:_sportTypeArray[4][@"frontImgUrl"] forState:UIControlStateNormal];
            [cell.sportTypeBtn6 sd_setBackgroundImageWithURL:_sportTypeArray[5][@"frontImgUrl"] forState:UIControlStateNormal];
            [cell.sportTypeBtn7 sd_setBackgroundImageWithURL:_sportTypeArray[6][@"frontImgUrl"] forState:UIControlStateNormal];
            [cell.sportTypeBtn8 sd_setBackgroundImageWithURL:_sportTypeArray[7][@"frontImgUrl"] forState:UIControlStateNormal];
            
            [cell.sportTypeBtn1 addTarget:self action:@selector(sportAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.sportTypeBtn2 addTarget:self action:@selector(sportAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.sportTypeBtn3 addTarget:self action:@selector(sportAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.sportTypeBtn4 addTarget:self action:@selector(sportAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.sportTypeBtn5 addTarget:self action:@selector(sportAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.sportTypeBtn6 addTarget:self action:@selector(sportAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.sportTypeBtn7 addTarget:self action:@selector(sportAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.sportTypeBtn8 addTarget:self action:@selector(sportAction:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.sportTypeBtn1.tag = 1001;
            cell.sportTypeBtn2.tag = 1002;
            cell.sportTypeBtn3.tag = 1003;
            cell.sportTypeBtn4.tag = 1004;
            cell.sportTypeBtn5.tag = 1005;
            cell.sportTypeBtn6.tag = 1006;
            cell.sportTypeBtn7.tag = 1007;
            cell.sportTypeBtn8.tag = 1008;
        }
        return cell;
    }else{
        HotClubTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"clubCell" forIndexPath:indexPath];
        //设置cell按下无效果
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (hotClubOver) {
            //接下当前行对应的字典
            NSDictionary *tempDict = _hotClubInfoArray[indexPath.row - 1];
            //接受字典中的数组
            //NSArray *experienceArray = tempDict[@"experience"];
            
            cell.nameLabel.text = tempDict[@"name"];
            cell.addressLabel.text = tempDict[@"address"];
            cell.distanceLabel.text = [NSString stringWithFormat:@"距离%@米",tempDict[@"distance"]];
            cell.clubImageView.userInteractionEnabled = YES;
            [cell.clubImageView sd_setImageWithURL:tempDict[@"image"]];
        }
        return cell;
    }
}

//cell高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 190;
    }
    return 180;
}

//按下cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row != 0) {
        ClubDetailViewController *clubDetailView = [Utilities getStoryboard:@"Home" instanceByIdentity:@"ClubDetailView"];
        if (sportOver) {
            NSString *clubKeyId = _hotClubInfoArray[indexPath.row][@"clubKeyId"];
            clubDetailView.clubKeyId = clubKeyId;
            [self.navigationController pushViewController:clubDetailView animated:YES];
        }
    }
}

#pragma mark - private

- (void)initailAllControl{
    sportOver = NO;
    hotClubOver = NO;
    _sportTypeArray = [NSMutableArray new];
    _hotClubInfoArray = [NSMutableArray new];
    
    //初始化经纬度
    _jing = 0;
    _wei = 0;
    
    //初始化开始页面
    _hotClubPage = 1;
    
    //初始化刷新器
    [self initRefresh];
    
    //初始化广告
    [self initAD];
}

- (void)initAD{
    //广告
    _ADScrollView.delegate = self;
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_W, 80)];
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(UI_SCREEN_W, 0, UI_SCREEN_W, 80)];
    UIView *view3 = [[UIView alloc] initWithFrame:CGRectMake(UI_SCREEN_W * 2, 0, UI_SCREEN_W, 80)];
    view1.backgroundColor = [UIColor orangeColor];
    view2.backgroundColor = [UIColor blueColor];
    view3.backgroundColor = [UIColor blackColor];
    
    [_ADScrollView addSubview:view1];
    [_ADScrollView addSubview:view2];
    [_ADScrollView addSubview:view3];
    
    _ADScrollView.showsHorizontalScrollIndicator = NO;
    _ADScrollView.contentSize = CGSizeMake(UI_SCREEN_W * 3, 80);
    _ADScrollView.alwaysBounceHorizontal = YES;
    _ADScrollView.pagingEnabled = YES;
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
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        //开始持续获取设备坐标，更新位置
        [_locationManager startUpdatingLocation];
    }
}

//初始化刷新器
- (void)initRefresh{
    _refresh = [[UIRefreshControl alloc]init];
    
    NSString *title = [NSString stringWithFormat:@"刷新ing..."];
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSTextAlignmentCenter];
    [style setLineBreakMode:NSLineBreakByTruncatingTail];
    NSDictionary *attrsDictionary = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone),
                                      NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleBody],
                                      NSParagraphStyleAttributeName:style,
                                      NSForegroundColorAttributeName:[UIColor magentaColor]};
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
    _refresh.attributedTitle = attributedTitle;
    
    _refresh.tintColor = [UIColor orangeColor];
    _refresh.backgroundColor = [UIColor whiteColor];
    [_refresh addTarget:self action:@selector(conRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refresh];
}

//当第一次加载app完后才能刷新
- (void)conRefresh{
    if (!sportOver) {
        [self getSportType];
    }
    [self getHotClub];
}

//定位请求错误提示
-(void)checkError:(NSError *)error{
    switch (error.code) {
        case kCLErrorNetwork:{
            [Utilities popUpAlertViewWithMsg:@"没有网络连接" andTitle:@"" onView:self];
        }
            break;
        case kCLErrorDenied:{
            [Utilities popUpAlertViewWithMsg:@"您没有开定位" andTitle:@"" onView:self];
        }
            break;
        case kCLErrorLocationUnknown:{
            [Utilities popUpAlertViewWithMsg:@"获取位置失败" andTitle:@"" onView:self];
        }
            break;
        default:{
            [Utilities popUpAlertViewWithMsg:@"UnKnow Error" andTitle:@"" onView:self];
        }
            break;
    }
}

//首页按钮
- (void)sportAction:(UIButton *)sender{
    
    SportTypeTableViewController *sportTypeView = [Utilities getStoryboard:@"Home" instanceByIdentity:@"SportTypeView"];
    
    NSDictionary *tempDict = [NSDictionary new];
    if (hotClubOver) {
        switch (sender.tag) {
            case 1001:{
                tempDict = _sportTypeArray[0];
                break;
            }
            case 1002:{
                tempDict = _sportTypeArray[1];
                break;
            }
            case 1003:{
                tempDict = _sportTypeArray[2];
                break;
            }
            case 1004:{
                tempDict = _sportTypeArray[3];
                break;
            }
            case 1005:{
                tempDict = _sportTypeArray[4];
                break;
            }
            case 1006:{
                tempDict = _sportTypeArray[5];
                break;
            }
            case 1007:{
                tempDict = _sportTypeArray[6];
                break;
            }
            case 1008:{
                tempDict = _sportTypeArray[7];
                break;
            }
            default:{
                
                break;
            }
        }
        
        [self.navigationController pushViewController:sportTypeView animated:YES];
        NSString *fId = tempDict[@"id"];
        NSString *typeName = tempDict[@"name"];
        //将运动id和经纬度传过去
        sportTypeView.city = _city;
        sportTypeView.sportType = fId;
        sportTypeView.sportName = typeName;
        sportTypeView.setJing = _jing;
        sportTypeView.setWei = _wei;
    }
}

//逆地理编码
-(void)setAnnotatinAithDescriptionOnCoordinate:(CLLocationCoordinate2D)mapCoordinate completionHandler:(void(^)(NSDictionary * info))annotationCompletionHandler{
    //初始化一个地理编码对象
    CLGeocoder *geocoder = [CLGeocoder new];
    //将CLLocationCoordinate2D对象转换成CLLocation对象
    CLLocation *annotationLocation = [[CLLocation alloc]initWithLatitude:mapCoordinate.latitude longitude:mapCoordinate.longitude];
    //执行你地理编码方法
    [geocoder reverseGeocodeLocation:annotationLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (!error) {
            //获取成功得到逆地理编码的结果
            NSDictionary *info = [placemarks[0] addressDictionary];
            //NSLog(@"逆地理编码：%@",info);
            /*
             在此处触发annotationCompletionHandler这个block发生，并把info作为参数传递给方法执行方（乙方），此block会在逆地理编码成功后触发
             */
            annotationCompletionHandler(info);
        }else{
            [self checkError:error];
            annotationCompletionHandler(nil);
        }
    }];
}

#pragma mark - privateNet

- (void)getSportType{
    
    __weak HomeTableViewController *weakSelf = self;
    
    //获取健身项目分类列表url
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
            [Utilities popUpAlertViewWithMsg:[NSString stringWithFormat:@"请保持网络畅通,稍后试试吧%@",responseObject[@"resultFlag"]] andTitle:@"" onView:self];
        }
    } failure:^(NSError *error) {
        [Utilities popUpAlertViewWithMsg:@"请保持网络畅通" andTitle:@"" onView:self];
    }];
}

//获取热门俱乐部
- (void)getHotClub{
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
        [Utilities popUpAlertViewWithMsg:@"您没有给与位置权限" andTitle:@"" onView:self];
        return;
    }
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(_wei, _jing);
    __weak HomeTableViewController *weakSelf = self;
    //
    [self setAnnotatinAithDescriptionOnCoordinate:coordinate completionHandler:^(NSDictionary *info) {
        NSString *city = info[@"City"];
        NSString *cityNot = [city substringToIndex:city.length - 1];
        weakSelf.title = city;
        weakSelf.city= cityNot;
        if (weakSelf.refresh.isRefreshing) {
            _hotClubPage = 1;
        }
        NSInteger perPage = 5;
        
        NSDictionary *parameters = @{
                                     @"city":cityNot,
                                     @"jing":@(weakSelf.jing),
                                     @"wei":@(weakSelf.wei),
                                     @"page":@(weakSelf.hotClubPage),
                                     @"perPage":@(perPage)
                                     };
        //获取热门会所（及其体验券）列表
        NSString *nerUrl = @"/homepage/choice";
        
        //网络请求
        [RequestAPI getURL:nerUrl withParameters:parameters success:^(id responseObject) {
            if (weakSelf.refresh.isRefreshing) {
                [weakSelf.refresh endRefreshing];
            }
            if ([responseObject[@"resultFlag"] integerValue] == 8001) {
                //NSLog(@"%@",responseObject);
                
                //等于1表示是下拉刷新或者刚进入页面
                if (weakSelf.hotClubPage == 1) {
                    _hotClubInfoArray = nil;
                    _hotClubInfoArray = [NSMutableArray new];
                }
                
                NSDictionary *result = responseObject[@"result"];
                NSArray *info = result[@"models"];
                //封装数据
                for (int i = 0; i < info.count; i++) {
                    NSString *name = info[i][@"name"];
                    NSString *address = info[i][@"address"];
                    NSString *distance = info[i][@"distance"];
                    NSString *image = info[i][@"image"];
                    NSString *clubKeyId = info[i][@"id"];
                    
                    NSDictionary *dict = @{
                                           @"name":name,
                                           @"address":address,
                                           @"distance":distance,
                                           @"image":image,
                                           @"clubKeyId":clubKeyId
                                           };
                    [weakSelf.hotClubInfoArray addObject:dict];
                }
                //网络请求完毕后刷新cell（用于判断是否经历过第一次刷新）
                hotClubOver = YES;
                weakSelf.totalPage = [responseObject[@"totalPage"] integerValue];
                [weakSelf.tableView reloadData];
            }else{
                if ([responseObject[@"resultFlag"] integerValue] == 8020) {
                    [Utilities popUpAlertViewWithMsg:@"暂无数据" andTitle:@"" onView:weakSelf];
                    hotClubOver = YES;
                    return ;
                }
                [Utilities popUpAlertViewWithMsg: [NSString stringWithFormat:@"保持网络畅通，稍后再试%@",responseObject[@"resultFlag"]] andTitle:@"" onView:weakSelf];
            }
        } failure:^(NSError *error) {
            if (weakSelf.refresh.isRefreshing) {
                [weakSelf.refresh endRefreshing];
            }
            [Utilities popUpAlertViewWithMsg:@"请保持网络畅通" andTitle:@"" onView:weakSelf];
        }];
    }];
}

#pragma mark - CLLocationManagerDelegate

//定位开始执行
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation{
    if (newLocation.coordinate.latitude == oldLocation.coordinate.latitude && newLocation.coordinate.longitude == oldLocation.coordinate.longitude) {
        NSLog(@"获得完毕经纬度");
        _jing = newLocation.coordinate.longitude;
        _wei = newLocation.coordinate.latitude;
        [self getHotClub];
        [manager stopUpdatingLocation];
    }
}

//定位失败
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    [self checkError:error];
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

#pragma mark - UIScrollViewDelegate

//滚动(上拉刷新)
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (scrollView.contentSize.height + 64 > scrollView.frame.size.height ) {
        if(scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height + 74){
            _hotClubPage ++;
            [self getHotClub];
        }
    }else{
        if (scrollView.contentOffset.y > -64) {
            _hotClubPage ++;
            [self getHotClub];
        }
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

@end
