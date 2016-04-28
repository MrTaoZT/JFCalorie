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

@interface MyMessageViewController ()<UITextFieldDelegate>
{
    NSInteger sexy;
    NSInteger count;
    NSString *memberSex;
    NSString *birthday;
    NSString *identificationcard;
}
@property (strong,nonatomic)UIDatePicker *datePicker;
@property (strong,nonatomic) ECSlidingViewController *slidingVc;
@property (strong,nonatomic) NSDictionary *dict;
@end

@implementation MyMessageViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getMessage];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [_gender addTarget:self action:@selector(changeGender:) forControlEvents:UIControlEventTouchUpInside];
    
    _birthday.delegate = self;
    
    count = 1;
    
    _datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, (self.view.frame.size.height - self.view.frame.size.height / 3), self.view.frame.size.width, self.view.frame.size.height / 3)];
    _datePicker.datePickerMode = UIDatePickerModeDate;
    [_datePicker setLocale:[NSLocale localeWithLocaleIdentifier:@"zh-CN"]];
    _datePicker.backgroundColor = [UIColor greenColor];

    _datePicker.hidden = YES;
    [self.view addSubview:_datePicker];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        if(sexy == 1){
            _gender.selectedSegmentIndex = 0;
        }else {
            _gender.selectedSegmentIndex = 1;
        }
    }else{
        _gender.selectedSegmentIndex = 1;
    }
    if (![dic[@"birthday"] isEqual: [NSNull null]]) {
        birthday = dic[@"birthday"];
    }else{
        birthday = @"";
    }
    if (![dic[@"identificationcard"] isEqual: [NSNull null]]) {
        identificationcard = dic[@"identificationcard"];
    }else{
        identificationcard = @"";
    }

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

//
- (void)saveMessage {
    NSString *memberId = _userID.text;
    NSString *name = _nickName.text;
    
    NSDate *date = [NSDate date];
    NSDateFormatter *df = [[NSDateFormatter alloc]init];//格式化
    [df setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [df stringFromDate:date];
    
    NSLog(@"dateStr = %@",dateStr);
    NSLog(@"sexy = %ld",sexy);
    NSLog(@"memberId = %@",memberId);
    NSLog(@"name111 = %@",name);
    NSLog(@"identitificationcard = %@",identificationcard);
    
    _dict = @{@"memberId":memberId,
                          @"name":name,
                          @"memberSex":@(sexy),
                          @"identitificationcard":identificationcard,
                          @"birthday":dateStr
                          };
    [RequestAPI postURL:@"/mySelfController/updateMyselfInfos" withParameters:_dict success:^(id responseObject){
        if ([responseObject[@"resultFlag"] integerValue] == 8001) {
            [Utilities popUpAlertViewWithMsg:@"保存成功" andTitle:nil onView:self];
            
            [[StorageMgr singletonStorageMgr]removeObjectForKey:@"dict"];
            [[StorageMgr singletonStorageMgr]addKey:@"dict" andValue:_dict];
        }else {
            [Utilities errorShow:responseObject[@"resultFlag"] onView:self];
            [self getMessage];
        }
    } failure:^(NSError *error) {
        NSLog(@"error = %@",error.description);
        [Utilities popUpAlertViewWithMsg:@"请保持网络通畅" andTitle:nil onView:self];
        [self getMessage];
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
        identificationcard = _cardID.text;
        birthday = _birthday.text;
        
        if ((_nickName.text.length == 0 || _nickName.text.length > 11)) {
            [Utilities popUpAlertViewWithMsg:@"用户名不能为空，并且需要小于11为" andTitle:nil onView:self];
            _nickName.text = @"";
            return;
        }
        if (identificationcard.length == 0 || identificationcard.length == 18) {
            
        }else{
            [Utilities popUpAlertViewWithMsg:@"请输入正确的身份证号" andTitle:nil onView:self];
            _cardID.text = @"";
            return;
        }
        [self saveMessage];
        
        [_rightButton setTitle:@"编辑"];
        count ++;
        
        _headImg.userInteractionEnabled = NO;
        _userID.userInteractionEnabled = NO;
        _nickName.userInteractionEnabled = NO;
        _gender.userInteractionEnabled = NO;
        _cardID.userInteractionEnabled = NO;
        _birthday.userInteractionEnabled = NO;
    }
}

- (IBAction)returnAction:(UIBarButtonItem *)sender {
    
    if ([_rightButton.title isEqualToString:@"保存"]) {
        [_rightButton setTitle:@"编辑"];
        
        _headImg.userInteractionEnabled = NO;
        _userID.userInteractionEnabled = NO;
        _nickName.userInteractionEnabled = NO;
        _gender.userInteractionEnabled = NO;
        _cardID.userInteractionEnabled = NO;
        _birthday.userInteractionEnabled = NO;
        
        [self getMessage];
        
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

#pragma mark- Textfield

- (void)textFieldDidBeginEditing:(UITextField *)textField

{
//    CGRectMake(0, (self.view.frame.size.height - self.view.frame.size.height / 3), self.view.frame.size.width, self.view.frame.size.height / 3)];
    _datePicker.hidden = NO;
    
    NSLog(@"textFieldDidBeginEditing");
    
    CGRect frame = _datePicker.frame;
    
    CGFloat heights = self.view.frame.size.height;
    
    // 当前点击textfield的坐标的Y值 + 当前点击textFiled的高度 - （屏幕高度- 键盘高度 - 键盘上tabbar高度）
    
    // 在这一部 就是了一个 当前textfile的的最大Y值 和 键盘的最全高度的差值，用来计算整个view的偏移量
    
    int offset = frame.origin.y + 42- ( heights - (self.view.frame.size.height / 3) - 35.0);//键盘高度216
    
    NSTimeInterval animationDuration = 0.30f;
    
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    
    [UIView setAnimationDuration:animationDuration];
    
    float width = self.view.frame.size.width;
    
    float height = self.view.frame.size.height;
    
    if(offset > 0)
        
    {
        
        CGRect rect = CGRectMake(0.0f, -offset,width,height);
        
        self.view.frame = rect;
        
    }
    
    [UIView commitAnimations];
    
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan");
    
//    [self.view endEditing:YES];
    
    _datePicker.hidden = YES;
    
    NSTimeInterval animationDuration = 0.30f;
    
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    
    [UIView setAnimationDuration:animationDuration];
    
    CGRect rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

//当文本输入框中输入的内容变化是调用该方法，返回值为NO不允许调用
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return YES;
}
@end
