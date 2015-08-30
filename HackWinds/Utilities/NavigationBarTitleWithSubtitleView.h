#import <UIKit/UIKit.h>

@interface NavigationBarTitleWithSubtitleView : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *detailButton;

- (void) setTitleText: (NSString *) aTitleText;
- (void) setDetailText: (NSString *) aDetailText;

@end
