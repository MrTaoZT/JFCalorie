//
//  CircularView.m
//  Calorie
//
//  Created by zt on 16/4/22.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "CircularView.h"
#import <QuartzCore/QuartzCore.h>
#define RYUIColorWithRGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
@implementation CircularView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self gradentWith:frame];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
        
    }
    return self;
}

- (void)gradentWith:(CGRect)frame{
    //设置贝塞尔曲线
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2) radius:(frame.size.width-PROGRESS_LINE_WIDTH)/2-5 startAngle:degressToRadius(-240) endAngle:degressToRadius(60) clockwise:YES];
    //根据原来的frame 进行进度渐变
    CGRect inset = CGRectInset(self.bounds, 30, 30);
    CGRect inster = CGRectIntegral(inset);
    CGRect rir2 = CGRectUnion(inset, self.bounds);
    
    
    //    NSLog(@"------frame1 = %@",NSStringFromCGRect(self.bounds));
    //    NSLog(@"------frame2 = %@",NSStringFromCGRect(inset));
    //    NSLog(@"------frame3 = %@",NSStringFromCGRect(inster));
    //    NSLog(@"------frame4 = %@",NSStringFromCGRect(rir2));
    CAReplicatorLayer * replica = [CAReplicatorLayer layer];
    replica.frame = inset;
    replica.backgroundColor = [UIColor magentaColor].CGColor;
    UIBezierPath * path2 = [UIBezierPath bezierPathWithOvalInRect:replica.frame];
    path2.lineWidth = 5.0f;
    path2.lineCapStyle = kCGLineCapRound;
    
    //遮罩层
    
    _progressLayer = [CAShapeLayer layer];
    
    _progressLayer.frame = self.bounds ;
    
    _progressLayer.fillColor =  [[UIColor clearColor] CGColor];
    
    _progressLayer.strokeColor=[UIColor redColor].CGColor;
    
    _progressLayer.lineCap = kCALineCapRound;
    
    _progressLayer.lineWidth = PROGRESS_LINE_WIDTH+5;
    
    
    //渐变图层
    CALayer * grain = [CALayer layer];
    
    CAGradientLayer *gradientLayer =  [CAGradientLayer layer];
    
    gradientLayer.frame = CGRectMake(0, 0, self.bounds.size.width/2, self.bounds.size.height);
    
    [gradientLayer setColors:[NSArray arrayWithObjects:(id)[[UIColor orangeColor] CGColor],(id)[RYUIColorWithRGB(142, 66, 60) CGColor], nil]];
    
    [gradientLayer setLocations:@[@0.1,@0.9]];
    
    [gradientLayer setStartPoint:CGPointMake(0.05, 1)];
    
    [gradientLayer setEndPoint:CGPointMake(0.9, 0)];
    [grain addSublayer:gradientLayer];
    
    
    CAGradientLayer * gradientLayer1 = [CAGradientLayer layer];
    gradientLayer1.frame = CGRectMake(self.bounds.size.width/2-10, 0, self.bounds.size.width/2+10, self.bounds.size.height);
    
    [gradientLayer1 setColors:[NSArray arrayWithObjects:(id)[RYUIColorWithRGB(142, 66, 60) CGColor],(id)[[UIColor greenColor] CGColor], nil]];
    [gradientLayer1 setLocations:@[@0.3,@1]];
    
    [gradientLayer1 setStartPoint:CGPointMake(0.2, 0.05)];
    
    [gradientLayer1 setEndPoint:CGPointMake(1, 1)];
    [grain addSublayer:gradientLayer1];
    
    //用progressLayer来截取渐变层 遮罩
    
    [grain setMask:_progressLayer];
    
    [self.layer addSublayer:grain];
    
    //增加动画
    
    CABasicAnimation *pathAnimation=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    
    pathAnimation.duration = 3;
    
    pathAnimation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    pathAnimation.fromValue=[NSNumber numberWithFloat:0.0f];
    
    pathAnimation.toValue=[NSNumber numberWithFloat:1.0f];
    
    pathAnimation.autoreverses=NO;
    //pathAnimation.repeatCount = INFINITY;
    _progressLayer.path=path.CGPath;
    
    [_progressLayer addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
}


@end
