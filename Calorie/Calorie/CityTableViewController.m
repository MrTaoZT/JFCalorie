//
//  CityTableViewController.m
//  Calorie
//
//  Created by 杨凡 on 16/4/20.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "CityTableViewController.h"

@interface CityTableViewController ()

@property(nonatomic, strong)NSMutableDictionary *citys;
@property(nonatomic, strong)NSMutableArray *keys;

@end

@implementation CityTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"选择城市";
    
    [self dataPreparation];
}

-(void)dataPreparation{
    _citys = [NSMutableDictionary new];
    _keys = [NSMutableArray new];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString * path = [[NSBundle mainBundle]pathForResource:@"citydict" ofType:@"plist"];
    if ([fm fileExistsAtPath:path]) {
        NSDictionary *resultDict = [NSDictionary dictionaryWithContentsOfFile:path];
        if (resultDict) {
            _citys = [NSMutableDictionary dictionaryWithDictionary:resultDict];
            //获取citysh中的所有键
            NSArray *unsortKey = [_citys allKeys];
            //升序排列
            NSArray *sortedKey = [unsortKey sortedArrayUsingSelector:@selector(compare:)];
            //_key是排好序的键(A-Z)
            _keys = [NSMutableArray arrayWithArray:sortedKey];
        }
    }
    //NSLog(@"citys = %@,keys = %ld",_citys,_keys.count);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _keys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //获得当前正在渲染的组的名称
    NSString *keys = _keys[section];
    //根据上述组名，将它作为键去citys字典中查询对应的值，也就是A-Z的其中一个数组
    NSArray *cityArr = _citys[keys];
    //
    return cityArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CityViewCell" forIndexPath:indexPath];
    
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.textColor = [UIColor brownColor];
    
    //获得当前正在渲染的组的名称
    NSString *keys = _keys[indexPath.section];
    //根据上述组名，将它作为键去citys字典中查询对应的值，也就是A-Z的其中一个数组
    NSArray *cityArr = _citys[keys];
    //根据当前正在渲染的行号，从上述组城市列表中获得对应的城市字典
    NSDictionary *cityDict = cityArr[indexPath.row];
    //从城市字典中拿到name键对应的值-城市名称
    NSString * cityName = cityDict[@"name"];
    cell.textLabel.text = cityName;
    
    return cell;
}

//返回每一组的组头的标题
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return _keys[section];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20.f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *key = _keys[indexPath.section];
    NSArray *tempArray = [NSArray arrayWithArray:_citys[key]];
    NSDictionary *dataDict = tempArray[indexPath.row];
    
    NSString *city = dataDict[@"name"];
    NSNumber *postalCode = dataDict[@"id"];
//    NSLog(@"%@",dataDict[@"id"]);
    _cityBlock(city, postalCode);
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return _keys;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
