//
//  CityTableViewController.m
//  Calorie
//
//  Created by 杨凡 on 16/4/20.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "CityTableViewController.h"

@interface CityTableViewController (){
    BOOL cityLoadOver;
}

@property(nonatomic, strong)NSMutableDictionary *citys;
@property(nonatomic, strong)NSMutableArray *keys;

//接收数据
@property(nonatomic, strong)NSArray *cityArray;

@property(nonatomic, strong)NSArray *hotArray;
@property(nonatomic, strong)NSArray *upgradedArray;

@property(nonatomic, strong)NSMutableArray *infoHotArray;
@property(nonatomic, strong)NSMutableArray *infoUpgradedArray;

@end

@implementation CityTableViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //取消tableview下划线
    //    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //去掉tableView的滚动条
    self.tableView.showsVerticalScrollIndicator = NO;
    
    cityLoadOver = NO;
    
    _hotArray = [NSArray new];
    _upgradedArray = [NSArray new];
    _infoHotArray = [NSMutableArray new];
    _infoUpgradedArray = [NSMutableArray new];
    
    self.navigationItem.title = @"选择城市";
    
    [self dataPreparation];
    
    [self getCity];
}

//获得数据
- (void)getCity{
    __weak CityTableViewController *weakSelf = self;
    
    NSString *netUrl = @"/city/hotAndUpgradedList";
    
    [RequestAPI getURL:netUrl withParameters:nil success:^(id responseObject) {
        //NSLog(@"responseObject..%@",responseObject);
        if ([responseObject[@"resultFlag"] integerValue] == 8001) {
            NSDictionary *result = responseObject[@"result"];
            weakSelf.hotArray = result[@"hot"];
            weakSelf.upgradedArray = result[@"upgraded"];
            //
            [self lastDataPreparation];
            cityLoadOver = YES;
            [weakSelf.tableView reloadData];
        }else{
            [Utilities popUpAlertViewWithMsg:@"请稍后重试" andTitle:@"" onView:self];
        }
    } failure:^(NSError *error) {
        [Utilities popUpAlertViewWithMsg:@"请保持网络畅通" andTitle:@"" onView:self];
    }];
}

//筛选出接口的数据
- (void)lastDataPreparation{
    for (int key = 0; key < _keys.count; key ++) {
        NSArray *array = _citys[_keys[key]];
        for (int i = 0; i < array.count; i++) {
            NSString *postal = array[i][@"id"];
            //循环_hotArray
            for (int j = 0; j < _hotArray.count; j++) {
                if (postal == _hotArray[j]) {
                    NSDictionary *dict = @{
                                           @"name":array[i][@"name"],
                                           @"id":array[i][@"id"]
                                           };
                    [_infoHotArray addObject:dict];
                }
            }
            //循环_upgradedArray
            for (int n = 0; n < _upgradedArray.count; n++) {
                if (postal == _upgradedArray[n]) {
                    NSDictionary *dict = @{
                                           @"name":array[i][@"name"],
                                           @"id":array[i][@"id"]
                                           };
                    [_infoUpgradedArray addObject:dict];
                }
            }
        }
    }
    _cityArray = [[NSArray alloc]initWithObjects:_infoHotArray, _infoUpgradedArray, nil];
}

//获得全国区号对应的城市
-(void)dataPreparation{
    _citys = [NSMutableDictionary new];
    _keys = [NSMutableArray new];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString * path = [[NSBundle mainBundle]pathForResource:@"citydict" ofType:@"plist"];
    if ([fm fileExistsAtPath:path]) {
        NSDictionary *resultDict = [NSDictionary dictionaryWithContentsOfFile:path];
        if (resultDict) {
            _citys = [NSMutableDictionary dictionaryWithDictionary:resultDict];
            //获取citysh中的所有键
            NSArray *unsortKey = [_citys allKeys];
            //升序排列
            NSArray *sortedKey = [unsortKey sortedArrayUsingSelector:@selector(compare:)];
            //_key是排好序的键(A-Z)
            _keys = [NSMutableArray arrayWithArray:sortedKey];
        }
    }
    //NSLog(@"citys = %@,keys = %ld",_citys,_keys.count);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//返回组数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _cityArray.count;
}

//返回行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSArray *array = _cityArray[section];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CityViewCell" forIndexPath:indexPath];
    
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.textColor = [UIColor brownColor];
    
    if (cityLoadOver) {
        cell.textLabel.text = _cityArray[indexPath.section][indexPath.row][@"name"];
    }
    
    
    return cell;
}

//返回每一组的组头的标题
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return @"hot";
    }else{
        return @"upgraded";
    }
}

//
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20.f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //    NSString *key = _keys[indexPath.section];
    //    NSArray *tempArray = _cityArray[indexPath.section];
    //    NSDictionary *dataDict = tempArray[indexPath.row];
    //
    NSString *city = _cityArray[indexPath.section][indexPath.row][@"name"];
    NSString *postalCode = _cityArray[indexPath.section][indexPath.row][@"id"];
    _cityBlock(city, postalCode);
    [self.navigationController popViewControllerAnimated:YES];
}

//返回每列名字
//-(NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
//    //    return _keys;
//    NSArray *array = @[@"hot",@"upgraded"];
//    return array;
//}

@end
