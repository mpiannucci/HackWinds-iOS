//
//  BuoyDataContainer.m
//  HackWinds
//
//  Created by Matthew Iannucci on 8/23/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import "BuoyDataContainer.h"
#import "BuoyModel.h"

// Local constants
static NSString * const BASE_WAVE_DATA_URL = @"https://mpitester-13.appspot.com/api/station/%@/data/latest/spectra";
static NSString * const BASE_LATEST_DATA_URL = @"https://mpitester-13.appspot.com/api/station/%@/data/latest";
static NSString * const BASE_WAVE_ENERGY_PLOT_URL = @"https://mpitester-13.appspot.com/api/station/%@/plot/%@";

@implementation BuoyDataContainer

-(id)init {
    self = [super init];
    
    self.buoyData = nil;
    
    // Default the update interval to 60 minutes
    self.updateInterval = 60;
    
    return self;
}

- (NSURL*) getLatestWaveDataURL {
    return [NSURL URLWithString:[NSString stringWithFormat:BASE_WAVE_DATA_URL, self.buoyID]];
}

- (NSURL*) getLatestSummaryURL {
    return [NSURL URLWithString:[NSString stringWithFormat:BASE_LATEST_DATA_URL, self.buoyID]];
}

- (NSURL*) getWaveEnergyPlotURL {
    return [NSURL URLWithString:[NSString stringWithFormat:BASE_WAVE_ENERGY_PLOT_URL, self.buoyID, @"energy"]];
}

- (NSURL*) getWaveDirectionalPlotURL {
    return [NSURL URLWithString:[NSString stringWithFormat:BASE_WAVE_ENERGY_PLOT_URL, self.buoyID, @"direction"]];
}

- (void) resetData {
    self.buoyData = nil;
}

@end
