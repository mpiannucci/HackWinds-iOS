//
//  BuoyDataContainer.m
//  HackWinds
//
//  Created by Matthew Iannucci on 8/23/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

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

@end
