//
//  BlindsSingleView.m
//  anyDemo
//
//  Created by king454 on 14-7-3.
//  Copyright (c) 2014年 MyName. All rights reserved.
//

#import "BlindsSingleView.h"
@interface BlindsSingleView ()
{
    CALayer *_aboveLayer;
    CALayer *_underLayer;
    PageState lastState;
}
@end


@implementation BlindsSingleView

@synthesize aboveImageRef =aboveImageRef;
@synthesize underImageRef =underImageRef;
@synthesize pageState        =pageState;
@synthesize disableActions  =disableActions;
@synthesize pageStateAnimationDuration =pageStateAnimationDuration;
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        self.userInteractionEnabled = YES;
    }
    return self;
}
-(id)initWithAboveImage:(CGImageRef)aboveImage withUnderImage:(CGImageRef)underImage withFrame:(CGRect)frame
{
    self = [self initWithFrame:frame];
    if (self) {
        self.underImageRef = underImage;
        self.aboveImageRef = aboveImage;
        self.pageState     = PageStateNormal;
        self.pageStateAnimationDuration = 0.25;
        self.disableActions =NO;
    }
    return  self;
}

-(void)dealloc
{
    CGImageRelease(aboveImageRef);
    CGImageRelease(underImageRef);
}
-(void)setAboveImageRef:(CGImageRef)imageRef
{
    if (aboveImageRef!=imageRef) {
        CGImageRelease(aboveImageRef);
        aboveImageRef = CGImageRetain(imageRef);
        [self setAboveLayer];
    }
}
-(void)setUnderImageRef:(CGImageRef)imageRef
{
    if (underImageRef!=imageRef) {
        CGImageRelease(underImageRef);
        underImageRef = CGImageRetain(imageRef);
        [self setUnderLayer];
    }
}
-(void)setAboveLayer
{
    _aboveLayer = [CALayer layer];
    if (aboveImageRef) {
        _aboveLayer.contents = (__bridge id)(aboveImageRef);
        _aboveLayer.zPosition = 0;
        _aboveLayer.frame = self.bounds;
        [self.layer addSublayer:_aboveLayer];
    }
}
-(void)setUnderLayer
{
    _underLayer = [CALayer layer];
    if (underImageRef) {
        _underLayer.contents = (__bridge id)(underImageRef);
        _underLayer.zPosition= -10;
        _underLayer.frame = self.bounds;
        [self.layer addSublayer:_underLayer];
    }
}
-(void)fromRightToLeft:(CGFloat)degress
{
    [self _actionWitState:PageStateRightToLeft andDegress:degress];
}
-(void)fromLeftToRight:(CGFloat)degress
{
    [self _actionWitState:PageStateLeftToRight andDegress:degress];
}
-(void)fromUpToDown:(CGFloat)degress
{
    [self _actionWitState:PageStateUpToDown andDegress:degress];
}
-(void)fromDownToUp:(CGFloat)degress
{
    [self _actionWitState:PageStateDownToUp andDegress:degress];
}
-(void)_actionWitState:(PageState)state andDegress:(CGFloat)degress
{
    if (self.pageState!= PageStateVertical) {
        self.pageState = state;
        [CATransaction setDisableActions:YES];
        CATransform3D transform = CATransform3DIdentity;
        if (state == PageStateLeftToRight) {
             transform = CATransform3DRotate(transform, degress*M_PI_2, 0.0f, 1.0f, 0.0);
        }else if(state == PageStateRightToLeft){
            transform = CATransform3DRotate(transform, degress*M_PI_2, 0.0f, -1.0f, 0.0);
        }else if(state == PageStateDownToUp){
            transform = CATransform3DRotate(transform, degress*M_PI_2, 1.0f, 0.0f, 0.0);
        }else if(state == PageStateUpToDown){
            transform = CATransform3DRotate(transform, degress*M_PI_2, -1.0f, 0.0f, 0.0);
        }
        _aboveLayer.transform = transform;
    }

}
-(void)setPageState:(PageState)state
{
    if (pageState != state) {
        switch (state) {
            case PageStateLeftToRight:
                [self _actionPageStateLeftToRight:state];
                break;
            case PageStateRightToLeft:
                [self _actionPageStateRightToleft:state];
                break;
            case PageStateUpToDown:
                [self _actionPageStateUpToDown:state];
                break;
            case PageStateDownToUp:
                [self _actionPageStateDownToUp:state];
                break;
            case PageStateVertical:
                [self _actionPageStateVertical:state];
                break;
            case PageStateNormal:
                [self _actionPageStateNormal:state];
                break;
            default:
                [self _actionPageStateNormal:state];
                break;
        }
    }
}
-(void)_actionPageStateLeftToRight :(PageState)state
{
        pageState = state;
        [CATransaction setDisableActions:YES];
        _aboveLayer.anchorPoint = CGPointMake(1.0, 0.0);
        _aboveLayer.position    = CGPointMake(self.bounds.size.width, 0.0);
}
-(void)_actionPageStateRightToleft :(PageState)state
{
        pageState = state;
        [CATransaction setDisableActions:YES];
        _aboveLayer.anchorPoint = CGPointZero;
        _aboveLayer.position    = CGPointZero;
}
-(void)_actionPageStateUpToDown :(PageState)state
{
        pageState = state;
        [CATransaction setDisableActions:YES];
        _aboveLayer.anchorPoint = CGPointMake(0.0, 1.0);;
        _aboveLayer.position    = CGPointMake(0.0,self.bounds.size.height);
}
-(void)_actionPageStateDownToUp :(PageState)state
{
        pageState = state;
        [CATransaction setDisableActions:YES];
        _aboveLayer.anchorPoint = CGPointZero;
        _aboveLayer.position    = CGPointZero;
}
-(void)_actionPageStateVertical :(PageState)state
{
        [CATransaction begin];
        [CATransaction setAnimationDuration:pageStateAnimationDuration];
        [CATransaction setDisableActions:disableActions];
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
        [CATransaction setCompletionBlock:^{
            if ([_blindsSingleDelegate respondsToSelector:@selector(blindSingle:withPageStateVertical:)]) {
                [_blindsSingleDelegate blindSingle:self withPageStateVertical:lastState];
            }
        }];
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = -1/1000.0f;
        if (pageState == PageStateDownToUp) {
            transform = CATransform3DRotate(transform, M_PI_2, 1.0f, 0.0f, 0.0);
        }else if (pageState == PageStateUpToDown) {
            transform = CATransform3DRotate(transform, M_PI_2, -1.0f, 0.0f, 0.0);
        }else if (pageState == PageStateLeftToRight) {
            transform = CATransform3DRotate(transform, M_PI_2, 0.0f, 1.0f, 0.0);
        }else if (pageState == PageStateRightToLeft) {
            transform = CATransform3DRotate(transform, M_PI_2, 0.0f, -1.0f, 0.0);
        }
        _aboveLayer.transform = transform;
        
        [CATransaction commit];
        lastState = pageState;
        pageState = state;
}
-(void)_actionPageStateNormal :(PageState)state
{
    [CATransaction begin];
    [CATransaction setAnimationDuration:pageStateAnimationDuration];
    [CATransaction setDisableActions:disableActions];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [CATransaction setCompletionBlock:^{
        if ([_blindsSingleDelegate respondsToSelector:@selector(blindSingle:withPageStateVertical:)]) {
            [_blindsSingleDelegate blindSingle:self withPageStateNormal:lastState];
        }
    }];

    CATransform3D transform = CATransform3DIdentity;
//    if (pageState == PageStateLeftToRight&&pageState== PageStateRightToLeft) {
//        transform = CATransform3DRotate(transform, 0, 0.0f, 1.0f, 0.0);
//    }else if (pageState == PageStateUpToDown&&pageState== PageStateDownToUp) {
//        transform = CATransform3DRotate(transform, 0, 1.0f, 0.0f, 0.0);
//    }
    _aboveLayer.transform = transform;
    [CATransaction commit];
    lastState = pageState;
    pageState = state;
}

@end
