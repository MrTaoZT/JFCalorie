//
//  ShopTableViewCell.m
//  Calorie
//
//  Created by Z on 16/4/23.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "ShopTableViewCell.h"

@implementation ShopTableViewCell

- (void)awakeFromNib {
    // Initialization code
    _goodsName.adjustsFontSizeToFitWidth = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
