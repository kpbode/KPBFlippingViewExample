#import <UIKit/UIKit.h>

@interface KPBTwosidedView : UIView

@property (nonatomic, weak) UIView *frontView;
@property (nonatomic, weak) UIView *backView;

- (void)flipWithCompletion:(void (^)(void))completion;
- (void)flipWithDelay:(NSTimeInterval)delay completion:(void (^)(void))completion;

- (void)flipBackWithDelay:(NSTimeInterval)delay completion:(void (^)(void))completion;
- (void)flipBackWithCompletion:(void (^)(void))completion;

@end
