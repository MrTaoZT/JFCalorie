//
//  SecondExperienceTableViewCell.h
//  Calorie
//
//  Created by Z on 16/4/22.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondExperienceTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *orginPrice;
@property (weak, nonatomic) IBOutlet UILabel *currentPrice;
@property (weak, nonatomic) IBOutlet UILabel *saleCount;
@property (weak, nonatomic) IBOutlet UILabel *endDate;
@property (weak, nonatomic) IBOutlet UILabel *useDate;
@property (weak, nonatomic) IBOutlet UILabel *beginDate;
@property (weak, nonatomic) IBOutlet UITextView *relus;


@end
