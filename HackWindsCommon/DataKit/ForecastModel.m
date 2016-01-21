//
//  ForecastModel.m
//  HackWinds
//
//  Created by Matthew Iannucci on 12/14/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//
#import "ForecastModel.h"
#import "Forecast.h"
#import "Condition.h"
#import "ForecastDataContainer.h"

NSString * const TOWN_BEACH_LOCATION = @"Narragansett Town Beach";
NSString * const POINT_JUDITH_LOCATION = @"Point Judith Lighthouse";
NSString * const MATUNUCK_LOCATION = @"Matunuck";
NSString * const SECOND_BEACH_LOCATION = @"Second Beach";

// Notification Constants
NSString * const FORECAST_DATA_UPDATED_TAG = @"ForecastModelDidUpdateDataNotification";
NSString * const FORECAST_LOCATION_CHANGED_TAG = @"ForecastLocationChangedNotification";
NSString * const FORECAST_DATA_UPDATE_FAILED_TAG = @"ForecastModelUpdateFailedNotification";

// Local Constants
static NSString * const BASE_MSW_URL = @"http://magicseaweed.com/api/nFSL2f845QOAf1Tuv7Pf5Pd9PXa5sVTS/forecast/?spot_id=%@&fields=localTimestamp,swell.*,wind.*,charts.*";
static const int TOWN_BEACH_ID = 1103;
static const int POINT_JUDITH_ID = 376;
static const int MATUNUCK_ID = 377;
static const int SECOND_BEACH_ID = 846;

@interface ForecastModel ()

// Private methods
- (void) initForecastContainers;
- (BOOL) parseForecastsFromData:(NSData*) unserializedData;
- (NSString *) formatDate:(NSUInteger)epoch;
- (BOOL) checkConditionDate:(NSString *)dateString;
- (BOOL) checkForecastDate:(NSString *)dateString;
- (BOOL) check24HourClock;

// Private members
@property (strong, nonatomic) NSUserDefaults *userDefaults;
@property (strong, nonatomic) NSMutableDictionary *forecastDataContainers;

@end

@implementation ForecastModel
{
    ForecastDataContainer *currentContainer;
    BOOL is24HourClock;
    BOOL initialForecastChange;
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
    initialForecastChange = YES;
    
    // Load the containers wiht the data
    [self initForecastContainers];
    
    self.userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.nucc.HackWinds"];
    [self.userDefaults synchronize];
    
    // Get the current location and setup the settings listener
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeForecastLocation)
                                                 name:FORECAST_LOCATION_CHANGED_TAG
                                               object:nil];
    
    // Get the forecast location
    [self changeForecastLocation];
    
    return self;
}

- (void) initForecastContainers {
    self.forecastDataContainers = [[NSMutableDictionary alloc] init];
    
    ForecastDataContainer *townBeachData = [[ForecastDataContainer alloc] init];
    townBeachData.forecastID = [NSNumber numberWithInt:TOWN_BEACH_ID];
    [self.forecastDataContainers setObject:townBeachData forKey:TOWN_BEACH_LOCATION];
    
    ForecastDataContainer *pointJudithData = [[ForecastDataContainer alloc] init];
    pointJudithData.forecastID = [NSNumber numberWithInt:POINT_JUDITH_ID];
    [self.forecastDataContainers setObject:pointJudithData forKey:POINT_JUDITH_LOCATION];
    
    ForecastDataContainer *matunuckData = [[ForecastDataContainer alloc] init];
    matunuckData.forecastID = [NSNumber numberWithInt:MATUNUCK_ID];
    [self.forecastDataContainers setObject:matunuckData forKey:MATUNUCK_LOCATION];
    
    ForecastDataContainer *secondBeachData = [[ForecastDataContainer alloc] init];
    secondBeachData.forecastID = [NSNumber numberWithInt:SECOND_BEACH_ID];
    [self.forecastDataContainers setObject:secondBeachData forKey:SECOND_BEACH_LOCATION];
}

- (void) changeForecastLocation {
    [self.userDefaults synchronize];
    
    currentContainer = [self.forecastDataContainers objectForKey:[self.userDefaults objectForKey:@"ForecastLocation"]];
    
    if (!initialForecastChange) {
        
        // Download the data for the new location!
        [self fetchForecastData];
    
    } else {
        initialForecastChange = NO;
    }
}

- (NSMutableArray*) getConditions {
    return currentContainer.conditions;
}

- (NSMutableArray *) getForecasts {
    return currentContainer.forecasts;
}

- (NSArray *) getConditionsForIndex:(int)index {
    if (currentContainer.conditions.count == CONDITION_DATA_POINT_COUNT) {
        NSArray *currentConditions = [currentContainer.conditions subarrayWithRange:NSMakeRange(index*6, 6)];
        return currentConditions;
    }
    return NULL;
}

- (void) fetchForecastData {
    @synchronized(self) {
        
        if (currentContainer.conditions.count != 0) {
            // Tell any listeners that the data has been loaded.
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:FORECAST_DATA_UPDATED_TAG
                 object:self];
            });
            
            return;
        }
        
        NSURL *dataURL = [NSURL URLWithString:[NSString stringWithFormat:BASE_MSW_URL, currentContainer.forecastID]];
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
    NSArray *rawData = [NSJSONSerialization
               JSONObjectWithData:unserializedData
               options:kNilOptions
               error:&error];
    
    // If there's no data, return nothing
    if (rawData == nil) {
        return NO;
    } else if (rawData.count < 1) {
        return NO;
    } else if ([rawData isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    
    // Loop through the objects, create new condition objects, and append to the array
    int conditionCount = 0;
    int forecastCount = 0;
    int dataIndex = 0;
    while (((conditionCount < CONDITION_DATA_POINT_COUNT) || (forecastCount < FORECAST_DATA_POINT_COUNT)) && (dataIndex < rawData.count)) {
        // Get the next json object and increment the count
        NSDictionary *thisDict = [rawData objectAtIndex:dataIndex];
        dataIndex++;
        
        // Get the hour and make sure it is valid for a condition object
        NSNumber *rawDate = [thisDict objectForKey:@"localTimestamp"];
        NSString *date = [self formatDate:[rawDate unsignedIntegerValue]];
        Boolean conditionCheck = [self checkConditionDate:date];
        Boolean forecastCheck = [self checkForecastDate:date];
        if (!conditionCheck && !forecastCheck)
        {
            continue;
        }
        
        // Get the dictionaries from the json array
        NSDictionary *swellDict = [thisDict objectForKey:@"swell"];
        NSDictionary *windDict = [thisDict objectForKey:@"wind"];
        NSDictionary *chartDict = [thisDict objectForKey:@"charts"];
        
        if (conditionCheck && conditionCount < CONDITION_DATA_POINT_COUNT) {
            // Get a new condition object
            Condition *thisCondition = [[Condition alloc] init];
            [thisCondition setTimestamp:date];
            
            // Get the minumum and maximum wave heights
            [thisCondition setMinBreakHeight:[swellDict objectForKey:@"minBreakingHeight"]];
            [thisCondition setMaxBreakHeight:[swellDict objectForKey:@"maxBreakingHeight"]];
            
            // Get the wind direction and speed
            [thisCondition setWindSpeed:[windDict objectForKey:@"speed"]];
            [thisCondition setWindDeg:[windDict objectForKey:@"direction"]];
            [thisCondition setWindDirection:[windDict objectForKey:@"compassDirection"]];
            
            // Get the swell height, period, and direction
            [thisCondition setSwellHeight:[[[swellDict objectForKey:@"components"] objectForKey:@"primary"] objectForKey:@"height"]];
            [thisCondition setSwellPeriod:[[[swellDict objectForKey:@"components"] objectForKey:@"primary"] objectForKey:@"period"]];
            [thisCondition setSwellDirection:[[[swellDict objectForKey:@"components"] objectForKey:@"primary"] objectForKey:@"compassDirection"]];
            
            // Get the Chart URLS
            [thisCondition setSwellChartURL:[chartDict objectForKey:@"swell"]];
            [thisCondition setWindChartURL:[chartDict objectForKey:@"wind"]];
            [thisCondition setPeriodChartURL:[chartDict objectForKey:@"period"]];
            
            // Append the condition
            [currentContainer.conditions addObject:thisCondition];
            conditionCount++;
        }
        
        if (forecastCheck && (forecastCount < FORECAST_DATA_POINT_COUNT)) {
            // Get a new Forecast object
            Forecast *thisForecast = [[Forecast alloc] init];
            
            // Set the date
            [thisForecast setTimestamp:date];
            
            // Get the minimum and maximumm breaking heights
            [thisForecast setMinBreakHeight:[swellDict objectForKey:@"minBreakingHeight"]];
            [thisForecast setMaxBreakHeight:[swellDict objectForKey:@"maxBreakingHeight"]];
            
            // Get the wind speed and direction
            [thisForecast setWindSpeed:[windDict objectForKey:@"speed"]];
            [thisForecast setWindDirection:[windDict objectForKey:@"compassDirection"]];
            
            // Append the forecast to the list
            [currentContainer.forecasts addObject:thisForecast];
            forecastCount++;
        }
    }
    return (currentContainer.forecasts.count == FORECAST_DATA_POINT_COUNT) && (currentContainer.conditions.count == CONDITION_DATA_POINT_COUNT);
}

- (NSString *)formatDate:(NSUInteger)epoch {
    // Return the formatted date string so it has the form "12:38 am"
    NSDate *forcTime = [NSDate dateWithTimeIntervalSince1970:epoch];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSString *formatted = @"";
    
    if ([self check24HourClock]) {
        [format setDateFormat:@"HH"];
        formatted = [NSString stringWithFormat:@"%@:00", [format stringFromDate:forcTime]];
    } else {
        [format setDateFormat:@"K a"];
        formatted = [format stringFromDate:forcTime];
        if ([formatted hasPrefix:@"0"]) {
            [format setDateFormat:@"HH a"];
            [format setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            formatted = [format stringFromDate:forcTime];
        }
    }
    return formatted;
}

- (BOOL)checkConditionDate:(NSString *)dateString {
    // Check if the date is for a valid time, we dont care about midnight nor 3 am
    if ([self check24HourClock]) {
        NSRange zeroRange = [dateString rangeOfString:@"00:"];
        NSRange threeRange = [dateString rangeOfString:@"03:"];
        if ((zeroRange.location != NSNotFound) || (threeRange.location != NSNotFound)) {
            // We dont care about them
            return NO;
        }
        return YES;
    } else {
        NSRange amRange = [dateString rangeOfString:@"AM"];
        NSRange zeroRange = [dateString rangeOfString:@"0"];
        NSRange threeRange = [dateString rangeOfString:@"3"];
        if (((amRange.location != NSNotFound) && (zeroRange.location != NSNotFound)) ||
            ((amRange.location != NSNotFound) && (threeRange.location != NSNotFound)))
        {
            // We dont care, return false
            return NO;
        }
        // Valid time
        return YES;
    }
}

- (BOOL)checkForecastDate:(NSString *)dateString
{
    // Check if the date is for a valid time, if its not return false (We only want very specific times for this
    if ([self check24HourClock]) {
        NSRange nineRange = [dateString rangeOfString:@"9"];
        NSRange fifteenRange = [dateString rangeOfString:@"15"];
        if ((nineRange.location != NSNotFound) ||
            (fifteenRange.location != NSNotFound))
        {
            // We care!!
            return YES;
        }
        return NO;
    } else {
        NSRange amRange = [dateString rangeOfString:@"AM"];
        NSRange pmRange = [dateString rangeOfString:@"PM"];
        NSRange threeRange = [dateString rangeOfString:@"3"];
        NSRange nineRange = [dateString rangeOfString:@"9"];
        if (((amRange.location != NSNotFound) && (nineRange.location != NSNotFound)) ||
            ((pmRange.location != NSNotFound) && (threeRange.location != NSNotFound)))
        {
            // We care!!
            return YES;
        }
        return NO;
    }
}

- (BOOL)check24HourClock {
    NSLocale *locale = [NSLocale currentLocale];
    NSString *dateCheck = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:locale];
    is24HourClock = ([dateCheck rangeOfString:@"a"].location == NSNotFound);
    return is24HourClock;
}

@end