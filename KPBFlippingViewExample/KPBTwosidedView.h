#import <UIKit/UIKit.h>

@interface KPBTwosidedView : UIView

- (void)flipWithCompletion:(void (^)(void))completion;
- (void)flipBackWithCompletion:(void (^)(void))completion;

@end
