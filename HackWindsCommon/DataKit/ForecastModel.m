//
//  ForecastModel.m
//  HackWinds
//
//  Created by Matthew Iannucci on 12/14/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//
#import "ForecastModel.h"
#import "Forecast.h"

// Notification Constants
NSString * const FORECAST_DATA_UPDATED_TAG = @"ForecastModelDidUpdateDataNotification";
NSString * const FORECAST_DATA_UPDATE_FAILED_TAG = @"ForecastModelUpdateFailedNotification";

// Data count constant
const int FORECAST_DATA_POINT_COUNT = 61;

@interface ForecastModel ()

// Private methods
- (BOOL) parseForecastsFromData:(NSData*) unserializedData;
- (BOOL) check24HourClock;

@end

@implementation ForecastModel
{
    BOOL is24HourClock;
}

+ (instancetype) sharedModel {
    static ForecastModel *_sharedModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // code to be executed once - thread safe version!
        _sharedModel = [[self alloc] init];
    });
    
    return _sharedModel;
}

- (id)init
{
    self = [super init];
    
    // Check the format of the clock
    [self check24HourClock];
    
    // Set up the data container with emoty values
    self.forecasts = [[NSMutableArray alloc] initWithCapacity:FORECAST_DATA_POINT_COUNT];
    
    return self;
}

- (NSArray *) getConditionsForIndex:(int)index {
    if (self.forecasts.count == FORECAST_DATA_POINT_COUNT) {
        NSArray *conditions = [self.forecasts subarrayWithRange:NSMakeRange(index * 6, 6)];
        return conditions;
    }
    return nil;
}

- (void) fetchForecastData {
    @synchronized(self) {
        
        if (self.forecasts.count != 0) {
            // Tell any listeners that the data has been loaded.
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:FORECAST_DATA_UPDATED_TAG
                 object:self];
            });
            
            return;
        }
        
        NSURL *dataURL = [NSURL URLWithString:@"https://rhodycast.appspot.com/forecast_as_json"];
        NSURLSessionTask *urlSession = [[NSURLSession sharedSession] dataTaskWithURL:dataURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (error != nil) {
                NSLog(@"Failed to download forecast data");
                
                // Send failure notification
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:FORECAST_DATA_UPDATE_FAILED_TAG
                     object:self];
                });
                
                return;
            }
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
            if (httpResponse.statusCode != 200) {
                NSLog(@"HTTP Error receiving forecast data");
                
                // Send failure notification
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:FORECAST_DATA_UPDATE_FAILED_TAG
                     object:self];
                });
                
                return;
            }
            
            // Parse the data
            BOOL parsed = [self parseForecastsFromData:data];
            
            // Tell any listeners that the data has been loaded.
            if (parsed) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter]
                    postNotificationName:FORECAST_DATA_UPDATED_TAG
                    object:self];
                });
            }
        }];
        
        [urlSession resume];
    }
}

- (BOOL) parseForecastsFromData:(NSData *)unserializedData {
    NSError *error;
    NSDictionary *rawData = [NSJSONSerialization
               JSONObjectWithData:unserializedData
               options:kNilOptions
               error:&error];
    
    // If there's no data, return nothing
    if (rawData == nil) {
        return NO;
    }
    
    // Get the metadata about the forecast object
    self.locationName = [rawData objectForKey:@"LocationName"];
    self.waveModelName = [[rawData objectForKey:@"WaveModel"] objectForKey:@"Description"];
    self.waveModelRun = [[rawData objectForKey:@"WaveModel"] objectForKey:@"ModelRun"];
    self.windModelName = [[rawData objectForKey:@"WindModel"] objectForKey:@"Description"];
    self.windModelRun = [[rawData objectForKey:@"WindModel"] objectForKey:@"ModelRun"];
    
    // Loop through the objects, create new condition objects, and append to the array
    NSArray *rawForecastData = [rawData objectForKey:@"ForecastData"];
    for (int i = 0; i < FORECAST_DATA_POINT_COUNT; i++) {
        Forecast *newForecast = [[Forecast alloc] init];
        
        // Grab the raw data from the next item in the list
        NSDictionary *rawForecast = [rawForecastData objectAtIndex:i];
        newForecast.dateString = [rawForecast objectForKey:@"Date"];
        newForecast.timeString = [rawForecast objectForKey:@"Time"];
        newForecast.minimumBreakingHeight = [rawForecast objectForKey:@"MinimumBreakingHeight"];
        newForecast.maximumBreakingHeight = [rawForecast objectForKey:@"MaximumBreakingHeight"];
        newForecast.windSpeed = [rawForecast objectForKey:@"WindSpeed"];
        newForecast.windDirection = [rawForecast objectForKey:@"WindDirection"];
        newForecast.windCompassDirection = [rawForecast objectForKey:@"WindCompassDirection"];
        
        Swell *primarySwell = [[Swell alloc] init];
        primarySwell.waveHeight = [[rawForecast objectForKey:@"PrimarySwellComponent"] objectForKey:@"WaveHeight"];
        primarySwell.period = [[rawForecast objectForKey:@"PrimarySwellComponent"] objectForKey:@"Period"];
        primarySwell.direction = [[rawForecast objectForKey:@"PrimarySwellComponent"] objectForKey:@"Direction"];
        primarySwell.compassDirection = [[rawForecast objectForKey:@"PrimarySwellComponent"] objectForKey:@"CompassDirection"];
        newForecast.primarySwellComponent = primarySwell;
        
        Swell *secondarySwell = [[Swell alloc] init];
        secondarySwell.waveHeight = [[rawForecast objectForKey:@"SecondarySwellComponent"] objectForKey:@"WaveHeight"];
        secondarySwell.period = [[rawForecast objectForKey:@"SecondarySwellComponent"] objectForKey:@"Period"];
        secondarySwell.direction = [[rawForecast objectForKey:@"SecondarySwellComponent"] objectForKey:@"Direction"];
        secondarySwell.compassDirection = [[rawForecast objectForKey:@"SecondarySwellComponent"] objectForKey:@"CompassDirection"];
        newForecast.secondarySwellComponent = secondarySwell;
        
        Swell *tertiarySwell = [[Swell alloc] init];
        tertiarySwell.waveHeight = [[rawForecast objectForKey:@"TertiarySwellComponent"] objectForKey:@"WaveHeight"];
        tertiarySwell.period = [[rawForecast objectForKey:@"TertiarySwellComponent"] objectForKey:@"Period"];
        tertiarySwell.direction = [[rawForecast objectForKey:@"TertiarySwellComponent"] objectForKey:@"Direction"];
        tertiarySwell.compassDirection = [[rawForecast objectForKey:@"TertiarySwellComponent"] objectForKey:@"CompassDirection"];
        newForecast.tertiarySwellComponent = tertiarySwell;
        
        [self.forecasts addObject:newForecast];
    }
    
    return self.forecasts.count == FORECAST_DATA_POINT_COUNT;
}

- (BOOL)check24HourClock {
    NSLocale *locale = [NSLocale currentLocale];
    NSString *dateCheck = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:locale];
    is24HourClock = ([dateCheck rangeOfString:@"a"].location == NSNotFound);
    return is24HourClock;
}

@end