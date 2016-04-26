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
#import "SearchViewController.h"
#import "CityTableViewController.h"

#import "UIScrollView+JElasticPullToRefresh.h"
#import "NavigationViewController.h"

@interface HomeTableViewController () <CLLocationManagerDelegate>{
    BOOL sportOver;
    BOOL hotClubOver;
    BOOL locationError;
    //防止刷新后没有网络上拉翻页页数增加
    BOOL loadingOver;
    BOOL isRefresh;
}

@property(nonatomic)CGFloat jing;
@property(nonatomic)CGFloat wei;

@property(nonatomic)NSInteger hotClubPage;
@property(nonatomic)NSInteger totalPage;

@property(nonatomic, strong)NSString *city;

@property(nonatomic, strong)NSDictionary *adDict;

//运动类型
@property(nonatomic, strong)NSMutableArray *sportTypeArray;
//热门俱乐部数据
@property(nonatomic, strong)NSMutableArray *hotClubInfoArray;

//位置管理
@property(nonatomic, strong)CLLocationManager *locationManager;

//刷新器
@property(nonatomic, strong)UIRefreshControl *refresh;

@end

@implementation HomeTableViewController

//每次页面出现
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"EnableGesture" object:nil];
    
}
//每次页面消失
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"DisableGesture" object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //取消tableview下划线
    //    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //去掉tableView的滚动条
    self.tableView.showsVerticalScrollIndicator = NO;
    
    [self initailAllControl];
    
    //初始化CLLocation
    [self initailCLLocation];
    
    //网络请求运动类型
    [self getSportType];
    
    //获取附近热门会所
    //[self getHotClub];
    
    //user
    [self setMD5RSA];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)lastOrLogin{
    //首先判断用户是否登录过
    if([[Utilities getUserDefaults:@"OrLogin"] boolValue]){
        //拿到缓存的密码
        NSString *username = [Utilities getUserDefaults:@"Username"];
        NSString *password = [Utilities getUserDefaults:@"Password"];
        if (username.length == 0 || password.length == 0) {
            return;
        }
        //如果登录了那么这里在判断  上一次是否按了退出按钮   yse  表示按了
        if ( [[Utilities getUserDefaults:@"AddUserAndPw"] boolValue]) {
            
            //表示用户 登录后  按了退出  这边依旧设置未登录  因为这里是默认从appdelage 进入  所以  全局变量inOrup  这边默认是NO （也就是未登录）
            //然后让  SignUpSuccessfully这个键为YES   那么在进入登录界面时  会运行  viewWillA 里面的放法
            [[StorageMgr singletonStorageMgr]removeObjectForKey:@"SignUpSuccessfully"];
            [[StorageMgr singletonStorageMgr]addKey:@"SignUpSuccessfully" andValue:@YES];
            //最后把  之前退出时  缓存了一个Username 的值给  全局变量 的Username    这样退出之后就会有用户名显示
            [[StorageMgr singletonStorageMgr]addKey:@"Username" andValue:[Utilities getUserDefaults:@"Username"]];
            return;
        }
        //这里是当判断到用户有登陆过  并且没有退出过   开启APP时   默认请求登录
        NSString *exponent = [[StorageMgr singletonStorageMgr] objectForKey:@"exponent"];
        NSString *modulus = [[StorageMgr singletonStorageMgr] objectForKey:@"modulus"];
        //MD5将原始密码进行MD5加密
        NSString *MD5Pwd = [password getMD5_32BitString];
        //将MD5加密过后的密码进行RSA非对称加密
        NSString *RSAPwd = [NSString encryptWithPublicKeyFromModulusAndExponent:MD5Pwd.UTF8String modulus:modulus exponent:exponent];
        
        NSDictionary *dic = @{@"userName":username,
                              @"password":RSAPwd,
                              @"deviceType":@7001,
                              @"deviceId":[Utilities uniqueVendor]};
        
        [RequestAPI postURL:@"/login" withParameters:dic success:^(id responseObject) {
            //NSLog(@"obj =======  %@",responseObject);
            if ([responseObject[@"resultFlag"] integerValue] == 8001) {
                NSLog(@"自动登录成功");
                NSDictionary *result = responseObject[@"result"];
                
                //这里将 全局变量键inOrUp  设置成yes  就可以运行leftVC  里的viewWillA  里的方法
                [[StorageMgr singletonStorageMgr]removeObjectForKey:@"inOrUp"];
                [[StorageMgr singletonStorageMgr]addKey:@"inOrUp" andValue:@YES];
                
                //紧接着这边给缓存  键Username  给值（result[@"contactTel"]）
                [Utilities removeUserDefaults:@"Username"];
                [Utilities setUserDefaults:@"Username" content:result[@"contactTel"]];
                
                //这里获取到  ID  并存进全局变量
                NSString *memberId = result[@"memberId"];
                [[StorageMgr singletonStorageMgr]removeObjectForKey:@"memberId"];
                [[StorageMgr singletonStorageMgr]addKey:@"memberId" andValue:memberId];
                
                NSDictionary *dict = @{@"memberId":result[@"memberId"],
                                       @"memberSex":result[@"memberSex"],
                                       @"memberName":result[@"memberName"],
                                       @"birthday":result[@"birthday"],
                                       @"identificationcard":result[@"identificationcard"]
                                       };
                [[StorageMgr singletonStorageMgr]removeObjectForKey:@"dict"];
                [[StorageMgr singletonStorageMgr]addKey:@"dict" andValue:dict];
            }else{
                [Utilities popUpAlertViewWithMsg:@"登录失败，请保持网络通畅" andTitle:nil onView:self];
                NavigationViewController *navView = [Utilities getStoryboard:@"Main" instanceByIdentity:@"nav"];
                [self presentViewController:navView animated:YES completion:nil];
            }
        } failure:^(NSError *error) {
            [Utilities popUpAlertViewWithMsg:@"系统繁忙,请重新登录" andTitle:nil onView:self];
            NavigationViewController *navView = [Utilities getStoryboard:@"Main" instanceByIdentity:@"nav"];
            [self presentViewController:navView animated:YES completion:nil];
        }];
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (hotClubOver) {
        return _hotClubInfoArray.count + 2;
    }else{
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        TitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"titleCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (sportOver) {
            //[cell.sportTypeBtn1 sd_setBackgroundImageWithURL:_sportTypeArray[0][@"backImgUrl"] forState:UIControlStateNormal];
            [cell.sportTypeBtn1 sd_setImageWithURL:_sportTypeArray[0][@"frontImgUrl"] forState:UIControlStateNormal];
            [cell.sportTypeBtn2 sd_setImageWithURL:_sportTypeArray[1][@"frontImgUrl"] forState:UIControlStateNormal];
            [cell.sportTypeBtn3 sd_setImageWithURL:_sportTypeArray[2][@"frontImgUrl"] forState:UIControlStateNormal];
            [cell.sportTypeBtn4 sd_setImageWithURL:_sportTypeArray[3][@"frontImgUrl"] forState:UIControlStateNormal];
            [cell.sportTypeBtn5 sd_setImageWithURL:_sportTypeArray[4][@"frontImgUrl"] forState:UIControlStateNormal];
            [cell.sportTypeBtn6 sd_setImageWithURL:_sportTypeArray[5][@"frontImgUrl"] forState:UIControlStateNormal];
            [cell.sportTypeBtn7 sd_setImageWithURL:_sportTypeArray[6][@"frontImgUrl"] forState:UIControlStateNormal];
            [cell.sportTypeBtn8 sd_setImageWithURL:_sportTypeArray[7][@"frontImgUrl"] forState:UIControlStateNormal];
            
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
    }if (indexPath.row == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellLabel" forIndexPath:indexPath];
        return cell;
    }else{
        HotClubTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"clubCell" forIndexPath:indexPath];
        
        //设置cell按下无效果
        //cell.clubImageView.contentMode = UIViewContentModeScaleAspectFill;
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (hotClubOver && _hotClubInfoArray[indexPath.row - 2]) {
            //接下当前行对应的字典
            NSDictionary *tempDict = _hotClubInfoArray[indexPath.row - 2];
            //接受字典中的数组
            //NSArray *experienceArray = tempDict[@"experience"];
            //NSLog(@"cellShow");
            
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
    }else if(indexPath.row == 1){
        return 30;
    }
    return 220;
}

//按下cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row != 0) {
        ClubDetailViewController *clubDetailView = [Utilities getStoryboard:@"Home" instanceByIdentity:@"ClubDetailView"];
        if (sportOver) {
            NSString *clubKeyId = _hotClubInfoArray[indexPath.row - 2][@"id"];
            //NSLog(@"id%@",clubKeyId);
            clubDetailView.clubKeyId = clubKeyId;
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:clubDetailView animated:YES];
            self.hidesBottomBarWhenPushed = NO;
        }
    }
}

#pragma mark - private

- (void)initailAllControl{
    sportOver = NO;
    locationError = NO;
    loadingOver = NO;
    isRefresh = NO;
    hotClubOver = YES;
    _sportTypeArray = [NSMutableArray new];
    _hotClubInfoArray = [NSMutableArray new];
    
    //初始化经纬度
    _jing = 0;
    _wei = 0;
    _city = @"无锡";
    [_chooseLocationButton setTitle:@"无锡" forState:UIControlStateNormal];
    
    //初始化开始页面
    _hotClubPage = 1;
    
    //初始化刷新器
    [self initRefresh];
    
}

- (void)getCityName{
    CLGeocoder *geocoder = [CLGeocoder new];
    CLLocation *annotationLocation = [[CLLocation alloc]initWithLatitude:_wei longitude:_jing];
    [geocoder reverseGeocodeLocation:annotationLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (!error) {
            NSDictionary *info = [placemarks[0] addressDictionary];
            NSString *name = info[@"City"];
            if (name != nil) {
                _city = [name substringToIndex:name.length - 1];
                [[StorageMgr singletonStorageMgr] addKey:@"jing" andValue:@(_jing)];
                [[StorageMgr singletonStorageMgr]addKey:@"wei" andValue:@(_wei)];
                [[StorageMgr singletonStorageMgr] addKey:@"cityName" andValue:_city];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setCity" object:nil userInfo:@{@"city":_city}];
                [self getHotClub];
                NSLog(@"%@",_city);
            }else{
                [Utilities popUpAlertViewWithMsg:@"位置异常,默认无锡" andTitle:@"" onView:self];
            }
        }else{
            [self chooseCity];
            NSLog(@"城市获取失败");
        }
    }];
}

- (void)btnAction{
    for (int i = 1001; i <= 1008 ; i++) {
        UIButton *button = [self.tableView viewWithTag:i];
        [button addTarget:self action:@selector(sportAction:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)initAD{
    _ADScrollView.delegate = self;
    if (loadingOver) {
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_W, 110)];
        image.contentMode = UIViewContentModeScaleAspectFill;
        [image sd_setImageWithURL:_adDict[@"imgurl"]];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(AdAction)];
        [_ADScrollView addGestureRecognizer:tap];
        [_ADScrollView addSubview:image];
        _ADScrollView.showsHorizontalScrollIndicator = NO;
        _ADScrollView.contentSize = CGSizeMake(UI_SCREEN_W + 2, 110);
        //_ADScrollView.alwaysBounceHorizontal =YES;
        _ADScrollView.pagingEnabled = YES;
    }
}

- (void)AdAction{
    
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
    
    JElasticPullToRefreshLoadingViewCircle *loadingViewCircle = [[JElasticPullToRefreshLoadingViewCircle alloc] init];
    loadingViewCircle.tintColor = [UIColor whiteColor];
    
    
    __weak __typeof(self)weakSelf = self;
    [self.tableView addJElasticPullToRefreshViewWithActionHandler:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.self conRefresh];
        });
    } LoadingView:loadingViewCircle];
    
    //波浪颜色 透明度
    [self.tableView setJElasticPullToRefreshFillColor:[UIColor colorWithRed:0.0431 green:0.7569 blue:0.9412 alpha:1]];
    //空白地方颜色
    [self.tableView setJElasticPullToRefreshBackgroundColor:[UIColor orangeColor]];
}

//当第一次加载app完后才能刷新
- (void)conRefresh{
    //获得运动类型
    if (!sportOver) {
        [self getSportType];
    }
    //获得热门俱乐部
    _hotClubPage = 1;
    isRefresh  =YES;
    [self getHotClub];
}

//定位请求错误提示
-(void)checkError:(NSError *)error{
    switch (error.code) {
        case kCLErrorNetwork:{
            NSLog(@"没有网络连接");
            //[Utilities popUpAlertViewWithMsg:@"没有网络连接" andTitle:@"" onView:self];
        }
            break;
        case kCLErrorDenied:{
            NSLog(@"您没有开定位");
            //[Utilities popUpAlertViewWithMsg:@"您没有开定位" andTitle:@"" onView:self];
        }
            break;
        case kCLErrorLocationUnknown:{
            NSLog(@"获取位置失败");
            //[Utilities popUpAlertViewWithMsg:@"获取位置失败" andTitle:@"" onView:self];
        }
            break;
        default:{
            //[Utilities popUpAlertViewWithMsg:@"UnKnow Error" andTitle:@"" onView:self];
        }
            break;
    }
}

//首页按钮
- (void)sportAction:(UIButton *)sender{
    
    SportTypeTableViewController *sportTypeView = [Utilities getStoryboard:@"Home" instanceByIdentity:@"SportTypeView"];
    
    NSDictionary *tempDict = [NSDictionary new];
    if (!locationError) {
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
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:sportTypeView animated:YES];
        self.hidesBottomBarWhenPushed = NO;
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
    //NSLog(@"刷新？%d",_refresh.isRefreshing);
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
        [Utilities popUpAlertViewWithMsg:@"您没有给与位置权限" andTitle:@"" onView:self];
        [self.tableView stopLoading];
        return;
    }
    
    //没有位置不能获得经纬度
    if (locationError) {
        [self.tableView stopLoading];
        return;
    }
    
    __weak HomeTableViewController *weakSelf = self;
    [weakSelf loadDataEnd];
    NSInteger perPage = 5;
    
    NSDictionary *parameters = @{
                                 @"city":_city,
                                 @"jing":@(weakSelf.jing),
                                 @"wei":@(weakSelf.wei),
                                 @"page":@(weakSelf.hotClubPage),
                                 @"perPage":@(perPage)
                                 };
    //获取热门会所（及其体验券）列表
    NSString *nerUrl = @"/homepage/choice";
    
    //网络请求
    [RequestAPI getURL:nerUrl withParameters:parameters success:^(id responseObject) {
        hotClubOver = YES;
        //初始化按钮事件
        [self btnAction];
        if (isRefresh) {
            [weakSelf.tableView stopLoading];
            isRefresh = NO;
        }
        if ([responseObject[@"resultFlag"] integerValue] == 8001) {
            NSLog(@"%@",responseObject);
            
            //等于1表示是下拉刷新或者刚进入页面
            if (weakSelf.hotClubPage == 1) {
                _hotClubInfoArray = nil;
                _hotClubInfoArray = [NSMutableArray new];
            }
            
            NSDictionary *result = responseObject[@"result"];
            NSArray *info = result[@"models"];
            NSDictionary *pagingInfo = result[@"pagingInfo"];
            //广告
            NSArray *array = responseObject[@"advertisement"];
            _adDict = array.firstObject;
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
                                       @"id":clubKeyId
                                       };
                [weakSelf.hotClubInfoArray addObject:dict];
            }
            //网络请求完毕后刷新cell（用于判断是否经历过第一次刷新）
            loadingOver = YES;
            weakSelf.totalPage = [pagingInfo[@"totalPage"] integerValue];
            //NSLog(@"totalPage:%ld",[pagingInfo[@"totalPage"] integerValue]);
            //初始化广告
            [self initAD];
            [weakSelf.tableView reloadData];
        }else{
            if ([responseObject[@"resultFlag"] integerValue] == 8020) {
                [Utilities popUpAlertViewWithMsg:@"暂无数据" andTitle:@"" onView:weakSelf];
                return ;
            }
            [Utilities popUpAlertViewWithMsg: [NSString stringWithFormat:@"保持网络畅通，稍后再试%@",responseObject[@"resultFlag"]] andTitle:@"" onView:weakSelf];
        }
    } failure:^(NSError *error) {
        if (isRefresh) {
            [weakSelf.tableView stopLoading];
            isRefresh = NO;
        }
        [Utilities popUpAlertViewWithMsg:@"请保持网络畅通" andTitle:@"" onView:weakSelf];
    }];
}

#pragma mark - CLLocationManagerDelegate

//定位开始执行
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation{
    if (newLocation.coordinate.latitude == oldLocation.coordinate.latitude && newLocation.coordinate.longitude == oldLocation.coordinate.longitude) {
        NSLog(@"获得完毕经纬度");
        locationError = NO;
        _jing = newLocation.coordinate.longitude;
        _wei = newLocation.coordinate.latitude;
        [self getCityName];
        [manager stopUpdatingLocation];
    }
}

//定位失败
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    locationError = YES;
    [self checkError:error];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"位置获取失败请手动选择" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //定位获取失败，让用户自己选城市
        [self chooseCity];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:confirm];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
    
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
            [self createTableFooter];
            [self loadDataing];
        }
    }else{
        if (scrollView.contentOffset.y > -64) {
            [self createTableFooter];
            [self loadDataing];
        }
    }
}

-(void)createTableFooter{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 40)];
    footerView.backgroundColor = [UIColor blackColor];
    self.tableView.tableFooterView = footerView;
    
    UILabel *loadMore = [[UILabel alloc]initWithFrame:CGRectMake((UI_SCREEN_W - 120)  / 2 , 0, 120, 40)];
    //loadMore.backgroundColor = [UIColor brownColor];
    loadMore.textColor = [UIColor whiteColor];
    loadMore.textAlignment = NSTextAlignmentCenter;
    loadMore.tag = 10086;
    loadMore.text = @"加载中...";
    loadMore.font = [UIFont systemFontOfSize:B_Font];
    loadMore.textColor = [UIColor lightGrayColor];
    [footerView addSubview:loadMore];
    
    //    UIActivityIndicatorView *acFooter = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(UI_SCREEN_W / 2 - 40, 10, 20, 20)];
    //    acFooter.tag = 10010;
    //    acFooter.color = [UIColor orangeColor];
    //    [footerView addSubview:acFooter];
    //    [acFooter startAnimating];
    
}

-(void)loadDataing{
    //判断是否还存在下一页
    if (_totalPage > _hotClubPage) {
        if (loadingOver) {
            //之前如果是yes说明正常进入了网络请求，页数加一，把加载成功改为NO
            _hotClubPage ++;
            loadingOver = NO;
            [self getHotClub];
        }
    }else{
        [self beforeLoadEnd];
        [self performSelector:@selector(loadDataEnd) withObject:nil afterDelay:1.0f];
    }
}

- (void)beforeLoadEnd{
    UILabel *loadMore = (UILabel *)[self.tableView.tableFooterView viewWithTag:10086];
    //UIActivityIndicatorView *acFooter = (UIActivityIndicatorView *)[self.tableView.tableFooterView viewWithTag:10010];
    loadMore.text = @"没有更多数据";
    loadMore.frame = CGRectMake((UI_SCREEN_W - 120)  / 2 , 0, 120, 40);
    //[acFooter stopAnimating];
    //acFooter = nil;
}

- (void)loadDataEnd{
    self.tableView.tableFooterView =[[UIView alloc]init];
}

#pragma mark - titleAction

- (IBAction)chooseLocationAction:(UIButton *)sender forEvent:(UIEvent *)event {
    [self chooseCity];
}

- (IBAction)searchAction:(UIBarButtonItem *)sender {
    
    SearchViewController *searchView = [Utilities getStoryboard:@"Home" instanceByIdentity:@"SearchView"];
    if (!locationError) {
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:searchView animated:YES];
        searchView.jing = _jing;
        searchView.wei = _wei;
        self.hidesBottomBarWhenPushed = NO;
    }else{
        [Utilities popUpAlertViewWithMsg:@"正在获取位置,稍等" andTitle:@"" onView:self];
    }
}

- (void)chooseCity{
    CityTableViewController *cityView = [Utilities getStoryboard:@"Home" instanceByIdentity:@"CityView"];
    //if (loadingOver) {
    [self.navigationController pushViewController:cityView animated:YES];
    //}
    cityView.cityBlock = ^(NSString *city, NSString *postalCode){
        [_chooseLocationButton setTitle:city forState:UIControlStateNormal];
        _city = postalCode;
        NSLog(@"%@,%@",city,postalCode);
        locationError = NO;
        [self getHotClub];
    };
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

#pragma mark - setMD5RSA

- (void)setMD5RSA{
    //获取模数指数
    NSDictionary *dic = @{@"deviceType":@7001,
                          @"deviceId":[Utilities uniqueVendor]
                          };
    
    [RequestAPI getURL:@"/login/getKey" withParameters:dic success:^(id responseObject) {
        //NSLog(@"responseObject : %@",responseObject);
        if ([responseObject[@"resultFlag"] integerValue] == 8001) {
            NSDictionary *resultDict = responseObject[@"result"];
            NSString *exponent = resultDict[@"exponent"];
            NSString *modulus = resultDict[@"modulus"];
            //从单例化全局变量中删除数据
            [[StorageMgr singletonStorageMgr] removeObjectForKey:@"exponent"];
            [[StorageMgr singletonStorageMgr] removeObjectForKey:@"modulus"];
            
            [[StorageMgr singletonStorageMgr] addKey:@"exponent" andValue:exponent];
            [[StorageMgr singletonStorageMgr] addKey:@"modulus" andValue:modulus];
            
            [self lastOrLogin];
        }else{
            NSLog(@"resultFailed");
        }
        
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
    
}
- (IBAction)leftButton:(UIBarButtonItem *)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"MenuSwitch" object:nil];
}
@end
