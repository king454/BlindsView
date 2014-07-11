//
//  BlindsView.h
//  BlindsView
//
//  Created by king454 on 14-7-5.
//  Copyright (c) 2014年 MyName. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlindsSingleView.h"

@interface BlindsView : UIView<BlindsSingleViewDelegate,UIGestureRecognizerDelegate>
{
    UIImage   *aboveImage;
    UIImage   *underImage;
    NSInteger  totalIndex;
    CGFloat    swipeActionTime;
    CGFloat    edgeInvalidRate;
    CGFloat    swipeSpeed;
}
@property (nonatomic,strong)UIImage   *aboveImage;
@property (nonatomic,strong)UIImage   *underImage;
/**
 *  总页数，默认1，建议不要超过30，经测试到达50，5S的设备都会卡，在往下待测
 */
@property (nonatomic,assign)NSInteger  totalIndex;
/**
 *  轻扫自动动画的总时间，默认2秒
 */
@property (nonatomic,assign)CGFloat    swipeActionTime;
/**
 *  边缘无效化的比率取值为 0.0 - 0.5,默认是0.1;
 */
@property (nonatomic,assign)CGFloat   edgeInvalidRate;
/**
 *  这个值是用来设定亲扫的速度（力度？）必须要大于640小于3000，我是这么设定的，默认640的话，
 */
@property (nonatomic,assign)CGFloat   swipeSpeed;
/**
 *  初始化
 *
 *  @param aboveImage 在上面的图片
 *  @param underImage 下面的图片
 *  @param index      分成几页,不能大于99页
 *  @param frame      设定必要的frame值来确定控件的frame值，以次为基础来放入百叶
 *  @return 实例对象
 */
@property (nonatomic,copy)void(^animationDidFinish)(void);
@property (nonatomic,copy)void(^animationDidCancel)(void);

-(id)initWithAboveImage:(UIImage*)aboveImage withUnderImage:(UIImage*)underImage withTotalIndex:(NSInteger)totalIndex withFrame:(CGRect)frame;
-(void)blindsReloadData;
@end
