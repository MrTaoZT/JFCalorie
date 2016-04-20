//
//  SearchViewController.m
//  Calorie
//
//  Created by Z on 16/4/19.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchTableViewCell.h"
#import "CityTableViewController.h"

#import <UIImageView+WebCache.h>

@interface SearchViewController (){
    BOOL loadOver;
    BOOL cityLoadOver;
}

@property(nonatomic)NSInteger page;
@property(nonatomic)NSInteger perPage;
@property(nonatomic,strong)NSString *city;
@property(nonatomic)NSInteger typeInt;
@property(nonatomic, strong)NSString *keyword;

@property(nonatomic, strong)NSMutableArray *dataArray;

@property(nonatomic, strong)NSMutableArray *cityArray;
@property(nonatomic, strong)NSArray *hotArray;
@property(nonatomic, strong)NSArray *upgradedArray;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    loadOver = NO;
    cityLoadOver = NO;
    _page = 1;
    _perPage = 5;
    //默认按距离排序
    _typeInt = 0;
    
    _dataArray = [NSMutableArray new];
    _hotArray = [NSMutableArray new];
    _upgradedArray = [NSMutableArray new];
    
    _keyword = _searchTextField.text;
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    // Do any additional setup after loading the view.
}
//
//- (void)getCity{
//    __weak SearchViewController *weakSelf = self;
//
//    NSString *netUrl = @"/city/hotAndUpgradedList";
//    
//    [RequestAPI getURL:netUrl withParameters:nil success:^(id responseObject) {
//        //NSLog(@"responseObject..%@",responseObject);
//        if ([responseObject[@"resultFlag"] integerValue] == 8001) {
//            NSDictionary *result = responseObject[@"result"];
//            weakSelf.hotArray = result[@"hot"];
//            weakSelf.upgradedArray = result[@"upgraded"];
//            cityLoadOver = YES;
//            [weakSelf.cityTableView reloadData];
//        }else{
//            [Utilities popUpAlertViewWithMsg:@"请稍后重试" andTitle:@"" onView:self];
//            //返回
//            //[self.navigationController popViewControllerAnimated:YES];
//        }
//    } failure:^(NSError *error) {
//        [Utilities popUpAlertViewWithMsg:@"请保持网络畅通" andTitle:@"" onView:self];
//    }];
//}

- (void)requestData{
    __weak SearchViewController *weakSelf = self;
    //搜索API
    NSString *netUrl = @"/clubController/nearSearchClub";
    /*
     city：城市区号（用户选择的查询城市）
     jing：用户当前位置经度
     wei：用户当前位置纬度
     page：当前页码
     perPage：每页数量
     type：排序类型（0：按距离；1：按人气）
     可选featureId：需要查询的健身类型ID
     可选brandId：需要查询的品牌ID
     可选distance：查询附近多少米范围
     可选areaId：需要查询的区ID
     可选streetId：需要查询的街道ID
     可选keyword：需要查询的关键字
     */
    
    _city = @"0510";
    
    NSDictionary *parameters = @{
                                  @"city":_city,
                                  @"jing":@(_jing),
                                  @"wei":@(_wei),
                                  @"page":@(_page),
                                  @"perPage":@(_perPage),
                                  @"type":@(_typeInt),
                                  @"keyword":_keyword
                                  };
    
    [RequestAPI getURL:netUrl withParameters:parameters success:^(id responseObject) {
        if ([responseObject[@"resultFlag"]integerValue] == 8001) {
            //NSLog(@".,.,.>>>>>%@",responseObject);
            NSDictionary *result = responseObject[@"result"];
            weakSelf.dataArray = result[@"models"];
            
            loadOver = YES;
            [weakSelf.tableView reloadData];
        }else{
            [Utilities popUpAlertViewWithMsg:@"请稍后重试" andTitle:@"" onView:self];
             //[self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(NSError *error) {
        [Utilities popUpAlertViewWithMsg:@"请保持网络畅通" andTitle:@"" onView:self];
         //[self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UItableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == _tableView) {
        return _dataArray.count;
    }
    return _cityArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == _tableView) {
        SearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        if (loadOver) {
            cell.nameLabel.text = _dataArray[indexPath.row][@"clubName"];
            cell.addressLabel.text = _dataArray[indexPath.row][@"clubAddressB"];
            cell.distanceLabel.text = [NSString stringWithFormat:@"%@米",_dataArray[indexPath.row][@"distance"]];
            [cell.image sd_setImageWithURL:_dataArray[indexPath.row][@"clubLogo"]];
            return cell;
        }
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CityCell"];
        if (cityLoadOver) {
            cell.textLabel.text = _hotArray[indexPath.row];
        }
        cell.textLabel.text = @"加载中";
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"13");
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == _tableView) {
        return 220;
    }
    return 30;
}

#pragma mark - private

- (IBAction)searchButton:(UIButton *)sender forEvent:(UIEvent *)event {
    _keyword = _searchTextField.text;
    
    [self requestData];
}
- (IBAction)cityButtonAction:(UIButton *)sender forEvent:(UIEvent *)event {
    CityTableViewController *cityView = [Utilities getStoryboard:@"Home" instanceByIdentity:@"CityView"];
    [self.navigationController pushViewController:cityView animated:YES];
    
    cityView.cityBlock = ^(NSString *city, NSNumber *postalCode){
        NSLog(@"%@,%@",city,postalCode);
    };
}

- (IBAction)typeAction:(UIButton *)sender forEvent:(UIEvent *)event {
    if (_typeInt) {
        _typeInt = 0;
        [sender setTitle:@"按距离" forState:UIControlStateNormal];
    }else{
        _typeInt = 1;
        [sender setTitle:@"按人气" forState:UIControlStateNormal];
    }
}

//行数按钮，用于显示用户输入行数
- (IBAction)perPageAction:(UIButton *)sender forEvent:(UIEvent *)event {
    _bgView.hidden = NO;
    _perPageTextField.hidden = NO;
    _choosePerPage.hidden = NO;
    _perPageTextField.text = @"";
    _perPageTextField.alpha = 1;
}
- (IBAction)choosePerPage:(UIButton *)sender forEvent:(UIEvent *)event {
    NSString *perPageStr = _perPageTextField.text;
    //判断其是整数且是空
    if (perPageStr.length != 0 && [self isPureInt:perPageStr]) {
        //赋值给入参
        _perPage = [perPageStr integerValue];
        [_perPageBtn setTitle:perPageStr forState:UIControlStateNormal];
        //重载请求数据
        [self requestData];
    }else{
        [_perPageBtn setTitle:@"默认" forState:UIControlStateNormal];
    }
    _choosePerPage.hidden = YES;
    _perPageTextField.hidden = YES;
    _bgView.hidden = YES;
}

- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}
@end
