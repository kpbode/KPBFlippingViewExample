#import <UIKit/UIKit.h>

@interface KPBTwosidedView : UIView

- (void)flipWithCompletion:(void (^)(void))completion;
- (void)flipWithDelay:(NSTimeInterval)delay completion:(void (^)(void))completion;

- (void)flipBackWithDelay:(NSTimeInterval)delay completion:(void (^)(void))completion;
- (void)flipBackWithCompletion:(void (^)(void))completion;

@end
