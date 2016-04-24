//
//  ShopTableViewController.m
//  Calorie
//
//  Created by Zly on 16/4/23.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "ShopTableViewController.h"
#import "ShopTableViewCell.h"

#import <UIImageView+WebCache.h>

@interface ShopTableViewController (){
    BOOL loadingOver;
}

@property(nonatomic, strong)NSMutableArray *goodsArray;
@property(nonatomic)NSInteger coin;

@end

@implementation ShopTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    loadingOver = NO;
    self.tableView.userInteractionEnabled = NO;
    
    [self getCoin];
    [self requestData];
}

//获得积分
- (void)getCoin{
    NSString *netUrl = @"/score/memberScore";
    NSString *userId = [[StorageMgr singletonStorageMgr] objectForKey:@"memberId"];
    if (userId) {
        [RequestAPI getURL:netUrl withParameters:@{@"memberId":userId} success:^(id responseObject) {
            NSLog(@"%@",responseObject);
            if ([responseObject[@"resultFlag"] integerValue] == 8001) {
                _coin = [responseObject[@"result"] integerValue];
                self.tableView.userInteractionEnabled = YES;
                self.navigationItem.title = [NSString stringWithFormat:@"当前积分为:%@",responseObject[@"result"]];
            }else{
                self.navigationItem.title = @"未登录";
                [Utilities popUpAlertViewWithMsg:@"请保持网络畅通,稍后试试" andTitle:@"" onView:self];
            }
        } failure:^(NSError *error) {
            self.navigationItem.title = @"未登录";
            [Utilities popUpAlertViewWithMsg:@"请保持网络畅通" andTitle:@"" onView:self];
        }];
    }
    
}

//获得商品列表
- (void)requestData{
    NSString *netUrl = @"/goods/list";
    NSDictionary *parameters = @{
                                 @"type":@(2),
                                 @"page":@(1),
                                 @"perPage":@(100)
                                 };
    [RequestAPI getURL:netUrl withParameters:parameters success:^(id responseObject) {
        if ([responseObject[@"resultFlag"] integerValue] == 8001) {
            NSDictionary *result = responseObject[@"result"];
            _goodsArray = result[@"models"];
            loadingOver = YES;
            self.tableView.userInteractionEnabled = YES;
            [self.tableView reloadData];
        }else{
            [Utilities popUpAlertViewWithMsg:@"请保持网络畅通,稍后试试" andTitle:@"" onView:self];
        }
    } failure:^(NSError *error) {
        [Utilities popUpAlertViewWithMsg:@"请保持网络畅通" andTitle:@"" onView:self];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _goodsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShopTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    if (loadingOver) {
        NSDictionary *dict = _goodsArray[indexPath.row];
        [cell.shopImage sd_setImageWithURL:dict[@"goodsImg"]];
        cell.goodsName.text = dict[@"goodsName"];
        cell.goodsAmount.text = [NSString stringWithFormat:@"商品数量%@",dict[@"goodsAmount"]];
        cell.goodsScore.text = [NSString stringWithFormat:@"所需积分%@",dict[@"goodsScore"]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([[StorageMgr singletonStorageMgr] objectForKey:@"memberId"]) {
        NSDictionary *dict = _goodsArray[indexPath.row];
        NSString *name = dict[@"goodsName"];
        NSString *score = dict[@"goodsScore"];
        if (_coin > [score integerValue]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"兑换提示" message:[NSString stringWithFormat:@"您当前正在兑换%@\n+将消耗您%@积分+\n确定兑换吗?",name,score] preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //确认兑换
                [self confirmShop:dict];
            }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:action];
            [alert addAction:cancel];
            [self presentViewController:alert animated:YES completion:nil];
        }else{
            [Utilities popUpAlertViewWithMsg:@"您的积分不够哦" andTitle:@"" onView:self];
        }
    }else{
        [Utilities popUpAlertViewWithMsg:@"您没有登录,先去登录吧" andTitle:@"" onView:self];
    }
}

//购买的网络请求
- (void)confirmShop:(NSDictionary *)dict{
    NSString *netUrl = @"/goods/exchangeGoods";
    NSString *userId = [[StorageMgr singletonStorageMgr] objectForKey:@"memberId"];
    NSString *goodsId = dict[@"goodsId"];
    
    NSDictionary *parameters = @{
                                 @"memberId":userId,
                                 @"goodsId":goodsId
                                 };
    [RequestAPI getURL:netUrl withParameters:parameters success:^(id responseObject) {
        if ([responseObject[@"resultFlag"] integerValue] == 8001) {
            NSLog(@"%@",responseObject);
        }else{
            [Utilities errorShow:responseObject[@"resultFlag"] onView:self];
        }
    } failure:^(NSError *error) {
        [Utilities popUpAlertViewWithMsg:@"请保持网络畅通" andTitle:@"" onView:self];
        NSLog(@"Error%@",error.userInfo);
    }];
}

@end
