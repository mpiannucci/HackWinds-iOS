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

@interface ForecastModel ()

// Private methods
- (void) loadRawData;
- (BOOL) parseForecasts;
- (NSString *) formatDate:(NSUInteger)epoch;
- (BOOL) checkConditionDate:(NSString *)dateString;
- (BOOL) checkForecastDate:(NSString *)dateString;

@end

@implementation ForecastModel
{
    NSArray *rawData;
    NSDictionary *locationURLs;
    NSString *currentLocationURL;
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
    
    // Load locations from file
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ForecastLocations"
                                                     ofType:@"plist"];
    locationURLs = [NSDictionary dictionaryWithContentsOfFile:path];
    
    // Initialize the data holders
    self.conditions = [[NSMutableArray alloc] init];
    self.forecasts = [[NSMutableArray alloc] init];
    
    // Get the current location and setup the settings listener
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:@"ForecastLocation"
                                               options:NSKeyValueObservingOptionNew
                                               context:NULL];
    // Get the forecast location
    [self changeForecastLocation];
    return self;
}

- (void) changeForecastLocation {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Load the url for the current location using the url dictionary
    currentLocationURL = [locationURLs objectForKey:[defaults objectForKey:@"ForecastLocation"]];
}

- (NSArray *) getConditionsForIndex:(int)index {
    if (rawData.count == 0) {
        // Theres no data yet so load form the url
        [self loadRawData];
    }
    if ([self.conditions count] == 0) {
        // There are no conditions so parse them out
        [self parseForecasts];
    }
    
    NSArray *currentConditions = [self.conditions subarrayWithRange:NSMakeRange(index*6, 6)];
    return currentConditions;
}

- (NSMutableArray *) getForecasts {
    if (rawData.count == 0) {
        // Theres no data yet so load form the url
        [self loadRawData];
    }
    if ([self.forecasts count] == 0) {
        // Theres no forecasts yet so parse them out
        [self parseForecasts];
    }
    
    return self.forecasts;
}

- (void)loadRawData {
    NSData *mswResponse = [NSData dataWithContentsOfURL:[NSURL URLWithString:currentLocationURL]];
    NSError *error;
    rawData = [NSJSONSerialization
               JSONObjectWithData:mswResponse
               options:kNilOptions
               error:&error];
}

- (BOOL) parseForecasts {
    // If there's no data, return nothing
    if (rawData == nil) {
        return NO;
    }
    
    // Loop through the objects, create new condition objects, and append to the array
    int conditionCount = 0;
    int forecastCount = 0;
    int dataIndex = 0;
    while ((conditionCount < 30) || (forecastCount < 10)) {
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
        
        if (conditionCheck && conditionCount < 30) {
            // Get a new condition object
            Condition *thisCondition = [[Condition alloc] init];
            [thisCondition setDate:date];
        
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
            [self.conditions addObject:thisCondition];
            conditionCount++;
        }
        
        if (forecastCheck && (forecastCount < 10)) {
            // Get a new Forecast object
            Forecast *thisForecast = [[Forecast alloc] init];
        
            // Set the date
            [thisForecast setDate:date];
        
            // Get the minimum and maximumm breaking heights
            [thisForecast setMinBreakHeight:[swellDict objectForKey:@"minBreakingHeight"]];
            [thisForecast setMaxBreakHeight:[swellDict objectForKey:@"maxBreakingHeight"]];
        
            // Get the wind speed and direction
            [thisForecast setWindSpeed:[windDict objectForKey:@"speed"]];
            [thisForecast setWindDir:[windDict objectForKey:@"compassDirection"]];
        
            // Append the forecast to the list
            [self.forecasts addObject:thisForecast];
            forecastCount++;
        }
    }
    return YES;
}

- (NSString *)formatDate:(NSUInteger)epoch
{
    // Return the formatted date string so it has the form "12:38 am"
    NSDate *forcTime = [NSDate dateWithTimeIntervalSince1970:epoch];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"K a"];
    [format setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSString *formatted = [format stringFromDate:forcTime];
    if ([formatted hasPrefix:@"0"]) {
        [format setDateFormat:@"HH a"];
        [format setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        formatted = [format stringFromDate:forcTime];
    }
    return formatted;
}

- (BOOL)checkConditionDate:(NSString *)dateString
{
    // Check if the date is for a valid time, we dont care about midnight nor 3 am
    NSRange AMrange = [dateString rangeOfString:@"AM"];
    NSRange Zerorange = [dateString rangeOfString:@"0"];
    NSRange Threerange = [dateString rangeOfString:@"3"];
    if (((AMrange.location != NSNotFound) && (Zerorange.location != NSNotFound)) ||
        ((AMrange.location != NSNotFound) && (Threerange.location != NSNotFound)))
    {
        // We dont care, return false
        return false;
    }
    // Valid time
    return true;
}

- (BOOL)checkForecastDate:(NSString *)dateString
{
    // Check if the date is for a valid time, if its not return false (We only want very specific times for this
    NSRange AMrange = [dateString rangeOfString:@"AM"];
    NSRange PMrange = [dateString rangeOfString:@"PM"];
    NSRange Zerorange = [dateString rangeOfString:@"0"];
    NSRange Threerange = [dateString rangeOfString:@"3"];
    NSRange Sixrange = [dateString rangeOfString:@"6"];
    NSRange Ninerange = [dateString rangeOfString:@"9"];
    NSRange Twelverange = [dateString rangeOfString:@"12"];
    if (((AMrange.location != NSNotFound) && (Zerorange.location != NSNotFound)) ||
        ((AMrange.location != NSNotFound) && (Threerange.location != NSNotFound)) ||
        ((AMrange.location != NSNotFound) && (Sixrange.location != NSNotFound)) ||
        ((PMrange.location != NSNotFound) && (Twelverange.location != NSNotFound)) ||
        ((PMrange.location != NSNotFound) && (Sixrange.location != NSNotFound)) ||
        ((PMrange.location != NSNotFound) && (Ninerange.location != NSNotFound)))
    {
        return false;
    }
    return true;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    // Callback for the forecast location settings changing
    // First clear all of the old data so that everything reloads
    if (rawData.count > 0) {
        rawData = [[NSArray alloc] init];
    }
    if ([self.conditions count] > 0) {
        [self.conditions removeAllObjects];
    }
    if ([self.forecasts count] > 0) {
        [self.forecasts removeAllObjects];
    }
    
    // Update the location
    [self changeForecastLocation];
    
    // Tell everyone the data has updated
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"ForecastModelDidUpdateDataNotification"
         object:self];
    });
}

@end