//
//  Utilities.m
//  Utility
//
//  Created by ZIYAO YANG on 15/8/20.
//  Copyright (c) 2015年 Zhong Rui. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

+ (id)getUserDefaults:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+ (void)setUserDefaults:(NSString *)key content:(id)value
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)removeUserDefaults:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)uniqueVendor
{
    NSString *uniqueIdentifier = [Utilities getUserDefaults:@"kKeyVendor"];
    if (!uniqueIdentifier || uniqueIdentifier.length == 0) {
        NSUUID *uuid = [[UIDevice currentDevice] identifierForVendor];
        uniqueIdentifier = [uuid UUIDString];
        [Utilities setUserDefaults:@"kKeyVendor" content:uniqueIdentifier];
    }
    return uniqueIdentifier;
}

+ (id)getStoryboard:(NSString *)storyboard instanceByIdentity:(NSString *)identity;
{
    UIStoryboard* sd = [UIStoryboard storyboardWithName:storyboard bundle:[NSBundle mainBundle]];
    return [sd instantiateViewControllerWithIdentifier:identity];
}

+ (void)popUpAlertViewWithMsg:(NSString *)msg andTitle:(NSString* )title onView:(UIViewController *)vc
{
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:title == nil ? @"提示" : title message:msg == nil ? @"操作失败" : msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:nil];
    [alertView addAction:cancelAction];
    [vc presentViewController:alertView animated:YES completion:nil];
}

+ (UIActivityIndicatorView *)getCoverOnView:(UIView *)view
{
    UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    aiv.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.4];
    aiv.frame = view.bounds;
    [view addSubview:aiv];
    [aiv startAnimating];
    return aiv;
}

+ (NSString *)notRounding:(float)price afterPoint:(int)position
{
    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *ouncesDecimal;
    NSDecimalNumber *roundedOunces;
    
    ouncesDecimal = [[NSDecimalNumber alloc] initWithFloat:price];
    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    return [NSString stringWithFormat:@"%@",roundedOunces];
}

+ (UIImage *)imageUrl:(NSString *)url {
    if ([url isKindOfClass:[NSNull class]] || url == nil) {
        return nil;
    }
    static dispatch_queue_t backgroundQueue;
    if (backgroundQueue == nil) {
        backgroundQueue = dispatch_queue_create("com.beilyton.queue", NULL);
    }
    
    NSArray *directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [directories objectAtIndex:0];
    __block NSString *filePath = nil;
    filePath = [documentDirectory stringByAppendingPathComponent:[url lastPathComponent]];
    UIImage *imageInFile = [UIImage imageWithContentsOfFile:filePath];
    if (imageInFile) {
        return imageInFile;
    }
    
    __block NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    if (!data) {
        NSLog(@"Error retrieving %@", url);
        return nil;
    }
    UIImage *imageDownloaded = [[UIImage alloc] initWithData:data];
    dispatch_async(backgroundQueue, ^(void) {
        [data writeToFile:filePath atomically:YES];
        //NSLog(@"Wrote to: %@", filePath);
    });
    return imageDownloaded;
}

+ (void) errorShow:(NSString *)resultFlag onView:(UIViewController *)vc{
    switch ([resultFlag integerValue]) {
        case 8011:
            [Utilities popUpAlertViewWithMsg:@"验证码错误" andTitle:nil onView:vc];
            break;
        case 8013:
            [Utilities popUpAlertViewWithMsg:@"请保持网络畅通" andTitle:nil onView:vc];
            break;
        case 8015:
            [Utilities popUpAlertViewWithMsg:@"注册码获取超出次数,请明天再获取" andTitle:nil onView:vc];
            break;
        case 8016:
            [Utilities popUpAlertViewWithMsg:@"该号已注册" andTitle:nil onView:vc];
            break;
        case 8017:
            [Utilities popUpAlertViewWithMsg:@"该号码不存在，请先注册" andTitle:nil onView:vc];
            break;
        case 8022:
            [Utilities popUpAlertViewWithMsg:@"该会员卡不存在" andTitle:nil onView:vc];
            break;
        case 8025:
            [Utilities popUpAlertViewWithMsg:@"暂无优惠券" andTitle:nil onView:vc];
            break;
        case 8028:
            [Utilities popUpAlertViewWithMsg:@"该号码不存在" andTitle:nil onView:vc];
            break;
        case 8029:
            [Utilities popUpAlertViewWithMsg:@"密码错误" andTitle:nil onView:vc];
            break;
        case 8030:
            [Utilities popUpAlertViewWithMsg:@"该手机未获得验证码" andTitle:nil onView:vc];
            break;
        default:
            [Utilities popUpAlertViewWithMsg:@"服务器暂忙，请稍后再试" andTitle:nil onView:vc];
            break;
    }
}
@end
