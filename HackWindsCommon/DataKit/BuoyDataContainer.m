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
static NSString * const BASE_WAVE_DATA_URL = @"https://buoyfinder.appspot.com/api/latest/wave/charts/%@";
static NSString * const BASE_LATEST_DATA_URL = @"https://buoyfinder.appspot.com/api/latest/%@";

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

- (void) resetData {
    self.buoyData = nil;
}

@end
