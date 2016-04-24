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
    BOOL loadingOver;
}

@property(nonatomic)NSInteger clubPage;
@property(nonatomic)NSInteger totalPage;
@property(nonatomic, strong)NSMutableArray *clubArray;

@end

@implementation SportTypeTableViewController

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
    
    requestOver = NO;
    loadingOver = NO;
    
    _clubArray = [NSMutableArray new];
    
    self.title = _sportName;
    
    //NSLog(@"id%@",_sportType);
    _totalPage = 1;
    _clubPage = 1;
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
        [self loadDataEnd];
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
                NSString *clubId = info[i][@"clubId"];
                
                NSDictionary *dict = @{
                                       @"clubName":name,
                                       @"clubAddressB":address,
                                       @"distance":distance,
                                       @"clubLogo":image,
                                       @"clubId":clubId
                                       };
                [weakSelf.clubArray addObject:dict];
            }
            requestOver = YES;
            loadingOver = YES;
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
        //NSLog(@"clubKeyId%@",clubKeyId);
        clubDetailView.clubKeyId = clubKeyId;
        [self.navigationController pushViewController:clubDetailView animated:YES];
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
}

-(void)loadDataing{
    //判断是否还存在下一页
    if (_totalPage > _clubPage) {
        if (loadingOver) {
            //之前如果是yes说明正常进入了网络请求，页数加一，把加载成功改为NO
            _clubPage ++;
            loadingOver = NO;
            [self getSportClub];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 256;
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
