#import "KPBTwosidedView.h"

@interface KPBTwosidedView ()

@property (nonatomic, copy) void (^flipCompletionBlock)();

@end

@implementation KPBTwosidedView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
        UILabel *frontView = [[UILabel alloc] initWithFrame:self.bounds];
        frontView.backgroundColor = [UIColor greenColor];
        frontView.text = @"Front";
        frontView.textAlignment = NSTextAlignmentCenter;
        frontView.textColor = [UIColor blackColor];
        frontView.font = [UIFont fontWithName:@"HelveticaNeue" size:24.f];
        self.frontView = frontView;
        
        UILabel *backView = [[UILabel alloc] initWithFrame:self.bounds];
        backView.backgroundColor = [UIColor redColor];
        backView.text = @"Back";
        backView.textAlignment = NSTextAlignmentCenter;
        backView.textColor = [UIColor blackColor];
        backView.font = [UIFont fontWithName:@"HelveticaNeue" size:24.f];
        self.backView = backView;
        
    }
    return self;
}

- (void)setFrontView:(UIView *)frontView
{
    if (frontView == nil) return;
    if (_frontView != nil)
    {
        [_frontView removeFromSuperview];
    }
    [self prepareLayer:frontView.layer];
    [self addSubview:frontView];
    _frontView = frontView;
}

- (void)setBackView:(UIView *)backView
{
    if (backView == nil) return;
    if (_backView != nil)
    {
        [_backView removeFromSuperview];
    }
    [self prepareLayer:backView.layer];
    backView.layer.transform = CATransform3DMakeRotation(M_PI, 0.f, 1.f, 0.f);
    [self addSubview:backView];
    _backView = backView;
}

- (void)prepareLayer:(CALayer *)layer
{
    layer.doubleSided = NO;
    layer.shouldRasterize = YES;
    layer.rasterizationScale = [UIScreen mainScreen].scale;
}

- (NSValue *)transformValueWithRotation:(CGFloat)rotation
{
    return [NSValue valueWithCATransform3D:CATransform3DMakeRotation(rotation, 1.f, 0.f, 0.f)];
}

- (NSArray *)flipFrontViewAnimationValues
{
    return @[
             [self transformValueWithRotation:0.f],
             [self transformValueWithRotation:M_PI_4],
             [self transformValueWithRotation:M_PI_2],
             [self transformValueWithRotation:M_PI_2 + M_PI_4],
             [self transformValueWithRotation:M_PI]
             ];
}

- (NSArray *)flipBackViewAnimationValues
{
    return @[
             [self transformValueWithRotation:M_PI],
             [self transformValueWithRotation:M_PI + M_PI_4],
             [self transformValueWithRotation:M_PI + M_PI_2],
             [self transformValueWithRotation:M_PI + M_PI_2 + M_PI_4],
             [self transformValueWithRotation:M_PI + M_PI]
             ];
}

- (NSArray *)flipBackFrontViewAnimationValues
{
    return @[
             [self transformValueWithRotation:M_PI],
             [self transformValueWithRotation:M_PI_2 + M_PI_4],
             [self transformValueWithRotation:M_PI_2],
             [self transformValueWithRotation:M_PI_4],
             [self transformValueWithRotation:0.f]
             ];
}

- (NSArray *)flipBackBackViewAnimationValues
{
    return @[
             [self transformValueWithRotation:M_PI + M_PI],
             [self transformValueWithRotation:M_PI + M_PI_2 + M_PI_4],
             [self transformValueWithRotation:M_PI + M_PI_2],
             [self transformValueWithRotation:M_PI + M_PI_4],
             [self transformValueWithRotation:M_PI]
             ];
}

- (void)performFlipWithFrontViewAnimationValues:(NSArray *)frontViewAnimationValues
                        backViewAnimationValues:(NSArray *)backViewAnimationValues
                                          delay:(NSTimeInterval)delay
                                completionBlock:(void (^)(void))completionBlock
{
    self.flipCompletionBlock = completionBlock;
    
    CATransform3D perspectiveTransform = CATransform3DIdentity;
    perspectiveTransform.m34 = -1.0f / 1000.f;
    self.layer.sublayerTransform = perspectiveTransform;
    
    CFTimeInterval animationDuration = 0.3;
    
    CAKeyframeAnimation *frontViewAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    frontViewAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    frontViewAnimation.removedOnCompletion = YES;
    frontViewAnimation.duration = animationDuration;
    frontViewAnimation.delegate = self;
    frontViewAnimation.values = frontViewAnimationValues;
    
    CAKeyframeAnimation *backViewAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    backViewAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    backViewAnimation.removedOnCompletion = YES;
    backViewAnimation.duration = animationDuration;
    backViewAnimation.delegate = self;
    backViewAnimation.values = backViewAnimationValues;
    
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    scaleAnimation.removedOnCompletion = YES;
    scaleAnimation.duration = animationDuration;
    
    CGFloat scaleFactor = .9f;
    
    scaleAnimation.values = @[
                              [NSValue valueWithCATransform3D:CATransform3DIdentity],
                              [NSValue valueWithCATransform3D:CATransform3DMakeScale(scaleFactor, scaleFactor, scaleFactor)],
                              [NSValue valueWithCATransform3D:CATransform3DIdentity],
                              ];
    
    // fire animations
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        _frontView.layer.transform = [[frontViewAnimation.values lastObject] CATransform3DValue];
        _backView.layer.transform = [[backViewAnimation.values lastObject] CATransform3DValue];
        
        [_frontView.layer addAnimation:frontViewAnimation forKey:kCATransition];
        [_backView.layer addAnimation:backViewAnimation forKey:kCATransition];
        
        [self.layer addAnimation:scaleAnimation forKey:@"cameraAnimation"];
    });
    
}

- (void)flipWithCompletion:(void (^)(void))completion
{
    [self flipWithDelay:0. completion:completion];
}

- (void)flipWithDelay:(NSTimeInterval)delay completion:(void (^)(void))completion
{
    [self performFlipWithFrontViewAnimationValues:[self flipFrontViewAnimationValues]
                          backViewAnimationValues:[self flipBackViewAnimationValues]
                                            delay:delay
                                  completionBlock:completion];
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{    
    if ([_frontView.layer animationForKey:kCATransition] == nil && [_backView.layer animationForKey:kCATransition] == nil)
    {
        if (_flipCompletionBlock != nil)
        {
            _flipCompletionBlock();
            self.flipCompletionBlock = nil;
        }        
    }
}

- (void)flipBackWithCompletion:(void (^)(void))completion
{
    [self flipBackWithDelay:.0 completion:completion];
}

- (void)flipBackWithDelay:(NSTimeInterval)delay
               completion:(void (^)(void))completion
{
    [self performFlipWithFrontViewAnimationValues:[self flipBackFrontViewAnimationValues]
                          backViewAnimationValues:[self flipBackBackViewAnimationValues]
                                            delay:delay
                                  completionBlock:completion];
}


@end
