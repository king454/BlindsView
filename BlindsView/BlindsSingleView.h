//
//  BlindsSingleView.h
//  anyDemo
//
//  Created by king454 on 14-7-3.
//  Copyright (c) 2014年 MyName. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BlindsSingleView;
typedef NS_ENUM(NSInteger, PageState) {
    PageStateLeftToRight =0,
    PageStateRightToLeft =1,
    PageStateUpToDown    =2,
    PageStateDownToUp    =3,
    PageStateVertical    =4,//当设定该状态会从当前状态跳转到90度，执行动画时间是0.25
    PageStateNormal      =5,//当设定改状态会从当前状态跳转到0 度， 执行动画时间是0.25
};

@protocol BlindsSingleViewDelegate <NSObject>
@optional
-(void)blindSingle:(BlindsSingleView*)singleView withPageStateVertical:(PageState)lastPageState;
-(void)blindSingle:(BlindsSingleView *)singleView withPageStateNormal:(PageState)lastPageState;
@end


@interface BlindsSingleView : UIView
{
    BOOL disableActions;
    CGImageRef aboveImageRef;
    CGImageRef underImageRef;
    PageState pageState;
    CGFloat pageStateAnimationDuration;
}
@property (nonatomic)CGImageRef aboveImageRef;
@property (nonatomic)CGImageRef underImageRef;
@property (nonatomic,assign)BOOL       disableActions;
@property (nonatomic,assign)PageState pageState;

@property (nonatomic,assign)id<BlindsSingleViewDelegate>blindsSingleDelegate;
@property (nonatomic,assign)CGFloat pageStateAnimationDuration;

-(id)initWithAboveImage:(CGImageRef)aboveImage withUnderImage:(CGImageRef)underImage withFrame:(CGRect)frame;
-(void)fromRightToLeft:(CGFloat)degress;
-(void)fromLeftToRight:(CGFloat)degress;
-(void)fromUpToDown:(CGFloat)degress;
-(void)fromDownToUp:(CGFloat)degress;

@end
