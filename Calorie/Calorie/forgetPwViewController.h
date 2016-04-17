//
//  forgetPwViewController.h
//  Calorie
//
//  Created by xyl on 16/4/17.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface forgetPwViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *firstPwTF;
@property (weak, nonatomic) IBOutlet UITextField *secondPwTF;

- (IBAction)setPwAction:(UIButton *)sender forEvent:(UIEvent *)event;

@end
