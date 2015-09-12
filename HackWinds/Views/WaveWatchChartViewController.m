//
//  WaveWatchChartViewController.m
//  HackWinds
//
//  Created by Matthew Iannucci on 9/10/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//
#define BASE_WW_CHART_URL @"http://polar.ncep.noaa.gov/waves/WEB/multi_1.latest_run/plots/US_eastcoast.hs.%@%03dh.png"
#define PAST_HOUR_PREFIX @"h"
#define FUTURE_HOUR_PREFIX @"f"

#import "WaveWatchChartViewController.h"
#import "AsyncImageView.h"

@interface WaveWatchChartViewController()

@property (weak, nonatomic) IBOutlet UIImageView *chartImageView;
@property (weak, nonatomic) IBOutlet UIButton *chartPlayButton;
@property (weak, nonatomic) IBOutlet UIButton *chartPauseButton;
@property (weak, nonatomic) IBOutlet UIProgressView *chartProgressBar;

// View specifics
@property (strong, nonatomic) NSMutableArray *animationImages;

@end

@implementation WaveWatchChartViewController {
    BOOL needsReload;
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
    
    needsReload = YES;
    
    [self sendChartImageAnimationLoadForIndex:0];
}

- (void) viewWillDisappear:(BOOL)animated {
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:self];
    [self.chartImageView stopAnimating];
    
    [super viewWillDisappear:animated];
}

- (void)sendChartImageAnimationLoadForIndex:(int)index {
    NSString *chartPrefix;
    if (index == 0) {
        chartPrefix = PAST_HOUR_PREFIX;
    } else {
        chartPrefix = FUTURE_HOUR_PREFIX;
    }
    
    NSURL *nextURL = [NSURL URLWithString:[NSString stringWithFormat:BASE_WW_CHART_URL, chartPrefix, index * 3]];
    [[AsyncImageLoader sharedLoader] loadImageWithURL:nextURL
                                               target:self
                                               action:@selector(imageLoadSuccess:)];
}

- (void) imageLoadSuccess:(id)sender {
    // Add the image to the array for animation
    [self.animationImages addObject:sender];
    
    if (needsReload) {
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
        if (needsReload) {
            self.animationImages = [[NSMutableArray alloc] init];
            needsReload = NO;
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
        [self sendChartImageAnimationLoadForIndex:(int)self.animationImages.count];
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

@end
