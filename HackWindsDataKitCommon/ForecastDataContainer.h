//
//  ForecastDataContainer.h
//  HackWinds
//
//  Created by Matthew Iannucci on 8/31/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//
#define CONDITION_DATA_POINT_COUNT 30
#define FORECAST_DATA_POINT_COUNT 10

#import <Foundation/Foundation.h>

@interface ForecastDataContainer : NSObject

@property (strong, nonatomic) NSNumber *forecastID;
@property (strong, nonatomic) NSMutableArray *conditions;
@property (strong, nonatomic) NSMutableArray *forecasts;

@end
