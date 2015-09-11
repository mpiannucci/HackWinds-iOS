//
//  WaveWatchChartViewController.m
//  HackWinds
//
//  Created by Matthew Iannucci on 9/10/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//
#define BASE_WW_CHART_URL @"http://polar.ncep.noaa.gov/waves/WEB/multi_1.latest_run/plots/US_eastcoast.hs.%@%dh.png"
#define PAST_HOUR_PREFIX @"h"
#define FUTURE_HOUR_PREFIX @"f"

#import "WaveWatchChartViewController.h"

@interface WaveWatchChartViewController()

@property (weak, nonatomic) IBOutlet UIImageView *chartImageView;
@property (weak, nonatomic) IBOutlet UIButton *chartPlayButton;
@property (weak, nonatomic) IBOutlet UIButton *chartPauseButton;
@property (weak, nonatomic) IBOutlet UIProgressView *chartProgressBar;

@end

@implementation WaveWatchChartViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // TODO: Everything
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (IBAction)chartPauseButtonClicked:(id)sender {
}

- (IBAction)chartPlayButtonClicked:(id)sender {
}

- (IBAction)closeButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
