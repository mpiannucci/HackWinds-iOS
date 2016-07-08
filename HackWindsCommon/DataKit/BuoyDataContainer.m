//
//  BuoyDataContainer.m
//  HackWinds
//
//  Created by Matthew Iannucci on 8/23/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import "BuoyDataContainer.h"
#import "BuoyModel.h"

// Global constant
const int BUOY_DATA_POINTS = 20;

// Local constants
static NSString * const BASE_DATA_URL = @"http://www.ndbc.noaa.gov/data/realtime2/%@%@";
static NSString * const BASE_SPECTRA_PLOT_URL = @"http://www.ndbc.noaa.gov/spec_plot.php?station=%@";
static NSString * const BASE_LATEST_DATA_URL = @"http://www.ndbc.noaa.gov/data/latest_obs/%@.txt";
static NSString * const BUOY_DETAIL_SUFFIX = @".spec";

@implementation BuoyDataContainer

-(id)init {
    self = [super init];
    
    self.buoyData = [NSMutableArray arrayWithCapacity:BUOY_DATA_POINTS];
    
    return self;
}

- (NSURL*) createDetailedWaveDataURL {
    return [NSURL URLWithString:[NSString stringWithFormat:BASE_DATA_URL, self.buoyID, BUOY_DETAIL_SUFFIX]];
}

- (NSURL*) createLatestReportOnlyURL {
    return [NSURL URLWithString:[NSString stringWithFormat:BASE_LATEST_DATA_URL, self.buoyID]];
}

- (NSURL*) createSpectraPlotURL {
    return [NSURL URLWithString:[NSString stringWithFormat:BASE_SPECTRA_PLOT_URL, self.buoyID]];
}

@end
