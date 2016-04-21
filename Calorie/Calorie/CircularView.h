//
//  CircularView.h
//  Calorie
//
//  Created by zt on 16/4/22.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

#define degressToRadius(ang) (M_PI*(ang)/180.0f) //把角度转换成PI的方式
#define PROGRESS_WIDTH 80 // 圆直径
#define PROGRESS_LINE_WIDTH 10 //弧线的宽度
@interface CircularView : UIView{
    CAShapeLayer * _trackLayer;
    CAShapeLayer * _progressLayer;

}

@end
