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

@end

@implementation ShopTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    loadingOver = NO;
    
    [self getCoin];
    [self requestData];
}

- (void)getCoin{
    NSString *netUrl = @"/score/memberScore";
    NSString *userId = [[StorageMgr singletonStorageMgr] objectForKey:@"memberId"];
    if (userId) {
        [RequestAPI getURL:netUrl withParameters:@{@"memberId":userId} success:^(id responseObject) {
            NSLog(@"%@",responseObject);
            if ([responseObject[@"resultFlag"] integerValue] == 8001) {
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
