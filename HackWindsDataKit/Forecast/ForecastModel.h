
//
//  ForecastModel.h
//  HackWinds
//
//  Created by Matthew Iannucci on 12/14/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//
#define TOWN_BEACH_LOCATION @"Narragansett Town Beach"
#define POINT_JUDITH_LOCATION @"Point Judith Lighthouse"
#define MATUNUCK_LOCATION @"Matunuck"
#define SECOND_BEACH_LOCATION @"Second Beach"

#import <Foundation/Foundation.h>

@interface ForecastModel : NSObject

- (void) changeForecastLocation;
- (BOOL) fetchForecastData;
- (NSArray *) getConditionsForIndex:(int)index;
- (NSMutableArray *) getConditions;
- (NSMutableArray *) getForecasts;
+ (instancetype) sharedModel;

@end
