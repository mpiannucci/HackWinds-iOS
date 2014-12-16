//
//  ForecastModel.m
//  HackWinds
//
//  Created by Matthew Iannucci on 12/14/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//

#define MSW_NARR_PIER_URL [NSURL URLWithString:@"http://magicseaweed.com/api/nFSL2f845QOAf1Tuv7Pf5Pd9PXa5sVTS/forecast/?spot_id=1103&fields=localTimestamp,swell.*,wind.*"]

#import "ForecastModel.h"
#import "Forecast.h"
#import "Condition.h"

@interface ForecastModel ()

// Private methods
- (void) loadRawData;
- (BOOL) parseConditions;
- (BOOL) parseForecasts;
- (NSString *) formatDate:(NSUInteger)epoch;
- (BOOL) checkConditionDate:(NSString *)dateString;
- (BOOL) checkForecastDate:(NSString *)dateString;

@end

@implementation ForecastModel
{
    NSData *rawData;
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
    
    // Initialize the data holders
    _conditions = [[NSMutableArray alloc] init];
    _forecasts = [[NSMutableArray alloc] init];
    
    return self;
}

- (NSMutableArray *) getCurrentConditions {
    if (rawData.length == 0) {
        // Theres no data yet so load form the url
        [self loadRawData];
    }
    if ([_conditions count] == 0) {
        // There are no conditions so parse them out
        [self parseConditions];
    }
    
    return _conditions;
}

- (NSMutableArray *) getForecasts {
    if (rawData.length == 0) {
        // Theres no data yet so load form the url
        [self loadRawData];
    }
    if ([_forecasts count] == 0) {
        // Theres no forecasts yet so parse them out
        [self parseForecasts];
    }
    
    return _forecasts;
}

- (void)loadRawData {
    rawData = [NSData dataWithContentsOfURL:MSW_NARR_PIER_URL];
}

- (BOOL) parseConditions {
    //parse out the MSW json data
    NSError* error;
    NSArray* json = [NSJSONSerialization
                     JSONObjectWithData:rawData
                     options:kNilOptions
                     error:&error];
    
    // Loop through the objects, create new condition objects, and append to the array
    int i = 0;
    int j = 0;
    while (i<6) {
        // Get the next json object and increment the count
        NSDictionary *thisDict = [json objectAtIndex:j];
        j++;
        
        // Get the hour and make sure it is valid
        NSNumber *rawDate = [thisDict objectForKey:@"localTimestamp"];
        NSString *date = [self formatDate:[rawDate unsignedIntegerValue]];
        Boolean check = [self checkConditionDate:date];
        if (!check)
        {
            continue;
        }
        
        // Get a new condition object
        Condition *thisCondition = [[Condition alloc] init];
        [thisCondition setDate:date];
        
        // Get the minumum and maximum wave heights
        NSDictionary *swellDict = [thisDict objectForKey:@"swell"];
        [thisCondition setMinBreak:[swellDict objectForKey:@"minBreakingHeight"]];
        [thisCondition setMaxBreak:[swellDict objectForKey:@"maxBreakingHeight"]];
        
        // Get the wind direction and speed
        NSDictionary *windDict = [thisDict objectForKey:@"wind"];
        [thisCondition setWindSpeed:[windDict objectForKey:@"speed"]];
        [thisCondition setWindDeg:[windDict objectForKey:@"direction"]];
        [thisCondition setWindDir:[windDict objectForKey:@"compassDirection"]];
        
        // Get the swell height, period, and direction
        [thisCondition setSwellHeight:[[[swellDict objectForKey:@"components"] objectForKey:@"primary"] objectForKey:@"height"]];
        [thisCondition setSwellPeriod:[[[swellDict objectForKey:@"components"] objectForKey:@"primary"] objectForKey:@"period"]];
        [thisCondition setSwellDir:[[[swellDict objectForKey:@"components"] objectForKey:@"primary"] objectForKey:@"compassDirection"]];
        
        // Append the condition
        [_conditions addObject:thisCondition];
        i++;
    }
    return YES;
}

- (BOOL) parseForecasts {
    //parse out the MSW json data
    NSError* error;
    NSArray* json = [NSJSONSerialization
                     JSONObjectWithData:rawData
                     options:kNilOptions
                     error:&error];
    // Quick log to check the amount of json objects recieved
    NSLog(@"%lu", (unsigned long)[json count]);
    
    // Loop through the objects, create new condition objects, and append to the array
    int i = 0;
    int j = 0;
    while (i<10) {
        NSDictionary *thisDict = [json objectAtIndex:j];
        j++;
        
        // Get the hour and check if its one that we care about
        NSNumber *rawDate = [thisDict objectForKey:@"localTimestamp"];
        NSString *date = [self formatDate:[rawDate unsignedIntegerValue]];
        Boolean check = [self checkForecastDate:date];
        if (!check)
        {
            continue;
        }
        
        // Get a new Foreccast object
        Forecast *thisForecast = [[Forecast alloc] init];
        
        // Set the date
        [thisForecast setDate:date];
        
        // Get the minimum and maximumm breaking heights
        NSDictionary *swellDict = [thisDict objectForKey:@"swell"];
        [thisForecast setMinBreak:[swellDict objectForKey:@"minBreakingHeight"]];
        [thisForecast setMaxBreak:[swellDict objectForKey:@"maxBreakingHeight"]];
        
        // Get the wind speed and direction
        NSDictionary *windDict = [thisDict objectForKey:@"wind"];
        [thisForecast setWindSpeed:[windDict objectForKey:@"speed"]];
        [thisForecast setWindDir:[windDict objectForKey:@"compassDirection"]];
        
        // Append the forecast to the list
        [_forecasts addObject:thisForecast];
        i++;
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

@end