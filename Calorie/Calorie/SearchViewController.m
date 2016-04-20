//
//  SearchViewController.m
//  Calorie
//
//  Created by Z on 16/4/19.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchTableViewCell.h"

#import <UIImageView+WebCache.h>

@interface SearchViewController (){
    BOOL loadOver;
}

@property(nonatomic)NSInteger page;
@property(nonatomic)NSInteger perPage;
@property(nonatomic,strong)NSString *city;
@property(nonatomic)NSInteger typeInt;
@property(nonatomic, strong)NSString *keyword;

@property(nonatomic, strong)NSMutableArray *dataArray;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    loadOver = NO;
    
    _dataArray = [NSMutableArray new];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    // Do any additional setup after loading the view.
}

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
    CGFloat jing = _jing;
    CGFloat wei = _wei;
    _page = 1;
    _perPage = 5;
    //默认按距离排序
    _typeInt = 0;
    
    NSDictionary *parameters = @{
                                  @"city":_city,
                                  @"jing":@(jing),
                                  @"wei":@(wei),
                                  @"page":@(_page),
                                  @"perPage":@(_perPage),
                                  @"type":@(_typeInt),
                                  @"keyword":_keyword
                                  };
    
    [RequestAPI getURL:netUrl withParameters:parameters success:^(id responseObject) {
        if ([responseObject[@"resultFlag"]integerValue] == 8001) {
            NSLog(@".,.,.>>>>>%@",responseObject);
            NSDictionary *result = responseObject[@"result"];
            weakSelf.dataArray = result[@"models"];
            
            loadOver = YES;
            [weakSelf.tableView reloadData];
        }else{
            [Utilities popUpAlertViewWithMsg:@"请稍后重试" andTitle:@"" onView:self];
        }
    } failure:^(NSError *error) {
        [Utilities popUpAlertViewWithMsg:@"请保持网络畅通" andTitle:@"" onView:self];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UItableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (loadOver) {
        cell.nameLabel.text = _dataArray[indexPath.row][@"clubName"];
        cell.addressLabel.text = _dataArray[indexPath.row][@"clubAddressB"];
        cell.distanceLabel.text = [NSString stringWithFormat:@"%@米",_dataArray[indexPath.row][@"distance"]];
        [cell.image sd_setImageWithURL:_dataArray[indexPath.row][@"clubLogo"]];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 220;
}

#pragma mark - private

- (IBAction)searchButton:(UIButton *)sender forEvent:(UIEvent *)event {
    _keyword = _searchTextField.text;
    [self requestData];
    NSLog(@"hotClubOver");
}
- (IBAction)cityButtonAction:(UIButton *)sender forEvent:(UIEvent *)event {
    
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

- (IBAction)perPageAction:(UIButton *)sender forEvent:(UIEvent *)event {
    
}
@end
