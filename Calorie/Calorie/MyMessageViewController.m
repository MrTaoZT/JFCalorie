//
//  MyMessageViewController.m
//  Calorie
//
//  Created by xyl on 16/4/17.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "MyMessageViewController.h"

@interface MyMessageViewController ()
{
    NSInteger sexy;
}
@property (strong,nonatomic)UIDatePicker *datePicker;

@end

@implementation MyMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    sexy = 1;
    // Do any additional setup after loading the view.
    [self noEdit];
    
    [self huoqu];
    
}


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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//取消用户交互
- (void) noEdit{
    _headImg.userInteractionEnabled = NO;
    _userID.userInteractionEnabled = NO;
    _nickName.userInteractionEnabled = NO;
    _gender.userInteractionEnabled = NO;
    _cardID.userInteractionEnabled = NO;
    _birthday.userInteractionEnabled = NO;
}

//
- (void)huoqu {
    NSString *memberId = _userID.text;
    NSString *name = _nickName.text;
    NSString *cardID = _cardID.text;
    
    
    [_gender addTarget:self action:@selector(changeGender:) forControlEvents:UIControlEventValueChanged];
    
    NSDictionary *dic = @{@"memberId":memberId,
                          @"name":name,
                          @"memberSex":@(sexy),
                          @"identitificationcard":cardID,
                          @"birthday":_birthday
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
    
    
}

- (IBAction)returnAction:(UIBarButtonItem *)sender {
    
    
}

- (IBAction)birthdayAction:(UITextField *)sender forEvent:(UIEvent *)event {
    NSDate *select = [_datePicker date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateAndTime =  [dateFormatter stringFromDate:select];
    _birthday.text = dateAndTime;
}

@end
