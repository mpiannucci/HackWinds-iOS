//
//  ForecastDataContainer.m
//  HackWinds
//
//  Created by Matthew Iannucci on 8/31/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import "ForecastDataContainer.h"

const int CONDITION_DATA_POINT_COUNT = 30;
const int FORECAST_DATA_POINT_COUNT = 10;

@implementation ForecastDataContainer

- (id) init {
    self = [super init];
    
    self.conditions = [NSMutableArray arrayWithCapacity:CONDITION_DATA_POINT_COUNT];
    self.forecasts = [NSMutableArray arrayWithCapacity:FORECAST_DATA_POINT_COUNT];
    
    return self;
}

@end
