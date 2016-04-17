//
//  SportTypeTableViewController.m
//  Calorie
//
//  Created by Zly on 16/4/17.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "SportTypeTableViewController.h"
#import "SportTypeTableViewCell.h"
#import "ClubDetailViewController.h"

#import <UIImageView+WebCache.h>

@interface SportTypeTableViewController (){
    BOOL requestOver;
}

@property(nonatomic, strong)NSMutableArray *clubArray;

@end

@implementation SportTypeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    requestOver = NO;
    
    _clubArray = [NSMutableArray new];
    
    NSLog(@"id%@",_sportType);
    
    //获得当前类型id的会所
    [self getSportClub];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _clubArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SportTypeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    if (requestOver) {
        NSDictionary *dict = _clubArray[indexPath.row];
        NSLog(@"dict%@",dict[@"clubAddressB"]);
        cell.nameLabel.text = dict[@"clubName"];
        cell.addressLabel.text = dict[@"clubAddressB"];
        cell.distanceLabel.text = [NSString stringWithFormat:@"%@米",dict[@"distance"]];

        [cell.clubImageView sd_setImageWithURL:dict[@"clubLogo"]];
    }
    
    return cell;
}

#pragma mark - privateFun

-(void)getSportClub{
    
    __weak SportTypeTableViewController *weakSelf = self;
    
    //根据条件，获取会所列表
    NSString *netUrl = @"/clubController/nearSearchClub";
    //默认
    NSString *city = @"0510";
    NSInteger page = 1;
    NSInteger perPage = 10;
    NSInteger type = 0;
    NSString *featureId = _sportType;
    
    NSDictionary *parameters = @{
                                 @"city":city,
                                 @"jing":@(_setJing),
                                 @"wei":@(_setWei),
                                 @"page":@(page),
                                 @"perPage":@(perPage),
                                 @"type":@(type),
                                 @"featureId":featureId
                                 };
    [RequestAPI getURL:netUrl withParameters:parameters success:^(id responseObject) {
        if ([responseObject[@"resultFlag"] integerValue] == 8001) {
            //NSLog(@"-->%@",responseObject);
            NSDictionary *dict = responseObject[@"result"];
            weakSelf.clubArray = dict[@"models"];
            requestOver = YES;
            [weakSelf.tableView reloadData];
        }else{
            [Utilities popUpAlertViewWithMsg:@"请保持网络畅通，稍后试试" andTitle:@"" onView:self];
        }
    } failure:^(NSError *error) {
        [Utilities popUpAlertViewWithMsg:@"请保持网络畅通" andTitle:@"" onView:self];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ClubDetailViewController *clubDetailView = [Utilities getStoryboard:@"Home" instanceByIdentity:@"ClubDetailView"];
    
    [self.navigationController pushViewController:clubDetailView animated:YES];
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
