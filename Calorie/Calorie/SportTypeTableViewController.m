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

@property(nonatomic)NSInteger clubPage;
@property(nonatomic)NSInteger totalPage;
@property(nonatomic, strong)NSMutableArray *clubArray;

@end

@implementation SportTypeTableViewController

- (void)viewDidAppear:(BOOL)animated{
    _clubPage = 1;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    requestOver = NO;
    
    _clubArray = [NSMutableArray new];
    
    self.title = _sportName;
    
    //NSLog(@"id%@",_sportType);
    _totalPage = 0;
    
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
        //NSLog(@"dict%@",dict[@"clubAddressB"]);
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
    NSString *city = _city;
    NSInteger perPage = 10;
    NSInteger type = 0;
    NSString *featureId = _sportType;
    
    NSDictionary *parameters = @{
                                 @"city":city,
                                 @"jing":@(_setJing),
                                 @"wei":@(_setWei),
                                 @"page":@(_clubPage),
                                 @"perPage":@(perPage),
                                 @"type":@(type),
                                 @"featureId":featureId
                                 };
    
    [RequestAPI getURL:netUrl withParameters:parameters success:^(id responseObject) {
        if ([responseObject[@"resultFlag"] integerValue] == 8001) {
            //NSLog(@"-->%@",responseObject);
            if (weakSelf.clubPage == 1) {
                weakSelf.clubArray = nil;
                weakSelf.clubArray = [NSMutableArray new];
            }
            NSDictionary *dict = responseObject[@"result"];
            NSArray *info = dict[@"models"];
            NSDictionary *pageinfo = dict[@"pagingInfo"];
            weakSelf.totalPage =  [pageinfo[@"totalPage"] integerValue];
            //NSLog(@"total%ld",_totalPage);
            //封装数据
            for (int i = 0; i < info.count; i++) {
                NSString *name = info[i][@"clubName"];
                NSString *address = info[i][@"clubAddressB"];
                NSString *distance = info[i][@"distance"];
                NSString *image = info[i][@"clubLogo"];
                
                NSDictionary *dict = @{
                                       @"clubName":name,
                                       @"clubAddressB":address,
                                       @"distance":distance,
                                       @"clubLogo":image,
                                       };
                [weakSelf.clubArray addObject:dict];
            }
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
    if (requestOver) {
        NSString *clubKeyId = _clubArray[indexPath.row][@"clubId"];
        //NSLog(@"%@",clubKeyId);
        clubDetailView.clubKeyId = clubKeyId;
        [self.navigationController pushViewController:clubDetailView animated:YES];
    }
}

#pragma mark - UIScrollViewDelegate

//滚动(上拉刷新)
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (scrollView.contentSize.height + 64 > scrollView.frame.size.height ) {
        if(scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height + 74){
            if (_totalPage > _clubPage) {
                ++_clubPage;
                [self getSportClub];
            }else{
                NSLog(@"没有更多数据");
            }
        }
    }else{
        if (scrollView.contentOffset.y > -74) {
            if (_totalPage < _clubPage) {
                ++_clubPage;
                [self getSportClub];
            }else{
                NSLog(@"没有更多数据");
            }
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
