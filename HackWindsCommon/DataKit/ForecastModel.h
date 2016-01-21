
//
//  ForecastModel.h
//  HackWinds
//
//  Created by Matthew Iannucci on 12/14/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//
#import <Foundation/Foundation.h>

// Location Constants
extern NSString * const TOWN_BEACH_LOCATION;
extern NSString * const POINT_JUDITH_LOCATION;
extern NSString * const MATUNUCK_LOCATION;
extern NSString * const SECOND_BEACH_LOCATION;

// Notification Constants
extern NSString * const FORECAST_DATA_UPDATED_TAG;
extern NSString * const FORECAST_LOCATION_CHANGED_TAG;
extern NSString * const FORECAST_DATA_UPDATE_FAILED_TAG;

@interface ForecastModel : NSObject

- (void) changeForecastLocation;
- (void) fetchForecastData;
- (NSArray *) getConditionsForIndex:(int)index;
- (NSMutableArray *) getConditions;
- (NSMutableArray *) getForecasts;
+ (instancetype) sharedModel;

@end
