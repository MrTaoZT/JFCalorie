//
//  ExperienceViewController.m
//  Calorie
//
//  Created by xyl on 16/4/22.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "ExperienceViewController.h"

@interface ExperienceViewController ()

@end

@implementation ExperienceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showExperience];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)showExperience{
    NSDictionary *dic = @{@"experienceId":_experienceInfos,};
    
    [RequestAPI getURL:@"/clubController/experienceDetail" withParameters:dic success:^(id responseObject) {
        NSLog(@"obj = %@",responseObject);
    } failure:^(NSError *error) {
        NSLog(@"error = %@", [error userInfo]);
    }];
}
@end
