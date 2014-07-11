//
//  BlindsView.m
//  BlindsView
//
//  Created by king454 on 14-7-5.
//  Copyright (c) 2014年 MyName. All rights reserved.
//

#import "BlindsView.h"
#import "UIImage+BlindsCreatViewWithSize.h"

#define Height (self.bounds.size.height)
#define Width  (self.bounds.size.width)
typedef NS_ENUM(NSInteger, BlindsRollState) {
    BlindsRollStateNormal           = 0,
    BlindsRollStateRightToLeft      = 1,
    BlindsRollStateLeftToRight      = 2,
    BlindsRollStateUpToDown         = 3,
    BlindsRollStateDownToUp         = 4,
    BlindsRollStateIsAnimation      = 5,
    BlindsRollStateCancelAnimation     = 6,
};

@interface BlindsView ()
{
    UIPanGestureRecognizer *_panGesture;
    CGPoint _startPoint;
    BOOL    _animationFinish;
    int        _lastNumber;
}

@property (nonatomic,strong)NSMutableArray *aboveImageArr;
@property (nonatomic,strong)NSMutableArray *underImageArr;

@property (nonatomic,strong)NSMutableArray *blindsSubViewArr;

@property (nonatomic,assign)BlindsRollState blindsRollstate;

@end
@implementation BlindsView

@synthesize aboveImage      = aboveImage;
@synthesize underImage      = underImage;
@synthesize totalIndex      = totalIndex;
@synthesize swipeActionTime = swipeActionTime;
@synthesize edgeInvalidRate = edgeInvalidRate;
@synthesize swipeSpeed      = swipeSpeed;
#pragma mark -----------初始化方法------------
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.totalIndex              = 1;
        self.swipeActionTime     = 2.0f;
        self.edgeInvalidRate      = 0.2;
        self.swipeSpeed            = 640.0f;
        self.userInteractionEnabled =YES;
        _animationFinish           = NO;
        _lastNumber                 = 0;
    }
    return self;
}

-(id)initWithAboveImage:(UIImage*)above withUnderImage:(UIImage*)under withTotalIndex:(NSInteger)totalInd withFrame:(CGRect)frame
{
    self = [self initWithFrame:frame];
    if (self) {
        self.totalIndex = totalInd;
        self.aboveImage = above ;
        self.underImage = under;
        [self blindsReloadData];
        [self _addGestureREcognizers];
        self.blindsRollstate = BlindsRollStateNormal;
    }
    return  self;
}
-(void)dealloc
{
    aboveImage = nil;
    underImage = nil;
    _blindsSubViewArr =nil;
}
#pragma  mark -----------set方法--------------
/*这里有个连续逻辑 
 首先是图片的获取->将图片处理生成对应的图片数组->生成子View->刷新界面是界面与数据一致
 */

-(void)setAboveImage:(UIImage *)aboveImg
{
    if (aboveImage!=aboveImg ) {
        aboveImage = [aboveImg opertionWithSize:self.frame.size];
        self.aboveImageArr = [self _segementationImage:aboveImage withSize:[self subViewSize:totalIndex] withsubImageNumber:totalIndex];
    }
}
-(void)setUnderImage:(UIImage *)underImg
{
    if (underImage!=underImg ) {
        underImage = [underImg opertionWithSize:self.frame.size];
        self.underImageArr = [self _segementationImage:underImage withSize:[self subViewSize:totalIndex] withsubImageNumber:totalIndex];
    }
}
-(void)setTotalIndex:(NSInteger)totalInd
{
    if (totalIndex<=0) {
        totalIndex=1;
    }
    if (totalIndex>=50) {
        totalIndex =50;
    }
    if (totalIndex != totalInd) {
        totalIndex = totalInd;
        if (underImage&&aboveImage) {
            self.aboveImageArr = [self _segementationImage:aboveImage withSize:[self subViewSize:totalIndex] withsubImageNumber:totalIndex];
            self.underImageArr = [self _segementationImage:underImage withSize:[self subViewSize:totalIndex] withsubImageNumber:totalIndex];
        }
    }
}
-(void)setAboveImageArr:(NSMutableArray *)aboveImageArr
{
    if (_aboveImageArr != aboveImageArr) {
        _aboveImageArr = aboveImageArr;
        [self _upDateBlindsSubViewArr];
    }
}
-(void)setUnderImageArr:(NSMutableArray *)underImageArr
{
    if (_underImageArr != underImageArr) {
        _underImageArr = underImageArr;
        [self _upDateBlindsSubViewArr];
    }
}
-(void)setBlindsRollstate:(BlindsRollState)blindsRollstate
{
    if (_blindsRollstate != blindsRollstate) {
        _blindsRollstate = blindsRollstate;
        switch (blindsRollstate) {
            case BlindsRollStateNormal:
                self.userInteractionEnabled = YES;
                break;
            case BlindsRollStateIsAnimation:
                self.userInteractionEnabled = NO;
                break;
            case BlindsRollStateLeftToRight:
                break;
            case BlindsRollStateRightToLeft:
                break;
            case BlindsRollStateUpToDown:
                break;
            case BlindsRollStateDownToUp:
                break;
            case BlindsRollStateCancelAnimation:
                break;
            default:
                break;
        }
    }
}
-(void)setEdgeInvalidRate:(CGFloat)edgeInvalidR
{
    if (edgeInvalidR<0) {
        edgeInvalidRate = 0.0f;
    }else if (edgeInvalidR >0.5f){
        edgeInvalidRate =0.5f;
    }else{
        edgeInvalidRate = edgeInvalidR;
    }
}
-(void)setSwipeActionTime:(CGFloat)swipeActionT
{
    if (swipeActionT <=0) {
        swipeActionTime = 2.0;
    }else if(swipeActionTime != swipeActionT){
        swipeActionTime = swipeActionT;
    }
}
-(void)setSwipeSpeed:(CGFloat)swipeS
{
    if (swipeS>=640.0&&swipeS<=3000.0) {
        swipeSpeed = swipeS;
    }else if(swipeS<640.0){
        swipeSpeed = 640.0f;
    }else if(swipeS>3000.0){
        swipeSpeed = 3000.0;
    }
}
/**
 *  更新视图
 */
-(void)blindsReloadData
{
    if (_blindsSubViewArr) {
        [self _removeBlindsSubLayer:_blindsSubViewArr];
        [self _addBlindsSubLayer:_blindsSubViewArr];
    }
}


#pragma mark ----------切割图片--------
/**
 *  切割图片返回数组
 *
 *  @param image             图片
 *  @param size              尺寸
 *  @param number            切割数量
 *  @param pagingOrientation 翻页方向，上下翻横切，水平翻纵切
 *
 *  @return 返回切割完毕后的结果
 */
-(NSMutableArray*)_segementationImage:(UIImage*)image withSize:(CGSize)size withsubImageNumber:(NSInteger)number
{
    NSMutableArray *array = [NSMutableArray new];
    CGImageRef imageRef = image.CGImage;
    if (number==0) {
        number = 1;
    }
    for (int i=0 ; i<number; i++) {
        NSMutableArray *smallArr = [NSMutableArray new];
        for (int j = 0 ; j<number; j++) {
            CGImageRef subImageRef = NULL;
            subImageRef = CGImageCreateWithImageInRect(imageRef, (CGRect){CGPointMake(size.width*j, size.height*i),size});
            if (subImageRef != NULL) {
                [smallArr addObject:(__bridge id)(subImageRef)];
                CGImageRelease(subImageRef);
            }
        }
        [array addObject:smallArr];
    }
    return array;
}
#pragma mark    ------生成对应的子视图----
/**
 *  生成对应的subView
 *
 *  @param aboveImageArr 表层图片源
 *  @param underImageArr 里层图片源
 *  @param number        subView数量
 *
 *  @return 返回子view数组
 */
-(NSMutableArray*)_creatViewWithAboveImageArr:(NSMutableArray*)aboveImageArr withUnderImageArr:(NSMutableArray*)underImageArr withArrNumber:(NSInteger)number
{
    if (aboveImageArr.count==number&&underImageArr.count == number) {
        NSMutableArray *viewArr = [NSMutableArray new];
        CGSize size = [self subViewSize:totalIndex];
        for (int i = 0 ; i<number; i++) {
            NSMutableArray *smallArr = [NSMutableArray new];
            for (int j = 0 ; j<number; j++) {
                CGRect rect = (CGRect){CGPointMake(size.width*j, size.height*i),size};
                BlindsSingleView *subView = [[BlindsSingleView alloc]initWithAboveImage:(__bridge CGImageRef)(aboveImageArr[i][j]) withUnderImage:(__bridge CGImageRef)(underImageArr[i][j]) withFrame:rect];
                subView.blindsSingleDelegate = self;
                subView.pageStateAnimationDuration = swipeActionTime/totalIndex;
                subView.tag = 100000+i*100+j;
                [smallArr addObject:subView];
            }
            [viewArr addObject:smallArr];
        }
        return viewArr;
    }
    return nil;
}
/**
 *  返回图片尺寸
 *
 *  @param number            数量
 *  @param pagingOrientation 方向
 *
 *  @return 尺寸
 */
-(CGSize)subViewSize:(NSInteger)number
{
    CGSize size =self.frame.size;
    size.width  /= number;
    size.height /= number;
    return size;
}
#pragma mark     ----------手势
-(void)_addGestureREcognizers
{
    _panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(_panAction:)];
    [self addGestureRecognizer:_panGesture];
    _panGesture.delegate =self;
    
}
#pragma mark --------pan移动的手势------
-(void)_panAction:(UIPanGestureRecognizer*)pan
{
    if (_blindsRollstate ==BlindsRollStateNormal) {
        [self _swipjudgeWithPanGestureRecognizer:pan];
    }else if(_blindsRollstate == BlindsRollStateLeftToRight){
        [self _panMoveLeftToRight:pan];
    }else if(_blindsRollstate == BlindsRollStateRightToLeft){
        [self _panMoveRightToLeft:pan];
    }else if(_blindsRollstate == BlindsRollStateDownToUp){
        [self _panMoveDownToUp:pan];
    }else if(_blindsRollstate == BlindsRollStateUpToDown){
        [self _panMoveUpToDown:pan];
    }
}
-(void)_swipjudgeWithPanGestureRecognizer:(UIPanGestureRecognizer*)pan
{
    CGPoint point = [pan velocityInView:self];
    CGFloat x = point.x;
    CGFloat y = point.y;
    /**
     *  先分离轻扫手势
     */
    if (x>swipeSpeed) {
        [self _swipAction:UISwipeGestureRecognizerDirectionRight];
        return;
    }else if(x<-swipeSpeed){
        [self _swipAction:UISwipeGestureRecognizerDirectionLeft];
        return;
    }else if(y<-swipeSpeed){
        [self _swipAction:UISwipeGestureRecognizerDirectionUp];
        return;
    }else if(y>swipeSpeed){
        [self _swipAction:UISwipeGestureRecognizerDirectionDown];
        return;
    }else if(x>-swipeSpeed&&x<swipeSpeed&&y<swipeSpeed&&y>-swipeSpeed){
        CGPoint locationPoint = [pan locationInView:self];
        if (pan.state == UIGestureRecognizerStateBegan) {
            [self _panBeginToMoveWithStartPoint:locationPoint];
        }
    }
}
-(void)_swipAction:(UISwipeGestureRecognizerDirection)direction
{
    if (_blindsRollstate==BlindsRollStateNormal) {
        _blindsRollstate = BlindsRollStateIsAnimation;
        _animationFinish = YES;
        switch (direction) {
            case UISwipeGestureRecognizerDirectionRight:
                [self _swipeLeftToRight];
                break;
            case UISwipeGestureRecognizerDirectionLeft:
                [self _swipeRightToLeft];
                break;
            case UISwipeGestureRecognizerDirectionUp:
                [self _swipeDownToUp];
                break;
            case UISwipeGestureRecognizerDirectionDown:
                [self _swipeUpToDown];
                break;
            default:
                break;
        }
    }
}
-(void)_panBeginToMoveWithStartPoint:(CGPoint)point
{
    CGFloat x= point.x;
    CGFloat y= point.y;
    /**
     *     _________
     *    |X*******X|
     *    |*       *|
     *    |*       *|
     *    |*       *|
     *    |X*******X|
     *     —————————
     *   先排除掉非*****区域的，然后根据情况来判断是往哪个方向来做手势
     */
    if (x>=Width*edgeInvalidRate&&x<=Width*(1-edgeInvalidRate)&&y>=Height*edgeInvalidRate&&y<=Height*(1-edgeInvalidRate)) {
        return;
    }else if ((x<Width*edgeInvalidRate&&x>0)&&((y>0&&y<Height*edgeInvalidRate)||(y>Height*(1-edgeInvalidRate)&&y<Height))){
        return;
    }else if ((x<Width&&x>Width*(1-edgeInvalidRate))&&((y>0&&y<Height*edgeInvalidRate)||(y>Height*(1-edgeInvalidRate)&&y<Height))){
        return;
    }else if(x<Width*edgeInvalidRate&&x>0){
        _startPoint = point;
        self.blindsRollstate = BlindsRollStateLeftToRight;
        return;
    }else if (x<Width&&x>Width*(1-edgeInvalidRate)){
        _startPoint = point;
        self.blindsRollstate = BlindsRollStateRightToLeft;
        return;
    }else if(y>0&&y<Height*edgeInvalidRate){
        self.blindsRollstate = BlindsRollStateUpToDown;
        _startPoint = point;
        return;
    }else if (y>Height*(1-edgeInvalidRate)&&y<Height){
        self.blindsRollstate = BlindsRollStateDownToUp;
        _startPoint = point;
        return;
    }
}
//向右pan
-(void)_panMoveLeftToRight:(UIPanGestureRecognizer*)pan
{
    CGFloat x =Width-_startPoint.x;//这里计算角度的总长度是通过起始点到最边缘为总长来计算的
    CGPoint movePoint =[pan translationInView:self];
    int number      = [self _calculateNumberOfTheSubViewToMove:x withCurrent:movePoint.x];
    if (number<=totalIndex-1&&number>=0) {
        if (number>totalIndex-1) {
            number =(int) totalIndex-1;
        }
        if (number<0) {
            number =0;
        }
        if (pan.state ==UIGestureRecognizerStateChanged) {
            if (movePoint.x>=0) {
                CGFloat degress = [self _calculateDegress:x withCurrent:movePoint.x];
                for (int i = 0 ; i<totalIndex; i++) {
                    [self _blindsViewMoveWith:_blindsSubViewArr[i][number]
                                     andState:BlindsRollStateLeftToRight andDegress:degress];
                    [self _panBlindsViewCompleteSubView:(number>0?_blindsSubViewArr[i][number-1]:nil)
                                       andCancelSubView:(number<=totalIndex-2?_blindsSubViewArr[i][number+1]:nil)
                                          withPageState:PageStateLeftToRight
                                withCurrentSubViewIndex:number];
                }
                _lastNumber=number;
            }
        }
    }
    if (pan.state == UIGestureRecognizerStateEnded||pan.state ==UIGestureRecognizerStateCancelled) {
        //这里要判断结束点在哪里,先判断是否大于零，小于零的话基本就是直接结束，大于零才做下面动作
        if (movePoint.x*2>=x) {
            _animationFinish = YES;
            self.blindsRollstate = BlindsRollStateIsAnimation;
            for (int i =0; i<totalIndex; i++) {
                [self _panBlindsViewCompleteBlindsSingleView:_blindsSubViewArr[i][_lastNumber] withPageState:PageStateLeftToRight];
            }
        }else if(movePoint.x>=0){
            _animationFinish = NO;
            self.blindsRollstate = BlindsRollStateCancelAnimation;
            for (int i = 0; i<totalIndex; i++) {
                [self _panBlindsViewCancelBlindsSingleView:_blindsSubViewArr[i][_lastNumber] withPageState:PageStateLeftToRight];
            }
        }else if(movePoint.x<0){
            [self _blindsSingLeViewDidCancelAnimation];
        }
    }

    
}
//向左pan
-(void)_panMoveRightToLeft:(UIPanGestureRecognizer*)pan
{
    CGFloat x=_startPoint.x;
    CGPoint movePoint =[pan translationInView:self];
    int number      = [self _calculateNumberOfTheSubViewToMove:x withCurrent:-(movePoint.x)];
    if (number<=totalIndex-1&&number>=0) {
        if (number>totalIndex-1) {
            number =(int) totalIndex-1;
        }
        if (number<0) {
            number =0;
        }
        if (pan.state == UIGestureRecognizerStateChanged) {
            if (movePoint.x<=0) {
                CGFloat degress = [self _calculateDegress:x withCurrent:-(movePoint.x)];
                for (int i =0 ; i<totalIndex; i++) {
                    [self _blindsViewMoveWith:_blindsSubViewArr[i][totalIndex-1-number] andState:BlindsRollStateRightToLeft andDegress:degress];
                    [self _panBlindsViewCompleteSubView:(number>0?_blindsSubViewArr[i][totalIndex-number]:nil)
                                       andCancelSubView:(number<=totalIndex-2?_blindsSubViewArr[i][totalIndex-number-2]:nil)
                                          withPageState:PageStateRightToLeft
                                withCurrentSubViewIndex:number];
                }
                _lastNumber=number;
            }
        }
    }
    if (pan.state == UIGestureRecognizerStateEnded||pan.state ==UIGestureRecognizerStateCancelled) {
        if ((-movePoint.x)*2>=x) {
            _animationFinish = YES;
            self.blindsRollstate = BlindsRollStateIsAnimation;
            for (int i =0; i<totalIndex; i++) {
                [self _panBlindsViewCompleteBlindsSingleView:_blindsSubViewArr[i][totalIndex-_lastNumber-1] withPageState:PageStateRightToLeft];
            }
        }else if(movePoint.x<=0){
            _animationFinish = NO;
            self.blindsRollstate = BlindsRollStateCancelAnimation;
            for (int i = 0; i<totalIndex; i++) {
                [self _panBlindsViewCancelBlindsSingleView:_blindsSubViewArr[i][totalIndex-_lastNumber-1] withPageState:PageStateRightToLeft];
            }
        }else if(movePoint.x>0){
            [self _blindsSingLeViewDidCancelAnimation];
        }
    }
}
-(void)_panMoveDownToUp:(UIPanGestureRecognizer*)pan
{
    CGFloat y=_startPoint.y;
    CGPoint movePoint =[pan translationInView:self];
    int number      = [self _calculateNumberOfTheSubViewToMove:y withCurrent:-(movePoint.y)];
    if (number<=totalIndex-1&&number>=0) {
        if (number>totalIndex-1) {
            number =(int) totalIndex-1;
        }
        if (number<0) {
            number =0;
        }
        if (pan.state == UIGestureRecognizerStateChanged) {
            if (movePoint.y<=0) {
                CGFloat degress = [self _calculateDegress:y withCurrent:-(movePoint.y)];
                for (int i =0 ; i<totalIndex; i++) {
                    [self _blindsViewMoveWith:_blindsSubViewArr[totalIndex-1-number][i] andState:BlindsRollStateDownToUp andDegress:degress];
                    [self _panBlindsViewCompleteSubView:(number>0?_blindsSubViewArr[totalIndex-number][i]:nil)
                                       andCancelSubView:(number<=totalIndex-2?_blindsSubViewArr[totalIndex-number-2][i]:nil)
                                          withPageState:PageStateDownToUp
                                withCurrentSubViewIndex:number];
                }
                _lastNumber=number;
            }
        }
    }
    if (pan.state == UIGestureRecognizerStateEnded||pan.state ==UIGestureRecognizerStateCancelled) {
        if ((-movePoint.y)*2>=y) {
            _animationFinish = YES;
            self.blindsRollstate = BlindsRollStateIsAnimation;
            for (int i =0; i<totalIndex; i++) {
                [self _panBlindsViewCompleteBlindsSingleView:_blindsSubViewArr[totalIndex-_lastNumber-1][i] withPageState:PageStateDownToUp];
            }
        }else if(movePoint.y<=0){
            _animationFinish = NO;
            self.blindsRollstate = BlindsRollStateCancelAnimation;
            for (int i = 0; i<totalIndex; i++) {
                [self _panBlindsViewCancelBlindsSingleView:_blindsSubViewArr[totalIndex-_lastNumber-1][i] withPageState:PageStateDownToUp];
            }
        }else if(movePoint.y>0){
            [self _blindsSingLeViewDidCancelAnimation];
        }
    }
}
-(void)_panMoveUpToDown:(UIPanGestureRecognizer*)pan
{
    CGFloat y =Height-_startPoint.y;
    CGPoint movePoint  =[pan translationInView:self];
    int number         = [self _calculateNumberOfTheSubViewToMove:y withCurrent:movePoint.y];
    if (number<=totalIndex-1&&number>=0) {
        if (number>totalIndex-1) {
            number =(int) totalIndex-1;
        }
        if (number<0) {
            number =0;
        }
        if (pan.state ==UIGestureRecognizerStateChanged) {
            if (movePoint.y>=0) {
                CGFloat degress = [self _calculateDegress:y withCurrent:movePoint.y];
                for (int i = 0 ; i<totalIndex; i++) {
                    [self _blindsViewMoveWith:_blindsSubViewArr[number][i] andState:BlindsRollStateUpToDown andDegress:degress];
                    [self _panBlindsViewCompleteSubView:(number>0?_blindsSubViewArr[number-1][i]:nil)
                                       andCancelSubView:(number<=totalIndex-2?_blindsSubViewArr[number+1][i]:nil)
                                          withPageState:PageStateUpToDown
                                withCurrentSubViewIndex:number];
                }
                _lastNumber=number;
            }
        }
    }
    if (pan.state == UIGestureRecognizerStateEnded||pan.state ==UIGestureRecognizerStateCancelled) {
        //这里要判断结束点在哪里
        if (movePoint.y*2>=y) {
            _animationFinish = YES;
            self.blindsRollstate = BlindsRollStateIsAnimation;
            for (int i =0; i<totalIndex; i++) {
                [self _panBlindsViewCompleteBlindsSingleView:_blindsSubViewArr[_lastNumber][i] withPageState:PageStateUpToDown];
            }
        }else if(movePoint.y>=0){
            _animationFinish = NO;
            self.blindsRollstate = BlindsRollStateCancelAnimation;
            for (int i = 0; i<totalIndex; i++) {
                [self _panBlindsViewCancelBlindsSingleView:_blindsSubViewArr[_lastNumber][i] withPageState:PageStateUpToDown];
            }
        }else if(movePoint.y<0){
            [self _blindsSingLeViewDidCancelAnimation];
        }
    }
}


#pragma mark ---------轻扫状态------------
-(void)_swipeRightToLeft
{
    if (_blindsSubViewArr) {
        for (int j = 0 ; j<totalIndex; j++) {
            id obj = _blindsSubViewArr[j][totalIndex-1];
            [self _blindsSingleView:obj withPageState:PageStateRightToLeft];
        }
    }
}
-(void)_swipeLeftToRight
{
    if (_blindsSubViewArr) {
        for (int j = 0 ; j<totalIndex; j++) {
            id obj = _blindsSubViewArr[j][0];
            [self _blindsSingleView:obj withPageState:PageStateLeftToRight];
        }
    }
}
-(void)_swipeDownToUp
{
    if (_blindsSubViewArr) {
        for (int i = 0 ; i<totalIndex; i++) {
            id obj = _blindsSubViewArr[totalIndex-1][i];
            [self _blindsSingleView:obj withPageState:PageStateDownToUp];
        }
    }
}
-(void)_swipeUpToDown
{
    if (_blindsSubViewArr) {
        for (int i = (int)totalIndex-1 ; i>=0; i--) {
            id obj = _blindsSubViewArr[0][i];
            [self _blindsSingleView:obj withPageState:PageStateUpToDown];
        }
    }
}
#pragma  mark ---------子视图代理-----------
/**
 *  这里是子视图完成抵达直角动画后的回调
 *
 *  @param singleView    子视图
 *  @param lastPageState 上一次的状态
 */
-(void)blindSingle:(BlindsSingleView *)singleView withPageStateVertical:(PageState)lastPageState
{
    if (_blindsRollstate == BlindsRollStateIsAnimation) {
        if (lastPageState == PageStateRightToLeft) {
            [self _blindSingleRightToLeftCompletion:singleView];
        }else if (lastPageState == PageStateLeftToRight) {
            [self _blindSingleLeftToRightCompletion:singleView];
        }else if (lastPageState == PageStateUpToDown) {
            [self _blindSingleUpToDownCompletion:singleView];
        }else if (lastPageState == PageStateDownToUp) {
            [self _blindSingleDownToUpCompletion:singleView];
        }
    }
}
/**
 *  这个是子视图完成还原状态的动画回调
 *
 *  @param singleView    子视图
 *  @param lastPageState 上一次的状态
 */
-(void)blindSingle:(BlindsSingleView *)singleView withPageStateNormal:(PageState)lastPageState
{
    if (_blindsRollstate == BlindsRollStateCancelAnimation) {
        if (lastPageState == PageStateRightToLeft) {
            [self _blindSingleRightToLeftCancel:singleView];
        }else if (lastPageState == PageStateLeftToRight) {
            [self _blindSingleLeftToRightCancel:singleView];
        }else if (lastPageState == PageStateUpToDown) {
            [self _blindSingleUpToDownCancel:singleView];
        }else if (lastPageState == PageStateDownToUp) {
            [self _blindSingleDownToUpCancel:singleView];
        }
    }
}

//这个是swipe左划
-(void)_blindSingleRightToLeftCompletion:(BlindsSingleView*)singleView
{
    int row  = (int)(singleView.tag-100000)%100;//第几列
    int line = (int)(singleView.tag-100000)/100;//第几行
    if (row>0) {
        if (_blindsSubViewArr) {
            id obj = _blindsSubViewArr[line][row-1];
            [self _blindsSingleView:obj withPageState:PageStateRightToLeft];
        }
    }else if(line==0&&row==0){
        [self _blindsSingleViewDidFinshAnimation];
    }
}
//这个是pan左划取消
-(void)_blindSingleRightToLeftCancel:(BlindsSingleView*)singleView
{
    int row  = (int)(singleView.tag-100000)%100;//第几列
    int line = (int)(singleView.tag-100000)/100;//第几行
    if (row<totalIndex-1) {
        if (_blindsSubViewArr) {
            id obj = _blindsSubViewArr[line][row+1];
            [self _panBlindsViewCancelBlindsSingleView:obj withPageState:PageStateRightToLeft];
        }
    }else if(line==totalIndex-1&&row==totalIndex-1){
        [self _blindsSingleViewDidFinshAnimation];
    }
}
//这个是swipe右划
-(void)_blindSingleLeftToRightCompletion:(BlindsSingleView*)singleView
{
    int row  = (int)(singleView.tag-100000)%100;//第几列
    int line = (int)(singleView.tag-100000)/100;//第几行
    if (row<totalIndex-1) {
        if (_blindsSubViewArr) {
            id obj = _blindsSubViewArr[line][row+1];
            [self _blindsSingleView:obj withPageState:PageStateLeftToRight];
        }
    }else if(line==totalIndex-1&&row==totalIndex-1){
        [self _blindsSingleViewDidFinshAnimation];
    }
}
//这个是pan右划取消
-(void)_blindSingleLeftToRightCancel:(BlindsSingleView*)singleView
{
    int row  = (int)(singleView.tag-100000)%100;//第几列
    int line = (int)(singleView.tag-100000)/100;//第几行
    if (row>0) {
        if (_blindsSubViewArr) {
            id obj = _blindsSubViewArr[line][row-1];
            [self _panBlindsViewCancelBlindsSingleView:obj withPageState:PageStateLeftToRight];
        }
    }else if(line==0&&row==0){
        [self _blindsSingleViewDidFinshAnimation];
    }
}
//swipe下滑
-(void)_blindSingleUpToDownCompletion:(BlindsSingleView*)singleView
{
    int row  = (int)(singleView.tag-100000)%100;//第几列
    int line = (int)(singleView.tag-100000)/100;//第几行
    if (line<totalIndex-1) {
        if (_blindsSubViewArr) {
            id obj = _blindsSubViewArr[line+1][row];
            [self _blindsSingleView:obj withPageState:PageStateUpToDown];
        }
    }else if(line==totalIndex-1&&row==totalIndex-1){
        [self _blindsSingleViewDidFinshAnimation];
    }
}
//pan下滑取消
-(void)_blindSingleUpToDownCancel:(BlindsSingleView*)singleView
{
    int row  = (int)(singleView.tag-100000)%100;//第几列
    int line = (int)(singleView.tag-100000)/100;//第几行
    if (line>0) {
        if (_blindsSubViewArr) {
            id obj = _blindsSubViewArr[line-1][row];
            [self _panBlindsViewCancelBlindsSingleView:obj withPageState:PageStateUpToDown];
        }
    }else if(row==0&&line==0){
        [self _blindsSingleViewDidFinshAnimation];
    }
}
//swipe上滑
-(void)_blindSingleDownToUpCompletion:(BlindsSingleView*)singleView
{
    int row  = (int)(singleView.tag-100000)%100;//第几列
    int line = (int)(singleView.tag-100000)/100;//第几行
    if (line>0) {
        if (_blindsSubViewArr) {
            id obj = _blindsSubViewArr[line-1][row];
            [self _blindsSingleView:obj withPageState:PageStateDownToUp];
        }
    }else if(row==0&&line==0){
        [self _blindsSingleViewDidFinshAnimation];
    }
}
//pan上滑取消
-(void)_blindSingleDownToUpCancel:(BlindsSingleView*)singleView
{
    int row  = (int)(singleView.tag-100000)%100;//第几列
    int line = (int)(singleView.tag-100000)/100;//第几行
    if (line<totalIndex-1) {
        if (_blindsSubViewArr) {
            id obj = _blindsSubViewArr[line+1][row];
            [self _panBlindsViewCancelBlindsSingleView:obj withPageState:PageStateDownToUp];
        }
    }else if(line==totalIndex-1&&row==totalIndex-1){
        [self _blindsSingleViewDidFinshAnimation];
    }
}
-(void)_blindsSingleView:(id)obj withPageState:(PageState)state
{
    if([obj isMemberOfClass:[BlindsSingleView class]]){
        BlindsSingleView *view = (BlindsSingleView*)obj;
        view.disableActions = NO;
        view.pageStateAnimationDuration = swipeActionTime/totalIndex;
        view.pageState = state;
        view.pageState = PageStateVertical;
    }
}
-(void)_blindsSingleViewDidFinshAnimation
{
    if (_animationFinish) {
        [self _swapImage];
    }
    [self blindsReloadData];
    self.blindsRollstate = BlindsRollStateNormal;
    if (self.animationDidFinish) {
        self.animationDidFinish();
    }
}
-(void)_blindsSingLeViewDidCancelAnimation
{
    [self blindsReloadData];
    self.blindsRollstate = BlindsRollStateNormal;
    if (self.animationDidCancel) {
        self.animationDidCancel();
    }
}
-(void)_swapImage
{
    UIImage *image  = aboveImage;
    self.aboveImage = underImage;
    self.underImage = image;
}

-(void)_removeBlindsSubLayer:(NSMutableArray*)subLayerArr
{
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
}
-(void)_addBlindsSubLayer:(NSMutableArray*)subLayerArr
{
    for (id subArr in subLayerArr) {
        for (id subView in subArr) {
            if ([subView isMemberOfClass:[BlindsSingleView class]]) {
                [self addSubview:subView];
            }
        }
    }
}
-(void)_upDateBlindsSubViewArr
{
    if (self.underImage&&self.aboveImage) {
        self.blindsSubViewArr = [self _creatViewWithAboveImageArr:_aboveImageArr withUnderImageArr:_underImageArr withArrNumber:totalIndex];
    }
}

-(CGFloat)_calculateDegress:(CGFloat)total withCurrent:(CGFloat)current
{
    //计算单位长度
    CGFloat a = total/totalIndex;
    //算出是第几列
    int     b =(int)(current/a);
    CGFloat c = current-a*b;
    return (CGFloat)c/a;
}
-(int)_calculateNumberOfTheSubViewToMove:(CGFloat)total withCurrent:(CGFloat)current
{
    CGFloat a = total/totalIndex;
    int     b = current/a;
    return b;
}

-(void)_blindsViewMoveWith:(id)obj andState:(BlindsRollState)state andDegress:(CGFloat)degress
{
    if ([obj isMemberOfClass:[BlindsSingleView class]]) {
        BlindsSingleView *view = (BlindsSingleView*)obj;
        switch (state) {
            case BlindsRollStateLeftToRight:{
                view.pageState = PageStateLeftToRight;
                [view fromLeftToRight:degress];
                break;
            }
            case BlindsRollStateRightToLeft:{
                view.pageState = PageStateRightToLeft;
                [view fromRightToLeft:degress];
                break;
            }
            case BlindsRollStateDownToUp:{
                view.pageState = PageStateDownToUp;
                [view fromDownToUp:degress];
                break;
            }
            case BlindsRollStateUpToDown:{
                view.pageState = PageStateUpToDown;
                [view fromUpToDown:degress];
                break;
            }
            default:
                break;
        }
    }
}
/**************************************保证前一个子视图的动画完成或取消*******************************************/
-(void)_panBlindsViewCompleteSubView:(id)completeView
                    andCancelSubView:(id)cancelView
                       withPageState:(PageState)state
             withCurrentSubViewIndex:(int)number
{
    if (_lastNumber<number&&number>0) {
        [self _panBlindsViewCompleteBlindsSingleView:completeView withPageState:state];
    }else if (_lastNumber>number&&number<=totalIndex-2){
        [self _panBlindsViewCancelBlindsSingleView:cancelView withPageState:state];
    }
}


/*****************************************单页完成或取消动画**************************************/
-(void)_panBlindsViewCompleteBlindsSingleView:(id)obj
                                withPageState:(PageState)state
{
    [self _panBlindsViewWithBlindsSingleView:obj withPageState:state withToPageState:PageStateVertical];
}
-(void)_panBlindsViewCancelBlindsSingleView:(id)obj withPageState:(PageState)state
{
    [self _panBlindsViewWithBlindsSingleView:obj withPageState:state withToPageState:PageStateNormal];
}
-(void)_panBlindsViewWithBlindsSingleView:(id)obj withPageState:(PageState)state withToPageState:(PageState)targetState
{
    if([obj isMemberOfClass:[BlindsSingleView class]]){
        BlindsSingleView *view = (BlindsSingleView*)obj;
        if (view.pageState != targetState) {
            view.pageStateAnimationDuration = 0.025f;
            view.pageState = state;
            view.disableActions =NO;
            view.pageState = targetState;
        }
    }
}
/*******************************************************************************************/

@end
