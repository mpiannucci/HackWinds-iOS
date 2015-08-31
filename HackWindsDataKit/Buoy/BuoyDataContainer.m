//
//  BuoyDataContainer.m
//  HackWinds
//
//  Created by Matthew Iannucci on 8/23/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import "BuoyDataContainer.h"

@implementation BuoyDataContainer

-(id)init {
    self = [super init];
    
    self.buoyData = [NSMutableArray arrayWithCapacity:BUOY_DATA_POINTS];
    self.waveHeights = [NSMutableArray arrayWithCapacity:BUOY_DATA_POINTS];
    self.swellWaveHeights = [NSMutableArray arrayWithCapacity:BUOY_DATA_POINTS];
    self.windWaveHeights = [NSMutableArray arrayWithCapacity:BUOY_DATA_POINTS];
    
    return self;
}

@end
