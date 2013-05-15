#import "KPBSampleViewController.h"
#import "KPBTwosidedView.h"

@interface KPBSampleViewController ()

@property (nonatomic, weak) KPBTwosidedView *targetView;
@property (nonatomic, assign) BOOL viewFlipped;

@end

@implementation KPBSampleViewController

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.viewFlipped = NO;
    }
    return self;
}

- (void)loadView
{
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectZero];
    
    KPBTwosidedView *targetView = [[KPBTwosidedView alloc] initWithFrame:CGRectMake(40.f, 240.f, 240.f, 360.f)];
    
    [containerView addSubview:targetView];
    self.targetView = targetView;
    
    UIView *coverView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 500.f, 320.f, 228.f)];
    coverView.backgroundColor = [UIColor whiteColor];
    coverView.layer.shadowColor = [[UIColor blackColor] CGColor];
    coverView.layer.shadowOffset = CGSizeMake(0.f, -1.f);
    coverView.layer.shadowRadius = 3.f;
    coverView.layer.shadowOpacity = .3f;
    [containerView addSubview:coverView];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [containerView addGestureRecognizer:tapGestureRecognizer];
    
    self.view = containerView;
}

- (void)onTap:(id)sender
{
    CGPoint newCenter = _targetView.center;
    
    if (!_viewFlipped)
    {
        newCenter.y -= 200.f;
        
        [UIView animateWithDuration:.2 animations:^{
            _targetView.center = newCenter;
        } completion:^(BOOL finished) {
            [_targetView flipWithCompletion:^{
                self.viewFlipped = YES;
            }];            
        }];
    }
    else
    {
        newCenter.y += 200.f;
        
        [_targetView flipBackWithCompletion:^{
            [UIView animateWithDuration:.2 animations:^{
                _targetView.center = newCenter;
            } completion:^(BOOL finished) {
                self.viewFlipped = NO;
            }];
        }];
        
        
    }
    
}

@end
