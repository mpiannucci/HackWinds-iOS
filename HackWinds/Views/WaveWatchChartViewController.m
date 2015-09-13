//
//  WaveWatchChartViewController.m
//  HackWinds
//
//  Created by Matthew Iannucci on 9/10/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//
#define BASE_WW_CHART_URL @"http://polar.ncep.noaa.gov/waves/WEB/multi_1.latest_run/plots/US_eastcoast.%@.%@%03dh.png"
#define PAST_HOUR_PREFIX @"h"
#define FUTURE_HOUR_PREFIX @"f"
#define WW_WAVE_HEIGHT_CHART 0
#define WW_SWELL_HEIGHT_CHART 1
#define WW_SWELL_PERIOD_CHART 2
#define WW_WIND_CHART 3

#import "WaveWatchChartViewController.h"
#import "AsyncImageView.h"

@interface WaveWatchChartViewController()

@property (weak, nonatomic) IBOutlet UIImageView *chartImageView;
@property (weak, nonatomic) IBOutlet UIButton *chartPlayButton;
@property (weak, nonatomic) IBOutlet UIButton *chartPauseButton;
@property (weak, nonatomic) IBOutlet UIProgressView *chartProgressBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *chartTypeSegmentControl;
@property (weak, nonatomic) IBOutlet UISwitch *manualControlSwitch;
@property (weak, nonatomic) IBOutlet UIButton *nextChartImageButton;
@property (weak, nonatomic) IBOutlet UIButton *previousChartImageButton;
@property (weak, nonatomic) IBOutlet UITextField *currentDisplayedHourEdit;

// View specifics
@property (strong, nonatomic) NSMutableArray *animationImages;

@end

@implementation WaveWatchChartViewController {
    BOOL needsReload[3];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Initialize the aniimation image array
    self.animationImages = [[NSMutableArray alloc] init];
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.chartPauseButton setHidden:YES];
    [self.chartPlayButton setHidden:YES];
    
    // Reset the reload flag
    for (int i = 0; i < 3; i++) {
        needsReload[i] = YES;
    }
    
    [self sendChartImageAnimationLoadForType:WW_WAVE_HEIGHT_CHART forIndex:0];
}

- (void) viewWillDisappear:(BOOL)animated {
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:self];
    [self.chartImageView stopAnimating];
    
    [super viewWillDisappear:animated];
}

- (void)sendChartImageAnimationLoadForType:(int)chartType forIndex:(int)index {
    NSString *chartTimePrefix;
    if (index == 0) {
        chartTimePrefix = PAST_HOUR_PREFIX;
    } else {
        chartTimePrefix = FUTURE_HOUR_PREFIX;
    }
    
    // Get the correct prefix so we can craft the correct url
    NSString *chartTypePrefix = [self getChartURLPrefixForType:chartType];
    
    // Create the full url and send out the image load request
    NSURL *nextURL = [NSURL URLWithString:[NSString stringWithFormat:BASE_WW_CHART_URL, chartTypePrefix, chartTimePrefix, index * 3]];
    [[AsyncImageLoader sharedLoader] loadImageWithURL:nextURL
                                               target:self
                                               action:@selector(imageLoadSuccess:)];
}

- (void) imageLoadSuccess:(id)sender {
    // Add the image to the array for animation
    [self.animationImages addObject:sender];
    
    if (needsReload[self.chartTypeSegmentControl.selectedSegmentIndex]) {
        // TODO: Set the correct percentages here, this was the one from the detailed forecast view
        [self.chartProgressBar setProgress:self.animationImages.count/12.0f animated:YES];
    }
    
    if ([self.animationImages count] < 2) {
        // If its the first image set it to the header as a holder
        [self.chartImageView setImage:sender];
    } else if ([self.animationImages count] == 56) {
        // We have all of the images so animate!!!
        [self.chartImageView setAnimationImages:self.animationImages];
        [self.chartImageView setAnimationDuration:20];
        
        // Okay so this is really hacky... For some reasons the images are not loaded correctly on the first
        // pass through each of the views.
        if (needsReload[self.chartTypeSegmentControl.selectedSegmentIndex])  {
            self.animationImages = [[NSMutableArray alloc] init];
            needsReload[self.chartTypeSegmentControl.selectedSegmentIndex] = NO;
        } else {
            // Show the play button, Hide the stop Button
            [self.chartPauseButton setHidden:YES];
            [self.chartPlayButton setHidden:NO];
            
            // Hide the progress bar becasue its loaded
            [self.chartProgressBar setHidden:YES];
        }
    }
    if (self.animationImages.count < 56) {
        // If the animation array isnt full, get the next image on the stack
        [self sendChartImageAnimationLoadForType:(int)[self.chartTypeSegmentControl selectedSegmentIndex]
                                        forIndex:(int)self.animationImages.count];
    }
}

- (NSString*) getChartURLPrefixForType:(int)chartType {
    switch (chartType) {
        case WW_WAVE_HEIGHT_CHART:
            return @"hs";
        case WW_SWELL_HEIGHT_CHART:
            return @"hs_sw1";
        case WW_SWELL_PERIOD_CHART:
            return @"tp_sw1";
        case WW_WIND_CHART:
            return @"u10";
        default:
            return @"";
    }
}

- (IBAction) chartPauseButtonClicked:(id)sender {
    [self.chartImageView stopAnimating];
    [self.chartPauseButton setHidden:YES];
    [self.chartPlayButton setHidden:NO];
}

- (IBAction) chartPlayButtonClicked:(id)sender {
    [self.chartImageView startAnimating];
    [self.chartPlayButton setHidden:YES];
    [self.chartPauseButton setHidden:NO];
}

- (IBAction) closeButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)chartTypeValueChanged:(id)sender {
    [self.chartPlayButton setHidden:YES];
    [self.chartImageView stopAnimating];
    
    // Reset the progress bar
    [self.chartProgressBar setHidden:NO];
    [self.chartProgressBar setProgress:0.0f animated:YES];
    
    // Reset the animation images and start lolading the new ones
    self.animationImages = [[NSMutableArray alloc] init];
    [self sendChartImageAnimationLoadForType:(int)[sender selectedSegmentIndex] forIndex:0];
}

- (IBAction)manualControlSwitchChanged:(id)sender {
}

- (IBAction)nextChartImageButtonClicked:(id)sender {
}

- (IBAction)previousChartImageButtonClicked:(id)sender {
}

- (IBAction)displayedHourEdited:(id)sender {
}

@end
