//
//  SearchViewController.m
//  Calorie
//
//  Created by Z on 16/4/19.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()

@property(nonatomic)NSInteger page;
@property(nonatomic)NSInteger perPage;
@property(nonatomic,strong)NSString *city;
@property(nonatomic)NSInteger typeInt;
@property(nonatomic, strong)NSString *keyword;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _keyword = _searchTextField.text;
    
    [self requestData];
    // Do any additional setup after loading the view.
}

- (void)requestData{
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

- (IBAction)searchButton:(UIButton *)sender forEvent:(UIEvent *)event {
    
}
- (IBAction)cityButtonAction:(UIButton *)sender forEvent:(UIEvent *)event {
    
}

- (IBAction)typeAction:(UIButton *)sender forEvent:(UIEvent *)event {
    
}

- (IBAction)perPageAction:(UIButton *)sender forEvent:(UIEvent *)event {
    
}
@end
