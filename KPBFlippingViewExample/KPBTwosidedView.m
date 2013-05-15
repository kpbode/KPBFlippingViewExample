#import "KPBTwosidedView.h"

@interface KPBTwosidedView ()

@property (nonatomic, weak) UIView *frontView;
@property (nonatomic, weak) UIView *backView;
@property (nonatomic, copy) void (^flipCompletionBlock)();

@end

@implementation KPBTwosidedView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
        UILabel *frontView = [[UILabel alloc] initWithFrame:self.bounds];
        frontView.layer.doubleSided = NO;
        frontView.layer.cornerRadius = 20.f;
        frontView.backgroundColor = [UIColor greenColor];
        frontView.text = @"Front";
        frontView.textAlignment = NSTextAlignmentCenter;
        frontView.textColor = [UIColor blackColor];
        frontView.font = [UIFont fontWithName:@"HelveticaNeue" size:24.f];
        
        [self addSubview:frontView];
        self.frontView = frontView;
        
        UILabel *backView = [[UILabel alloc] initWithFrame:self.bounds];
        backView.layer.doubleSided = NO;
        backView.layer.cornerRadius = 20.f;
        backView.layer.transform = CATransform3DMakeRotation(M_PI, 0.f, 1.f, 0.f);
        backView.backgroundColor = [UIColor redColor];
        backView.text = @"Back";
        backView.textAlignment = NSTextAlignmentCenter;
        backView.textColor = [UIColor blackColor];
        backView.font = [UIFont fontWithName:@"HelveticaNeue" size:24.f];
        
        [self addSubview:backView];
        self.backView = backView;
        
    }
    return self;
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
    
    _frontView.layer.transform = [[frontViewAnimation.values lastObject] CATransform3DValue];
    _backView.layer.transform = [[backViewAnimation.values lastObject] CATransform3DValue];
    
    [_frontView.layer addAnimation:frontViewAnimation forKey:kCATransition];
    [_backView.layer addAnimation:backViewAnimation forKey:kCATransition];
    
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
    
    [self.layer addAnimation:scaleAnimation forKey:@"cameraAnimation"];
}

- (void)flipWithCompletion:(void (^)(void))completion
{
    [self performFlipWithFrontViewAnimationValues:[self flipFrontViewAnimationValues]
                          backViewAnimationValues:[self flipBackViewAnimationValues]
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
    [self performFlipWithFrontViewAnimationValues:[self flipBackFrontViewAnimationValues]
                          backViewAnimationValues:[self flipBackBackViewAnimationValues]
                                  completionBlock:completion];
}


@end
