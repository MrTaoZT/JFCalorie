//
//  ClubDetailViewController.m
//  Calorie
//
//  Created by Zly on 16/4/17.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "ClubDetailViewController.h"
#import "FirstTableViewCell.h"
#import "SecontTableViewCell.h"
#import "ThiredTableViewCell.h"

#import <UIImageView+WebCache.h>

@interface ClubDetailViewController (){
    BOOL loadOver;
}

@property(nonatomic, strong)NSMutableArray *clubDetailArray;
@property(nonatomic, strong)NSDictionary *clubDict;

@end

@implementation ClubDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    loadOver = NO;
    _clubDict = [NSDictionary new];
    self.title = @"clubDetail";
    [self getClubDetail];
    // Do any additional setup after loading the view.
}

- (void)getClubDetail{
    NSString *netUrl = @"/clubController/getClubDetails";
    
    NSDictionary *paramenters = @{
                                  @"clubKeyId":_clubKeyId,
                                  };
    
    [RequestAPI getURL:netUrl withParameters:paramenters success:^(id responseObject) {
        //NSLog(@"%@",responseObject);
        _clubDict = responseObject[@"result"];
//        NSDictionary *infoDict = @{
//                                   @"clubLogo":dict[@"clubLogo"]
//                                   };
        loadOver = YES;
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}
//property (weak, nonatomic) IBOutlet UIImageView *clubImage;
//@property (weak, nonatomic) IBOutlet UILabel *name;
//@property (weak, nonatomic) IBOutlet UIButton *collection;
//@property (weak, nonatomic) IBOutlet UILabel *address;
//@property (weak, nonatomic) IBOutlet UIButton *call;

//@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
//
//@property (weak, nonatomic) IBOutlet UILabel *openTime;

//@property (weak, nonatomic) IBOutlet UILabel *clubTime;
//@property (weak, nonatomic) IBOutlet UILabel *storeNums;
//@property (weak, nonatomic) IBOutlet UILabel *clubPerson;
//@property (weak, nonatomic) IBOutlet UITextView *clubIntroduce;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:{
            FirstTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell1" forIndexPath:indexPath];
            if (loadOver) {
                [cell.clubImage sd_setImageWithURL:_clubDict[@"clubLogo"] placeholderImage:[UIImage imageNamed:@"hotClubDefaultImage"]];
                cell.name = _clubDict[@"clubName"];
            }
            
            return cell;
           break;
        }
        case 1:{
            SecontTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell2" forIndexPath:indexPath];
            return cell;
            break;
        }
        default:{
            ThiredTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell3" forIndexPath:indexPath];
            return cell;
            break;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            return 256;
            break;
        case 1:
            return 165;
        default:
            return 210;
            break;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
