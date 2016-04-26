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
#import <UIButton+WebCache.h>

#import "ExperienceViewController.h"
@interface ClubDetailViewController (){
    BOOL loadOver;
    NSInteger scrollViewTag;
    NSInteger collectionBtnTag;
    NSInteger callTag;
}

@property(nonatomic, strong)NSMutableArray *clubDetailArray;
@property(nonatomic, strong)NSMutableDictionary *clubDict;
@property(nonatomic)CGFloat offectSet;

//用户id
@property(nonatomic, strong)NSString *memberId;

@end

@implementation ClubDetailViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    UIBarButtonItem *button = [[UIBarButtonItem alloc]initWithTitle:@"体验券" style:UIBarButtonItemStylePlain target:self action:@selector(jumpExperience)];
    self.navigationItem.rightBarButtonItem = button;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //取消tableview下划线
    //    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //去掉tableView的滚动条
    self.tableView.showsVerticalScrollIndicator = NO;
    
    scrollViewTag = 1001;
    collectionBtnTag = 1002;
    callTag = 1003;
    loadOver = NO;
    _offectSet = -64;
    
    _clubDict = [NSMutableDictionary new];
    
    self.navigationItem.title = @"会所详情";
    
    //得到用户ID
    _memberId = [[StorageMgr singletonStorageMgr] objectForKey:@"memberId"];
    
    [self getClubDetail];
    // Do any additional setup after loading the view.
}

- (void)getClubDetail{
    //获得会所详情
    NSString *netUrl = @"/clubController/getClubDetails";
    NSDictionary *paramenters;
    
    //判断用户是否登录
    if ([_memberId isKindOfClass:[NSNull class]] || _memberId == nil || _memberId == NULL) {
        paramenters = @{
                        @"clubKeyId":_clubKeyId,
                        };
    }else{
        paramenters = @{
                        @"clubKeyId":_clubKeyId,
                        @"memberId":_memberId
                        };
    }
    
    //网络请求
    [RequestAPI getURL:netUrl withParameters:paramenters success:^(id responseObject) {
        if ([responseObject[@"resultFlag"] integerValue] == 8001) {
            //NSLog(@"%@",responseObject);
            _clubDict = [NSMutableDictionary dictionaryWithDictionary:responseObject[@"result"]];
            
            loadOver = YES;
            [self.tableView reloadData];
        }else{
            [Utilities popUpAlertViewWithMsg:[NSString stringWithFormat:@"请稍后再试%@",responseObject[@"resultFlag"]] andTitle:@"" onView:self];
        }
    } failure:^(NSError *error) {
        [Utilities popUpAlertViewWithMsg:@"请保持网络畅通" andTitle:@"" onView:self];
    }];
}

//scrollView滚动
- (void)addPic{
    NSArray *clubPic = _clubDict[@"clubPic"];
    CGFloat widthGap = UI_SCREEN_H / 4;
    
    //位置变量
    int orginVariable = 0;
    UIScrollView *scrollView = (UIScrollView *)[self.tableView viewWithTag:scrollViewTag];
    scrollView.contentSize = CGSizeMake(widthGap * clubPic.count + (clubPic.count - 1) * 2, 90);
    scrollView.alwaysBounceHorizontal = YES;
    scrollView.bounces = YES;
    scrollView.userInteractionEnabled = YES;
    
    for (NSDictionary *dict in clubPic) {
        //NSLog(@"%@",dict);
        UIButton *view;
        view = [[UIButton alloc] initWithFrame:CGRectMake(widthGap * orginVariable + 2 * orginVariable, 0, widthGap, scrollView.frame.size.height)];
        view.tag = orginVariable;
        [view addTarget:self action:@selector(imageViewAction:) forControlEvents:UIControlEventTouchUpInside];
        view.imageView.contentMode = UIViewContentModeScaleAspectFill;
        //取消按钮高亮
        view.adjustsImageWhenHighlighted = NO;
        orginVariable ++;
        [view sd_setImageWithURL:dict[@"imgUrl"] forState:UIControlStateNormal];
        [scrollView addSubview:view];
    }
}

- (void)imageViewAction:(UIButton *)sender{
    if (loadOver) {
        //设置初始位置
        UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(0, _offectSet, self.view.frame.size.width, self.view.frame.size.height)];
        image.tag = 100;
        image.backgroundColor = [UIColor blackColor];
        image.contentMode = UIViewContentModeScaleAspectFit;
        image.image = sender.imageView.image;
        image.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closePic:)];
        [image addGestureRecognizer:tap];
        [self.view addSubview:image];
        
        //一个animation
        POPBasicAnimation *zommDowmAnimation = [POPBasicAnimation animation];
        zommDowmAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewScaleXY];
        zommDowmAnimation.duration = 0.25f;
        zommDowmAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.2, 1.2)];
        [image pop_addAnimation:zommDowmAnimation forKey:@"zommDowmAnimation"];
        
        zommDowmAnimation.completionBlock = ^(POPAnimation *animation, BOOL finshed){
            POPBasicAnimation *basicAnimation = [POPBasicAnimation animation];
            basicAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewScaleXY];
            basicAnimation.duration = 0.25f;
            basicAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.0f, 1.0f)];
            [image pop_addAnimation:basicAnimation forKey:@"basicAnimation"];
        };
        
        //当图片出现让tableView不能滚
        self.tableView.scrollEnabled = NO;
        self.navigationController.navigationBar.userInteractionEnabled = NO;
    }
}

- (void)closePic:(UITapGestureRecognizer *)gesture{
    UIImageView *image = [self.tableView viewWithTag:100];
    self.tableView.scrollEnabled = YES;
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    [image removeFromSuperview];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    _offectSet = scrollView.contentOffset.y;
    NSLog(@"%f",_offectSet);
}

- (void)collectionBtn{
    UIButton *button = (UIButton *)[self.tableView viewWithTag:collectionBtnTag];
    [button addTarget:self action:@selector(collectionAction:) forControlEvents:UIControlEventTouchUpInside];
}

//收藏事件
- (void)collectionAction:(UIButton *)sender{
    //收藏接口
    NSString *netUrl = @"/mySelfController/addFavorites";
    if ([_memberId isKindOfClass:[NSNull class]] || _memberId == nil || _memberId == NULL) {
        [Utilities popUpAlertViewWithMsg:@"请先登录" andTitle:@"" onView:self];
        return;
    }
    NSLog(@"memberId %@",_memberId);
    NSString *clubId = _clubDict[@"clubId"];
    //NSLog(@"clubId%@",clubId);
    //获取当前收藏状态
    BOOL type = [_clubDict[@"isFavicons"] boolValue];
    //NSLog(@"type%@",@(type));
    NSDictionary *parameters = @{
                                 @"memberId":_memberId,
                                 @"clubId":clubId,
                                 //反向一下
                                 @"type":@(!type)
                                 };
    
    [RequestAPI getURL:netUrl withParameters:parameters success:^(id responseObject) {
        if ([responseObject[@"resultFlag"] integerValue] == 8001) {
            [_clubDict removeObjectForKey:@"isFavicons"];
            //NSLog(@"%@",_clubDict[@"isFavicons"]);
            NSInteger temp = !type;
            [_clubDict setValue:@(temp) forKey:@"isFavicons"];
            //NSLog(@"...%@",_clubDict[@"isFavicons"]);
            
            if ([_clubDict[@"isFavicons"] boolValue]) {
                [Utilities popUpAlertViewWithMsg:@"收藏成功，您可前往我的收藏查看" andTitle:@"" onView:self];
                [sender setTitle:@"已收藏" forState:UIControlStateNormal];
            }else{
                [Utilities popUpAlertViewWithMsg:@"取消收藏成功" andTitle:@"" onView:self];
                [sender setTitle:@"未收藏" forState:UIControlStateNormal];
            }
        }else{
            [Utilities popUpAlertViewWithMsg:[NSString stringWithFormat:@"请稍后重试%@",responseObject[@"resultFlag"]] andTitle:@"" onView:self];
        }
    } failure:^(NSError *error) {
        [Utilities popUpAlertViewWithMsg:@"请保持网络连接" andTitle:@"" onView:self];
    }];
}

- (void)callAction{
    UIButton *callBtn = (UIButton *)[self.tableView viewWithTag:callTag];
    [callBtn addTarget:self action:@selector(callAction:) forControlEvents:UIControlEventTouchUpInside];
}

//打电话事件
- (void)callAction:(UIButton *)sender{
    //获得电话
    NSString *phoneTemp = _clubDict[@"clubTel"];
    NSArray *phoneAllArray = [phoneTemp componentsSeparatedByString:@","];
    if (phoneAllArray.count > 1) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"选择您要拨打的会所电话" preferredStyle:UIAlertControllerStyleAlert];
        //有几个电话弹窗有几个选项
        for (int i = 0; i < phoneAllArray.count; i++) {
            if(![phoneAllArray[i] isEqualToString:@"  "]){
                UIAlertAction *action = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@",phoneAllArray[i]] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",phoneAllArray[i]]];
                    [[UIApplication sharedApplication] openURL:url];
                    NSLog(@"phoneAllArray%@",phoneAllArray[i]);
                }];
                [alert addAction:action];
            }
        }
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",phoneAllArray[0]]];
        [[UIApplication sharedApplication] openURL:url];
    }
    //NSLog(@"%@",phoneAllArray);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (loadOver) {
        switch (indexPath.row) {
            case 0:{
                FirstTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell1" forIndexPath:indexPath];
                //俱乐部图片
                [cell.clubImage sd_setImageWithURL:_clubDict[@"clubLogo"] placeholderImage:[UIImage imageNamed:@"hotClubDefaultImage"]];
                //俱乐部名字
                cell.name.text = [NSString stringWithFormat:@"%@",_clubDict[@"clubName"]];
                
                cell.name.userInteractionEnabled = YES;
                
                //收藏情况
                cell.collection.tag = collectionBtnTag;
                [self collectionBtn];
                //NSLog(@"-->%d",[_clubDict[@"isFavicons"] boolValue]);
                if ([_clubDict[@"isFavicons"] boolValue]) {
                    [cell.collection setTitle:@"已收藏" forState:UIControlStateNormal];
                }else{
                    [cell.collection setTitle:@"未收藏" forState:UIControlStateNormal];
                }
                //地址
                cell.address.text = _clubDict[@"clubAddressB"];
                cell.address.adjustsFontSizeToFitWidth = YES;
                //电话
                cell.call.tag = callTag;
                [self callAction];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return cell;
                break;
            }
            case 1:{
                SecontTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell2" forIndexPath:indexPath];
                
                //滚动视图
                cell.scrollView.tag = scrollViewTag;
                [self addPic];
                //营业时间（UI搞反了）
                cell.openTime.text = _clubDict[@"clubTime"];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
                break;
            }
            default:{
                ThiredTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell3" forIndexPath:indexPath];
                
                cell.clubTime.text = [NSString stringWithFormat:@"开业时间：%@",_clubDict[@"openTime"]];
                cell.storeNums.text = [NSString stringWithFormat:@"拥有分店数量：%@",_clubDict[@"storeNums"]] ;
                cell.clubPerson.text = [NSString stringWithFormat:@"教练数量：%@",_clubDict[@"clubPerson"]];
                cell.clubIntroduce.text = _clubDict[@"clubIntroduce"];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
                break;
            }
        }
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell1"];
        return cell;
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

- (void)jumpExperience{
    ExperienceViewController *experienceVc = [Utilities getStoryboard:@"Home" instanceByIdentity:@"experienceVc"];
    NSArray *experienceInfo = _clubDict[@"experienceInfos"];
    NSDictionary *experienceInfoDict = experienceInfo.firstObject;
    NSString *eId = experienceInfoDict[@"eId"];
    if (eId) {
        experienceVc.experienceInfos = eId;
        [self.navigationController pushViewController:experienceVc animated:YES];
    }else{
        [Utilities popUpAlertViewWithMsg:@"体验券已被抢完哦，下次乘早吧亲!" andTitle:@"" onView:self];
    }
}
@end
