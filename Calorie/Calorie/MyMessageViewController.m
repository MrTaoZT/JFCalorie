//
//  MyMessageViewController.m
//  Calorie
//
//  Created by xyl on 16/4/17.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "MyMessageViewController.h"
#import "TabBarViewController.h"
#import "LeftViewController.h"
#import "HomeNavViewController.h"

@interface MyMessageViewController ()
{
    NSInteger sexy;
    NSInteger count;
    NSString *memberSex;
    NSString *birthday;
    NSString *identificationcard;
}
@property (strong,nonatomic)UIDatePicker *datePicker;
@property (strong,nonatomic) ECSlidingViewController *slidingVc;
@end

@implementation MyMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    count = 1;
    
    [self getMessage];
}

- (void)getMessage{
    _headImg.userInteractionEnabled = NO;
    _userID.userInteractionEnabled = NO;
    _nickName.userInteractionEnabled = NO;
    _gender.userInteractionEnabled = NO;
    _cardID.userInteractionEnabled = NO;
    _birthday.userInteractionEnabled = NO;
    
    NSDictionary *dic = [[StorageMgr singletonStorageMgr]objectForKey:@"dict"];
    if (![dic[@"memberSex"] isEqual: [NSNull null]]) {
        NSLog(@"dic %@",[dic objectForKey:@"memberSex"]);
        memberSex = dic[@"memberSex"];
        sexy = [memberSex integerValue];
    }else{
        sexy = 1;
    }
    if (![dic[@"birthday"] isEqual: [NSNull null]]) {
        birthday = dic[@"birthday"];
    }else{
        birthday = @"1";
    }
    if (![dic[@"identificationcard"] isEqual: [NSNull null]]) {
        identificationcard = dic[@"identificationcard"];
    }else{
        identificationcard = @"2";
    }
    NSLog(@"id = %@",dic[@"memberId"]);
    NSLog(@"name = %@",dic[@"memberName"]);
    _nickName.text = [Utilities getUserDefaults:@"Username"];
    _userID.text = [NSString stringWithFormat:@"%@",dic[@"memberId"]];
    _birthday.text = birthday;
    _cardID.text = identificationcard;
    
}

//NSDictionary *dict = @{@"memberId":result[@"memberId"],
//                       @"memberSex":result[@"memberSex"],
//                       @"memberName":result[@"memberName"],
//                       @"birthday":result[@"birthday"],
//                       @"identificationcard":result[@"identificationcard"]
//                       };
//@property (weak, nonatomic) IBOutlet UIImageView *headImg;//头像
//@property (weak, nonatomic) IBOutlet UILabel *userID;//用户ID
//@property (weak, nonatomic) IBOutlet UITextField *nickName;//昵称
//@property (weak, nonatomic) IBOutlet UISegmentedControl *gender;//性别
//@property (weak, nonatomic) IBOutlet UITextField *cardID;//身份证
//@property (weak, nonatomic) IBOutlet UITextField *birthday;//生日


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//
- (void)saveMessage {
    NSString *memberId = _userID.text;
    NSString *name = _nickName.text;
    
    [_gender addTarget:self action:@selector(changeGender:) forControlEvents:UIControlEventValueChanged];
    
    NSDictionary *dic = @{@"memberId":memberId,
                          @"name":name,
                          @"memberSex":@(sexy),
                          @"identitificationcard":identificationcard,
                          @"birthday":birthday
                          };
    [RequestAPI postURL:@"/mySelfController/updateMyselfInfos" withParameters:dic success:^(id responseObject) {
        
    } failure:^(NSError *error) {
        
    }];
}


- (void)changeGender:(UISegmentedControl *)sender {
    
    if (sender.selectedSegmentIndex == 0){
        sexy = 1;
        
    } else {
        sexy = 2;
    }
}


- (IBAction)rightAction:(UIBarButtonItem *)sender {
    if (count%2 != 0 ) {
        [_rightButton setTitle:@"保存"];
        count ++;
        
        _headImg.userInteractionEnabled = YES;
        _nickName.userInteractionEnabled = YES;
        _gender.userInteractionEnabled = YES;
        _cardID.userInteractionEnabled = YES;
        _birthday.userInteractionEnabled = YES;
        
    }else {
        [_rightButton setTitle:@"编辑"];
        count ++;
        
        identificationcard = _cardID.text;
        birthday = _birthday.text;
        
        if ((_nickName.text.length == 0 || _nickName.text.length > 11)) {
            [Utilities popUpAlertViewWithMsg:@"用户名不能为空，并且需要小于11为" andTitle:nil onView:self];
        }
        if (identificationcard.length != 0 || identificationcard.length != 18) {
            [Utilities popUpAlertViewWithMsg:@"请输入正确的身份证号" andTitle:nil onView:self];
        }
        [self saveMessage];
    }
}

- (IBAction)returnAction:(UIBarButtonItem *)sender {
    
    if ([_rightButton.title isEqualToString:@"保存"]) {
        [_rightButton setTitle:@"编辑"];
        count ++;
        return;
    }
    //这里跳转到首页
    LeftViewController * leftVc = [Utilities getStoryboard:@"Home" instanceByIdentity:@"LeftVc"];
    TabBarViewController * tabView = [Utilities getStoryboard:@"Home" instanceByIdentity:@"TabView"];
    //----------------------侧滑开始 center----------------------
    //初始化侧滑框架,并且设置中间显示的页面
    _slidingVc = [ECSlidingViewController slidingWithTopViewController:tabView];
    //设置侧滑 的  耗时
    _slidingVc.defaultTransitionDuration = 0.25f;
    //设置 控制侧滑的手势   (这里同时对触摸 和 拖拽相应)
    _slidingVc.topViewAnchoredGesture = ECSlidingViewControllerAnchoredGesturePanning | ECSlidingViewControllerAnchoredGestureTapping;
    //设置上述手势的识别范围
    [tabView.view addGestureRecognizer:_slidingVc.panGesture];
    //----------------------侧滑开始 left----------------------
    _slidingVc.underLeftViewController = leftVc;
    //设置侧滑的开闭程度   (peek都是设置中间的页面出现的宽度 )
    _slidingVc.anchorRightPeekAmount = UI_SCREEN_W / 4;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(menuSwitchAction) name:@"MenuSwitch" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(EnableGestureAction) name:@"EnableGesture" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DisableGestureAction) name:@"DisableGesture" object:nil];
    
    HomeNavViewController *homeNav = [[HomeNavViewController alloc]initWithRootViewController:_slidingVc];
    _slidingVc.navigationController.navigationBar.hidden = YES;
    
    [self presentViewController:homeNav animated:YES completion:nil];
}

- (void) menuSwitchAction{
    NSLog(@"menu1");
    //如果中间那扇门在在右侧，说明  已经被侧滑  因此需要关闭
    if (_slidingVc.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredRight) {
        //中间  页面向左滑
        [_slidingVc resetTopViewAnimated:YES];
    }else {
        //中间  页面向右滑
        [_slidingVc anchorTopViewToRightAnimated:YES];
    }
}
//激活 侧滑手势
- (void)EnableGestureAction{
    _slidingVc.panGesture.enabled = YES;
    NSLog(@"1");
}
//关闭 侧滑手势
- (void)DisableGestureAction{
    _slidingVc.panGesture.enabled = NO;
    NSLog(@"2");
}

- (IBAction)birthdayAction:(UITextField *)sender forEvent:(UIEvent *)event {
    NSDate *select = [_datePicker date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateAndTime =  [dateFormatter stringFromDate:select];
    _birthday.text = dateAndTime;
}

@end
