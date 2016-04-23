//
//  ShopTableViewCell.h
//  Calorie
//
//  Created by Z on 16/4/23.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *shopImage;
@property (weak, nonatomic) IBOutlet UILabel *goodsName;
@property (weak, nonatomic) IBOutlet UILabel *goodsAmount;
@property (weak, nonatomic) IBOutlet UILabel *goodsScore;
@end
