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
    
    NSString *netUrl = @"/goods/list";
    NSDictionary *parameters = @{
                                 @"type":@(2),
                                 @"page":@(1),
                                 @"perPage":@(100)
                                 };
    [RequestAPI getURL:netUrl withParameters:parameters success:^(id responseObject) {
        NSDictionary *result = responseObject[@"result"];
        _goodsArray = result[@"models"];
        loadingOver = YES;
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        
    }];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
