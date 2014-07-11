//
//  UIImage+BlindsCreatViewWithSize.m
//  BlindsView
//
//  Created by king454 on 14-7-5.
//  Copyright (c) 2014年 MyName. All rights reserved.
//

#import "UIImage+BlindsCreatViewWithSize.h"

@implementation UIImage (BlindsCreatViewWithSize)
#pragma mark ---------判断图片尺寸与frame--------
/**
 *  判断图片是否符合尺寸，返回并处理生成对应尺寸的图片
 *
 *  @param size  尺寸
 *
 *  @return 返回对应尺寸的图片
 */
-(UIImage*)opertionWithSize:(CGSize)size
{
    if ([self judgeImageSize:size]) {
        return self;
    }else{
        return [self screenWithSize:size];
    }
}
/**
 *  判断图片的尺寸是否是对应的
 *
 *  @param size  尺寸
 *
 *  @return 是与否
 */

-(BOOL)judgeImageSize:(CGSize)size
{
    CGSize imageSize = self.size;
    imageSize.height *= self.scale;
    imageSize.width  *= self.scale;
    return  CGSizeEqualToSize(imageSize, size);
}
/**
 *  给定尺寸，然后截图生成对应的图片
 *
 *  @param size  尺寸
 *
 *  @return 返回处理后的图片
 */
-(UIImage*)screenWithSize:(CGSize)size
{
    UIView *view = [UIView new];
    view.frame =CGRectMake(0, 0, size.width, size.height);
    view.layer.contentsGravity = kCAGravityResizeAspect;
    view.layer.contents = (__bridge id)(self.CGImage);
    //开始截图
    UIGraphicsBeginImageContextWithOptions(size, YES, 1.0);
    //获取图像
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *reslutImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return  reslutImage;
}

@end
