
//
//  ForecastModel.h
//  HackWinds
//
//  Created by Matthew Iannucci on 12/14/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//
#import <Foundation/Foundation.h>

// Notification Constants
extern NSString * const FORECAST_DATA_UPDATED_TAG;
extern NSString * const FORECAST_DATA_UPDATE_FAILED_TAG;

// Data constants
extern const int FORECAST_DATA_POINT_COUNT;

@interface ForecastModel : NSObject

@property (strong, nonatomic) NSString *locationName;
@property (strong, nonatomic) NSString *waveModelName;
@property (strong, nonatomic) NSString *waveModelRun;
@property (strong, nonatomic) NSString *windModelName;
@property (strong, nonatomic) NSString *windModelRun;
@property (strong, nonatomic) NSMutableArray *forecasts;
@property (strong, nonatomic) NSMutableArray *dailyForecasts;

- (void) fetchForecastData;
- (int) getDayCount;
- (int) getDayForecastStartingIndex:(int)day;
- (NSArray *) getForecastsForDay:(int)day;
+ (instancetype) sharedModel;

@end
