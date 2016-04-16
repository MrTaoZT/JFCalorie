//
//  HotClubTableViewCell.h
//  Calorie
//
//  Created by 杨凡 on 16/4/16.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HotClubTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;//俱乐部名称
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;//地址
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;//距离
@property (weak, nonatomic) IBOutlet UIImageView *clubImageView;//俱乐部图片

@end
