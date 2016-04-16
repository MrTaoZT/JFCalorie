//
//  HomeTableViewController.m
//  Calorie
//
//  Created by 杨凡 on 16/4/16.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "HomeTableViewController.h"
#import "TitleTableViewCell.h"
#import "HotClubTableViewCell.h"

@interface HomeTableViewController (){
    BOOL sportOver;
}

@property(nonatomic, strong)NSMutableArray *sportTypeArray;

@end

@implementation HomeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //取消tableview下划线
//    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self initailAllControl];
    
    //网络请求拿去运动类型
    [self getSportType];
    
    
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
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        TitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"titleCell" forIndexPath:indexPath];
        if (sportOver) {
            [cell.sportTypeBtn1 setTitle:_sportTypeArray[indexPath.row][@"name"] forState:UIControlStateNormal];
            [cell.sportTypeBtn2 setTitle:_sportTypeArray[indexPath.row][@"name"] forState:UIControlStateNormal];
            [cell.sportTypeBtn3 setTitle:_sportTypeArray[indexPath.row][@"name"] forState:UIControlStateNormal];
            [cell.sportTypeBtn4 setTitle:_sportTypeArray[indexPath.row][@"name"] forState:UIControlStateNormal];
            [cell.sportTypeBtn5 setTitle:_sportTypeArray[indexPath.row][@"name"] forState:UIControlStateNormal];
            [cell.sportTypeBtn6 setTitle:_sportTypeArray[indexPath.row][@"name"] forState:UIControlStateNormal];
            [cell.sportTypeBtn7 setTitle:_sportTypeArray[indexPath.row][@"name"] forState:UIControlStateNormal];
            [cell.sportTypeBtn8 setTitle:_sportTypeArray[indexPath.row][@"name"] forState:UIControlStateNormal];
            sportOver = NO;
        }
        return cell;
    }else{
        HotClubTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"clubCell" forIndexPath:indexPath];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 203;
    }
    return 150;
}

#pragma mark - private

- (void)initailAllControl{
    sportOver = NO;
    _sportTypeArray = [NSMutableArray new];
}

#pragma mark - privateNet

- (void)getSportType{
    
    __weak HomeTableViewController *weakSelf = self;
    
    NSString *netUrl = @"/homepage/category";
    NSInteger page = 1;
    NSInteger perPage = 10;
    
    NSDictionary *parameters = @{
                                 @"page":@(page),
                                 @"perPage":@(perPage)
                                 };
    
    [RequestAPI getURL:netUrl withParameters:parameters success:^(id responseObject) {
        if ([responseObject[@"resultFlag"] integerValue] == 8001) {
            NSDictionary *result = responseObject[@"result"];
            _sportTypeArray = result[@"models"];
            NSLog(@"%@",_sportTypeArray);
            sportOver = YES;
            [weakSelf.tableView reloadData];
        }else{
            [Utilities popUpAlertViewWithMsg:@"请保持网络畅通,稍后试试吧" andTitle:@"" onView:self];
        }
    } failure:^(NSError *error) {
        [Utilities popUpAlertViewWithMsg:@"请保持网络畅通" andTitle:@"" onView:self];
    }];
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
