#import "NavigationBarTitleWithSubtitleView.h"

@interface NavigationBarTitleWithSubtitleView()

@end

@implementation NavigationBarTitleWithSubtitleView

@synthesize titleLabel;
@synthesize detailButton;

- (id) init
{
    self = [super initWithFrame:CGRectMake(0, 0, 200, 44)];
    if (self) {
        [self setBackgroundColor: [UIColor clearColor]];
        [self setAutoresizesSubviews:YES];
        
        CGRect titleFrame = CGRectMake(0, 2, 200, 24);
        titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:16];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.text = @"";
        titleLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:titleLabel];
        
        CGRect detailFrame = CGRectMake(0, 24, 200, 44-24);
        detailButton = [[UIButton alloc] initWithFrame:detailFrame];
        detailButton.backgroundColor = [UIColor clearColor];
        detailButton.titleLabel.font = [UIFont systemFontOfSize:10];
        detailButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [detailButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [detailButton setTitle:@"" forState:UIControlStateNormal];
        detailButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        
        [self addSubview:detailButton];
        
        [self setAutoresizingMask : (UIViewAutoresizingFlexibleLeftMargin |
                                     UIViewAutoresizingFlexibleRightMargin |
                                     UIViewAutoresizingFlexibleTopMargin |
                                     UIViewAutoresizingFlexibleBottomMargin)];
    }
    return self;
}

- (void) setTitleText: (NSString *) aTitleText
{
    [self.titleLabel setText:aTitleText];
}

- (void) setDetailText: (NSString *) aDetailText
{  
    [self.detailButton setTitle:aDetailText forState:UIControlStateNormal];
}  

@end