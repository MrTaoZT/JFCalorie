//
//  SportTypeTableViewController.h
//  Calorie
//
//  Created by Zly on 16/4/17.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SportTypeTableViewController : UITableViewController

@property(nonatomic, strong)NSString *sportName;
@property(nonatomic, strong)NSString *sportType;
@property(nonatomic, strong)NSString *city;

@property(nonatomic)CGFloat setJing;
@property(nonatomic)CGFloat setWei;

@end
