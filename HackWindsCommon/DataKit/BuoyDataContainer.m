//
//  BuoyDataContainer.m
//  HackWinds
//
//  Created by Matthew Iannucci on 8/23/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//
#define BASE_DATA_URL @"http://www.ndbc.noaa.gov/data/realtime2/%@%@"
#define BASE_SPECTRA_PLOT_URL @"http://www.ndbc.noaa.gov/spec_plot.php?station=%@"
#define BASE_LATEST_DATA_URL @"http://www.ndbc.noaa.gov/get_observation_as_xml.php?station=%@"
#define BUOY_SUMMARY_SUFFIX @".txt"
#define BUOY_DETAIL_SUFFIX @".spec"

#import "BuoyDataContainer.h"
#import "BuoyModel.h"

@implementation BuoyDataContainer

-(id)init {
    self = [super init];
    
    self.buoyData = [NSMutableArray arrayWithCapacity:BUOY_DATA_POINTS];
    NSMutableArray *sigWaveHeights = [NSMutableArray arrayWithCapacity:BUOY_DATA_POINTS];
    NSMutableArray *swellWaveHeights = [NSMutableArray arrayWithCapacity:BUOY_DATA_POINTS];
    NSMutableArray *windWaveHeights = [NSMutableArray arrayWithCapacity:BUOY_DATA_POINTS];
    
    self.waveHeights = [[NSMutableDictionary alloc] initWithCapacity:3];
    [self.waveHeights setObject:sigWaveHeights forKey:SUMMARY_DATA_MODE];
    [self.waveHeights setObject:swellWaveHeights forKey:SWELL_DATA_MODE];
    [self.waveHeights setObject:windWaveHeights forKey:WIND_DATA_MODE];
    
    return self;
}

- (NSURL*) createStandardMeteorologicalDataURL {
    return [NSURL URLWithString:[NSString stringWithFormat:BASE_DATA_URL, self.buoyID, BUOY_SUMMARY_SUFFIX]];
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
