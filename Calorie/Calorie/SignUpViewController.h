//
//  SignUpViewController.h
//  Calorie
//
//  Created by xyl on 16/4/17.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *titleImgIV;
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UITextField *codeTF;

- (IBAction)codeAction:(UIButton *)sender forEvent:(UIEvent *)event;
@property (weak, nonatomic) IBOutlet UITextField *firstPwTF;
@property (weak, nonatomic) IBOutlet UITextField *secondPwTF;
- (IBAction)signUpAction:(UIButton *)sender forEvent:(UIEvent *)event;


@end
