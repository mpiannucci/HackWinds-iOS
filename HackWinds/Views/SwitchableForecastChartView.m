//
//  SwitchableChartView.m
//  HackWinds
//
//  Created by Matthew Iannucci on 11/6/17.
//  Copyright © 2017 Rhodysurf Development. All rights reserved.
//

#import "SwitchableForecastChartView.h"
#import "AsyncImageView.h"
#import "UIImage+Crop.h"
#import <HackWindsDataKit/HackWindsDataKit.h>

// Constants
static NSString * const BASE_WW_CHART_URL = @"http://polar.ncep.noaa.gov/waves/WEB/multi_1.latest_run/plots/US_eastcoast.%@.%@%03dh.png";
static NSString * const PAST_HOUR_PREFIX = @"h";
static NSString * const FUTURE_HOUR_PREFIX = @"f";
static const int WAVE_HEIGHT_CHART = 0;
static const int SWELL_PERIOD_CHART = 1;
static const int WIND_CHART = 2;
static const int WW_HOUR_STEP = 3;

@interface SwitchableForecastChartView()

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *chartModeSegmentButton;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIImageView *chartImageView;

@property (strong, nonatomic) NSMutableArray *animationImages;

- (void) initView;
- (void)sendChartImageAnimationWithType:(int)chartType forIndex:(int)index;
- (void) imageLoadFailure:(id)sender;
- (void)imageLoadSuccess:(id)sender;

@end

@implementation SwitchableForecastChartView {
    BOOL needsReload[3];
}

- (id) init {
    self = [super init];
    self.dayIndex = 0;
    self.conditonCount = 0;
    [self initView];
    return self;
}

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.dayIndex = 0;
    self.conditonCount = 0;
    [self initView];
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    self.dayIndex = 0;
    self.conditonCount = 0;
    [self initView];
    return self;
}

- (id) initWithDayIndex:(NSInteger)index conditionCount:(NSInteger)count {
    self = [super init];
    self.dayIndex = index;
    self.conditonCount = count;
    [self initView];
    return self;
}

- (void) initView {
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"SwitchableForecastChartView" owner:self options:nil] objectAtIndex:0];
    [self addSubview:view];
    [view setFrame:self.bounds];
    
    // Initialize the aniimation image array
    self.animationImages = [[NSMutableArray alloc] init];
    
    // Setup the segment titles cuz of the weird storyboard bug
    [self.chartModeSegmentButton setTitle:@"Waves" forSegmentAtIndex:0];
}

- (void) initialize {
    // Hide the play button
    [self.playButton setHidden:YES];
    
    // Reset the reload flag
    for (int i = 0; i < 3; i++) {
        needsReload[i] = YES;
    }
    
     [self sendChartImageAnimationWithType:(int)[self.chartModeSegmentButton selectedSegmentIndex] forIndex:0];
}

- (void) cleanup {
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:self];
    [self.chartImageView stopAnimating];
}

#pragma mark - Button callbacks

- (IBAction)chartModeChanged:(id)sender {
    // Clear out the old animation images
    // Reset the image buttons and animation
    [self.playButton setHidden:YES];
    [self.chartImageView stopAnimating];
    
    // Reset the progress bar
    [self.progressView setHidden:NO];
    [self.progressView setProgress:0.0f animated:YES];
    
    // Reset the animation images and start lolading the new ones
    self.animationImages = [[NSMutableArray alloc] init];
    [self sendChartImageAnimationWithType:(int)[sender selectedSegmentIndex] forIndex:0];
}

- (IBAction)playButtonClicked:(id)sender {
    [self.chartImageView startAnimating];
    [self.playButton setHidden:YES];
    [self.pauseButton setHidden:NO];
}

- (IBAction)pauseButtonClicked:(id)sender {
    [self.chartImageView stopAnimating];
    [self.pauseButton setHidden:YES];
    [self.playButton setHidden:NO];
}

#pragma mark - AsyncImageView handlers

- (void) imageLoadFailure:(id)sender {
    [self.chartImageView setImage:[UIImage imageNamed:@"ErrorLoading"]];
    [self.progressView setHidden:YES];
}

- (void)imageLoadSuccess:(id)sender {
    
    // Crop the image
    UIImage *croppedChart = [sender crop:CGRectMake(60, 0, 400, 300)];
    
    // Add the cropped image to the array for animation
    [self.animationImages addObject:croppedChart];
    
    if (needsReload[self.chartModeSegmentButton.selectedSegmentIndex]) {
        [self.progressView setProgress:self.animationImages.count/6.0f animated:YES];
    }
    
    if ([self.animationImages count] < 2) {
        // If its the first image set it to the header as a holder
        [self.chartImageView setImage:croppedChart];
    } else if ([self.animationImages count] == self.conditonCount) {
        // We have all of the images so animate!!!
        [self.chartImageView setAnimationImages:self.animationImages];
        [self.chartImageView setAnimationDuration:5];
        
        // Okay so this is really hacky... For some reasons the images are not loaded correctly on the first
        // pass through each of the views.
        if (needsReload[self.chartModeSegmentButton.selectedSegmentIndex]) {
            self.animationImages = [[NSMutableArray alloc] init];
            needsReload[self.chartModeSegmentButton.selectedSegmentIndex] = NO;
        } else {
            // Show the play button, Hide the stop Button
            [self.pauseButton setHidden:YES];
            [self.playButton setHidden:NO];
            
            // Hide the progress bar becasue its loaded
            [self.progressView setHidden:YES];
        }
    }
    if (self.animationImages.count < self.conditonCount) {
        // If the animation array isnt full, get the next image on the stack
        [self sendChartImageAnimationWithType:(int)self.chartModeSegmentButton.selectedSegmentIndex
                                     forIndex:(int)self.animationImages.count];
    }
}

- (void)sendChartImageAnimationWithType:(int)chartType forIndex:(int)index {
    NSString *timePrefix = FUTURE_HOUR_PREFIX;
    if ((self.dayIndex == 0) && (index == 0)) {
        timePrefix = PAST_HOUR_PREFIX;
    }
    
    int hour = WW_HOUR_STEP * ([[ForecastModel sharedModel] getDayForecastStartingIndex:(int)self.dayIndex] + index);
    NSURL *wwChartURL = [NSURL URLWithString:[NSString stringWithFormat:BASE_WW_CHART_URL, [self getChartURLPrefixForType:chartType], timePrefix, hour]];
    [[AsyncImageLoader sharedLoader] loadImageWithURL:wwChartURL target:self success:@selector(imageLoadSuccess:) failure:@selector(imageLoadFailure:)];
}

- (NSString*) getChartURLPrefixForType:(int)chartType {
    switch (chartType) {
        case WAVE_HEIGHT_CHART:
            return @"hs";
        case SWELL_PERIOD_CHART:
            return @"tp_sw1";
        case WIND_CHART:
            return @"u10";
        default:
            return @"";
    }
}

@end
