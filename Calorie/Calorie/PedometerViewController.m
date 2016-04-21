//
//  PedometerViewController.m
//  Calorie
//
//  Created by 杨凡 on 16/4/21.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "PedometerViewController.h"
#import "CircularView.h"
#import <HealthKit/HealthKit.h>
#import "ARLabel.h"

@interface PedometerViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    
    NSDate *date;
    
    NSInteger walk;
    NSInteger avgwwalk;
}
@property (strong,nonatomic) NSMutableArray *objectForShow;
@property (strong,nonatomic) HKHealthStore *healthStore;
@property (strong,nonatomic) UITableView *tableView;
@property (strong,nonatomic) ARLabel *walklale;
@property (strong,nonatomic)ARLabel *avgWalkLab;
@end

@implementation PedometerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _objectForShow = [NSMutableArray new];
    [self interfaceView];
    self.tableView.tableFooterView = [[UIView alloc]init];
    //设置tableView不能滚动
    //    [self.tableView setScrollEnabled:NO];
    //下拉刷新
    UIRefreshControl *rc = [[UIRefreshControl alloc]init];
    _tableView.tableFooterView = [[UIView alloc]init];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    rc.tag = 1001;
    rc.tintColor = [UIColor orangeColor];
    [rc addTarget:self action:@selector(getpermission) forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:rc];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self getpermission];
    
}
-(void)interfaceView{
    //进度条的背景
    CircularView *circularView = [[CircularView alloc]initWithFrame:CGRectMake(50, 70, self.view.frame.size.width -100, self.view.frame.size.height/2)];
    circularView.backgroundColor = [UIColor clearColor];
    //    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:circularView action:@selector(detailHerlth)];
    //  [tap setNumberOfTapsRequired:1];
    //  [tap setNumberOfTouchesRequired:1];
    [self.view addSubview:circularView];
    
    
    //设置lable截止时间
    date = [NSDate date];
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"HH:mm"];
    NSString *formatDate = [dateformatter stringFromDate:date];
    CGRect lableFram = CGRectMake(circularView.frame.size.width/2 - 50, circularView.frame.size.height/4, 100, 30);
    ARLabel *lable =[[ARLabel alloc]initWithFrame:lableFram];
    [lable setText:[NSString stringWithFormat:@"截止%@已走",formatDate]];
    lable.textColor = [UIColor lightGrayColor];
    lable.font = [UIFont systemFontOfSize:12];
    [circularView addSubview:lable];
    
    //设置lable步数
    
    
    CGRect lableFram2 = CGRectMake(circularView.frame.size.width/2 - 75, circularView.frame.size.height/2 - 75, 150, 150);
    _walklale =[[ARLabel alloc]initWithFrame:lableFram2];
    _walklale.textAlignment = UITextAlignmentCenter;
    _walklale.textColor = [UIColor blueColor];
    _walklale.font = [UIFont systemFontOfSize:15];
    [circularView addSubview:_walklale];
    
    
    
    CGRect lableFrame3 = CGRectMake(circularView.frame.size.width/2 - 60, circularView.frame.size.height /2 ,120, 150);
    _avgWalkLab =[[ARLabel alloc]initWithFrame:lableFrame3];
    _avgWalkLab.text = @"每天多走一步，成功一大步";
    _avgWalkLab.textColor = [UIColor lightGrayColor];
    _avgWalkLab.font = [UIFont systemFontOfSize:12];
    [circularView addSubview:_avgWalkLab];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height/2 +40, self.view.frame.size.width, self.view.frame.size.height/2 - 40 ) style:UITableViewStylePlain];
    //     _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor colorWithWhite:0.05f alpha:0.01f];
    _tableView.delegate = self;
    _tableView.dataSource =self;
    [self.view addSubview:_tableView];
    
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
        
        if (success)
        {
            NSLog(@"获取步数权限成功");
            //获取步数后我们调用获取步数的方法
            [self readStepCount];
            [self saveStepCount];
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
    
    //查询样本信息
    HKSampleType *sampleType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    //NSSortDescriptors用来告诉healthStore怎么样将结果排序。(开始和结束)
    NSSortDescriptor *start = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    NSSortDescriptor *end = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    /*查询的基类是HKQuery，这是一个抽象类，能够实现每一种查询目标，这里我们需要查询的步数是一个
     HKSample类所以对应的查询类就是HKSampleQuery。
     下面的limit参数传1表示查询最近一条数据,查询多条数据只要设置limit的参数值就可以了
     */
    HKSampleQuery *sampleQuery = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:nil limit:0 sortDescriptors:@[start,end] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        //打印查询结果
        NSLog(@"resultCount = %ld result = %@",results.count,results);
        
        if (!error) {
            if (results.count > 0) {
                
                
                //把结果装换成字符串类型
                HKQuantitySample *result = results[0];
                HKQuantity *quantity = result.quantity;
                
                double value = [quantity doubleValueForUnit:[HKUnit countUnit]];
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    _walklale.text = [NSString stringWithFormat:@" %d",(int)value ];
                    
                    //查询是在多线程中进行的，如果要对UI进行刷新，要回到主线程中
                    NSLog(@"最新步数：%f",value);
                    
                    
                }];
                
            }
        }
    }];
    //执行查询
    [self.healthStore executeQuery:sampleQuery];
}

// 设置本地通知
- (void)registerLocalNotification:(NSInteger)alertTime {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    // 设置触发通知的时间
    NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:alertTime];
    NSLog(@"fireDate=%@",fireDate);
    
    notification.fireDate = fireDate;
    // 时区
    notification.timeZone = [NSTimeZone defaultTimeZone];
    // 设置重复的间隔
    notification.repeatInterval = kCFCalendarUnitSecond;
    
    // 通知内容
    notification.alertBody =  @"您有新的消息请查收";
    notification.applicationIconBadgeNumber = 1;
    // 通知被触发时播放的声音
    notification.soundName = UILocalNotificationDefaultSoundName;
    // 通知参数
    NSDictionary *userDict = [NSDictionary dictionaryWithObject:@"您好" forKey:@"key"];
    notification.userInfo = userDict;
    
    // ios8后，需要添加这个注册，才能得到授权
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType type =  UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        // 通知重复提示的单位，可以是天、周、月
        notification.repeatInterval = NSCalendarUnitDay;
    } else {
        // 通知重复提示的单位，可以是天、周、月
        notification.repeatInterval = NSDayCalendarUnit;
    }
    
    // 执行通知注册
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}
// 本地通知回调函数，当应用程序在前台时调用
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"noti:%@",notification);
    
    // 这里真实需要处理交互的地方
    // 获取通知所带的数据
    NSString *notMess = [notification.userInfo objectForKey:@"key"];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"本地通知"message:notMess delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil];
    [alert show];
    
    // 更新显示的徽章个数
    NSInteger badge = [UIApplication sharedApplication].applicationIconBadgeNumber;
    badge--;
    badge = badge >= 0 ? badge : 0;
    [UIApplication sharedApplication].applicationIconBadgeNumber = badge;
    
    // 在不需要再推送时，可以取消推送
    [PedometerViewController cancelLocalNotificationWithKey:@"key"];
}
// 取消某个本地推送通知
+ (void)cancelLocalNotificationWithKey:(NSString *)key {
    // 获取所有本地通知数组
    NSArray *localNotifications = [UIApplication sharedApplication].scheduledLocalNotifications;
    
    for (UILocalNotification *notification in localNotifications) {
        NSDictionary *userInfo = notification.userInfo;
        if (userInfo) {
            // 根据设置通知参数时指定的key来获取通知参数
            NSString *info = userInfo[key];
            
            // 如果找到需要取消的通知，则取消
            if (info != nil) {
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
                break;
            }
        }
    }
}
-(void)saveStepCount{
    //
    //     HKHealthStore *healthStore = [[HKHealthStore alloc]init];
    [_objectForShow removeAllObjects];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *interval = [[NSDateComponents alloc]init];
    interval.day = 7;
    //设置一个计算的时间点
    NSDateComponents *anchorComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth |NSCalendarUnitYear | NSCalendarUnitWeekday  fromDate:[NSDate date]];
    NSInteger offset = (7 + anchorComponents.weekday )%7;
    anchorComponents.day -= offset;
    //设置从几点开始计时
    anchorComponents.hour = 23;
    [self registerLocalNotification:23];
    interval.day = 1;
    NSDate *anchorDate = [calendar dateFromComponents:anchorComponents];
    
    HKQuantityType *qiantityType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    //创建查询   intervalcomponents:按照多少时间间隔查询
    HKStatisticsCollectionQuery *query = [[HKStatisticsCollectionQuery alloc]initWithQuantityType:qiantityType quantitySamplePredicate:nil options:HKStatisticsOptionCumulativeSum anchorDate:anchorDate intervalComponents:interval];
    
    
    //查询结果
    query.initialResultsHandler = ^(HKStatisticsCollectionQuery *query,HKStatisticsCollection *results,NSError *error){
        if (error) {
            NSLog(@"error = %@",error.description);
        }else{
            
            NSDate *endDate = [NSDate date];
            
            /*value 这个参数很重要  －7：表示从今天开始逐步查询后面7天的步数
             NSCalendarUnitDay  表示按照什么类型输出
             */
            NSDate *startDate = [calendar dateByAddingUnit:NSCalendarUnitWeekday value:-7 toDate:endDate options:0];
            
            [results enumerateStatisticsFromDate:startDate toDate:endDate withBlock:^(HKStatistics * _Nonnull result, BOOL * _Nonnull stop) {
                HKQuantity *quantity = result.sumQuantity;
                UIRefreshControl *rc = (UIRefreshControl *)[_tableView viewWithTag:1001];
                [rc endRefreshing];
                if (quantity) {
                    NSDate *date = result.startDate;
                    
                    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
                    //设置时区
                    [outputFormatter setLocale:[NSLocale currentLocale]];
                    [outputFormatter setDateFormat:@"MM月dd日"];
                    NSString *str = [outputFormatter stringFromDate:date];
                    
                    double value = [quantity doubleValueForUnit:[HKUnit countUnit]];
                    NSLog(@"____________>>>>时间：= %@, 步行： = %f\n",str,value);
                    NSString *string  = [NSString stringWithFormat:@" 时间：%@               ",str];
                    NSString *string2 = [NSString stringWithFormat:@"步行：%d",(int)value];
                    NSArray *arr = [NSArray arrayWithObjects:string,string2, nil];
                    NSLog(@"------+++----->>>>%@",string);
                    [_objectForShow addObjectsFromArray:arr];
                    NSLog(@"------------>>>>%@",_objectForShow);
                    [_tableView reloadData];
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
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section  {
    return _objectForShow.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    
    // 定义变量保存重用标记的值
    static NSString *test = @"test";
    //    用TableSampleIdentifier表示需要重用的单元
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:test];
    cell .backgroundColor  = [UIColor colorWithWhite:0.05f alpha:0.01f];
    
    //    如果如果没有多余单元，则需要创建新的单元
    if  (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:test];
    }
    
    else {
        while ([cell.contentView.subviews lastObject ]!=nil) {
            [(UIView*)[cell.contentView.subviews lastObject]removeFromSuperview];
        }
    }
    cell.textLabel.text = _objectForShow[indexPath.row];
    NSLog(@"************>>>>>%@",_objectForShow);
    //取消选中颜色
    UIView *cellClickVc = [[UIView alloc]initWithFrame:cell.frame];
    cell.selectedBackgroundView = cellClickVc;
    cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    //取消边框线
    [cell setBackgroundView:[[UIView alloc] init]];
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}
//单击一个cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if(cell.tag == 0){
        
        //注销cell单击事件
        cell.selected = NO;
    }else {
        //取消选中项
        [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
