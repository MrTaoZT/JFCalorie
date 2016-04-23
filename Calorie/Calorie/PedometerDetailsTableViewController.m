//
//  PedometerDetailsTableViewController.m
//  Calorie
//
//  Created by Z on 16/4/22.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "PedometerDetailsTableViewController.h"
#import <HealthKit/HealthKit.h>
#import "PedometerViewController.h"

@interface PedometerDetailsTableViewController ()
@property (strong,nonatomic) NSMutableArray *objectForShow;

@property (strong,nonatomic) HKHealthStore *healthStore;
@end

@implementation PedometerDetailsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _objectForShow = [NSMutableArray new];
    self.tableView.delegate = self;
    self.tableView.dataSource =self;
    
    UIRefreshControl *rc = [[UIRefreshControl alloc]init];
    self.tableView.tableFooterView = [[UIView alloc]init];
    rc.tag = 1001;
    rc.tintColor = [UIColor orangeColor];
    [rc addTarget:self action:@selector(getpermission) forControlEvents:UIControlEventValueChanged];
    //    PedometerViewController.flag = _flag;
    
    [self getpermission];
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
    return _objectForShow.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (_objectForShow) {
        cell.textLabel.text = _objectForShow[indexPath.row];
        NSLog(@"************>>>>>%@",_objectForShow);
    }
   
    return cell;
}

-(void)getpermission{
    //查看healthKit在设备上是否可用，ipad不支持HealthKit
    /*
     调用 isHealthDataAvailable 方法来查看HealthKit在该设备上是否可用。HealthKit在iPad上不可用。
     */
    if(![HKHealthStore isHealthDataAvailable])
    {
        NSLog(@"设备不支持healthKit");
    }
    
    //创建healthStore实例对象
    self.healthStore = [[HKHealthStore alloc] init];
    
    //设置需要获取的权限这里仅设置了步数
    HKObjectType *stepCount = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    NSSet *healthSet = [NSSet setWithObjects:stepCount, nil];
    
    //从健康应用中获取权限
    [self.healthStore requestAuthorizationToShareTypes:nil readTypes:healthSet completion:^(BOOL success, NSError * _Nullable error) {
        UIRefreshControl *rc = (UIRefreshControl *)[self.tableView viewWithTag:1001];
        [rc endRefreshing];
        if (success)
        {
            NSLog(@"获取步数权限成功");
            //获取步数后我们调用获取步数的方法
            
            self.navigationItem.title = @"详细步数";
            [self readStepCount];
            
        }
        else
        {
            NSLog(@"获取步数权限失败");
        }
    }];
    
}
//查询数据
- (void)readStepCount
{
    
    //    //查询样本信息
    //    HKSampleType *sampleType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    //
    //    //设置24小时
    //    NSTimeInterval stardate = 24*60*60;
    //    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:stardate];
    //    NSDateComponents *interval = [[NSDateComponents alloc]init];
    //    interval.minute = 1;
    //    NSDate *endDate = [NSDate date];
    [_objectForShow removeAllObjects];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *interval = [[NSDateComponents alloc]init];
    interval.minute = 1;
    //设置一个计算的时间点
    NSDateComponents *anchorComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth fromDate:[NSDate date]];
    NSInteger offset =  anchorComponents.minute ;
    anchorComponents.minute -= offset;
    
    
    NSDate *anchorDate = [calendar dateFromComponents:anchorComponents];
    
    HKQuantityType *qiantityType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    //创建查询   intervalcomponents:按照多少时间间隔查询
    HKStatisticsCollectionQuery *query = [[HKStatisticsCollectionQuery alloc]initWithQuantityType:qiantityType quantitySamplePredicate:nil options:HKStatisticsOptionCumulativeSum anchorDate:anchorDate intervalComponents:interval];
    
    
    //查询结果
    query.initialResultsHandler = ^(HKStatisticsCollectionQuery *query,HKStatisticsCollection *results,NSError *error){
        UIRefreshControl *rc = (UIRefreshControl *)[self.tableView viewWithTag:1001];
        [rc endRefreshing];
        if (error) {
            NSLog(@"error = %@",error.description);
        }else{
            
            NSDate *endDate = [NSDate date];
            
            
            NSDate *startDate = [calendar dateByAddingUnit:NSCalendarUnitWeekday value:-1 toDate:endDate options:0];
            
            [results enumerateStatisticsFromDate:startDate toDate:endDate withBlock:^(HKStatistics * _Nonnull result, BOOL * _Nonnull stop) {
                HKQuantity *quantity = result.sumQuantity;
                
                if (quantity) {
                    NSDate *date = result.startDate;
                    
                    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
                    //设置时区
                    [outputFormatter setLocale:[NSLocale currentLocale]];
                    [outputFormatter setDateFormat:@"MM月dd日 HH:mm"];
                    NSString *str = [outputFormatter stringFromDate:date];
                    
                    double value = [quantity doubleValueForUnit:[HKUnit countUnit]];
                    NSLog(@"_____{{{{{{}}_______>>>>时间：= %@, 步行： = %f\n",str,value);
                    NSString *string  = [NSString stringWithFormat:@" 时间：%@                 步行：%d",str,(int)value];
                    NSLog(@"------+++----->>>>%@",string);
                    [_objectForShow addObject:string];
                    [self.tableView reloadData];
                    NSLog(@"------------>>>>%@",_objectForShow);
                    // [_tableView reloadData];
                    //            dispatch_async(dispatch_get_main_queue(), ^{
                    //
                    //                NSLog(@"------------>>>>%@",arr);
                    //            });
                }
            }];
        }
    };
    
    [_healthStore executeQuery:query];
    
    
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
