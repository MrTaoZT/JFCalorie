//
//  CityTableViewController.h
//  Calorie
//
//  Created by 杨凡 on 16/4/20.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CityTableViewController : UITableViewController

@property(nonatomic, strong) void (^cityBlock)(NSString *city, NSString *postalCode);

@end
