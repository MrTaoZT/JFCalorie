//
//  ExperienceViewController.m
//  Calorie
//
//  Created by xyl on 16/4/22.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "ExperienceViewController.h"
#import "FirstExperienceTableViewCell.h"
#import "SecondExperienceTableViewCell.h"
#import <UIImageView+WebCache.h>
@interface ExperienceViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong,nonatomic)NSMutableDictionary *objectForShow;
@end

@implementation ExperienceViewController



- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
     [self.TableView setScrollEnabled:NO];
    //取消tableview下划线
    //    self.tableView.tableFooterView = [[UIView alloc]init];
    self.TableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //去掉tableView的滚动条
    self.TableView.showsVerticalScrollIndicator = NO;
    
    //[[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    
    _TableView.delegate = self;
    _TableView.dataSource = self ;
    
    _objectForShow = [NSMutableDictionary new];
    [self showExperience];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)showExperience{
    [_objectForShow removeAllObjects];
    NSDictionary *dic = @{@"experienceId":_experienceInfos,};
    
    [RequestAPI getURL:@"/clubController/experienceDetail" withParameters:dic success:^(id responseObject) {
        NSLog(@"obj = %@",responseObject);
        _objectForShow = [NSMutableDictionary dictionaryWithDictionary:responseObject[@"result"]];
        [_TableView reloadData];
    } failure:^(NSError *error) {
        NSLog(@"error = %@", [error userInfo]);
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section  {
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    switch (indexPath.row) {
        case 0:{
            FirstExperienceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell1" forIndexPath:indexPath];
            [ cell.eLogoImageView sd_setImageWithURL:_objectForShow[@"eLogo"] placeholderImage:[UIImage imageNamed:@"hotClubDefaultImage"]];
            cell.eName.text = [NSString stringWithFormat:@"%@",_objectForShow[@"eName"]];
            cell.eClubName.adjustsFontSizeToFitWidth = YES;
            cell.eClubName.text = [NSString stringWithFormat:@"%@",_objectForShow[@"eClubName"]];
            cell.eAddress.text = [NSString stringWithFormat:@"%@",_objectForShow[@"eAddress"]];
            //取消边框线
            //            [cell setBackgroundView:[[UIView alloc] init]];
            //            cell.backgroundColor = [UIColor clearColor];
            return cell;
            break;
        }
            
        default:{
            SecondExperienceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell2" forIndexPath:indexPath];
            
            cell.orginPrice.text = [NSString stringWithFormat:@"原价:%@",_objectForShow[@"orginPrice"]];
            cell.currentPrice.text =[NSString stringWithFormat:@"现价:%@",_objectForShow[@"currentPrice"]];
            cell.saleCount.text = [NSString stringWithFormat:@"销售数量:%@",_objectForShow[@"saleCount"]];
            cell.endDate.text = [NSString stringWithFormat:@"有效期结束时间:%@",_objectForShow[@"endDate"]];
            cell.endDate.adjustsFontSizeToFitWidth = YES;
            cell.useDate.text = [NSString stringWithFormat:@"可用时间段:%@",_objectForShow[@"useDate"]];
            cell.beginDate.text = [NSString stringWithFormat:@"有效期开始时间:%@",_objectForShow[@"beginDate"]];
            cell.beginDate.adjustsFontSizeToFitWidth = YES;
            cell.relus.text = [NSString stringWithFormat:@"使用规则:%@",_objectForShow[@"rules"]];
            //取消选中颜色
            UIView *cellClickVc = [[UIView alloc]initWithFrame:cell.frame];
            cell.selectedBackgroundView = cellClickVc;
            cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
            cell.userInteractionEnabled = NO;
            //            //取消边框线
            //            [cell setBackgroundView:[[UIView alloc] init]];
            //            cell.backgroundColor = [UIColor clearColor];
            return cell;
            break;
        }
            
            
            
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            return 256;
            break;
        default:
            return 330;
            break;
    }
}

//- (IBAction)clubTel:(UIButton *)sender forEvent:(UIEvent *)event {
//    NSLog(@"zaicidianji");
//    NSArray *phone  =[_objectForShow[@"clubTel"] componentsSeparatedByString:@","];
//    if (phone.count == 0) {
//        
//    }
//    if (phone.count > 1) {
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"选择您要拨打的会所电话" preferredStyle:UIAlertControllerStyleAlert];
//        //有几个电话弹窗有几个选项
//        for (int i = 0; i < phone.count; i++) {
//            UIAlertAction *action = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@",phone[i]] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",phone[i]]];
//                [[UIApplication sharedApplication] openURL:url];
//                
//            }];
//            [alert addAction:action];
//        }
//        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//            
//        }];
//        [alert addAction:cancel];
//        [self presentViewController:alert animated:YES completion:nil];
//        
//    }else{
//        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",phone]];
//        [[UIApplication sharedApplication]openURL:url];
//        
//    }
//    
//    
//}
@end
