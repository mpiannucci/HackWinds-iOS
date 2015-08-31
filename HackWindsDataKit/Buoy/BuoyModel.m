//
//  BuoyModel.m
//  HackWinds
//
//  Created by Matthew Iannucci on 12/14/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//
// Summary data locations
#define SUMMARY_DATA_HEADER_LENGTH 38
#define SUMMARY_DATA_LINE_LENGTH 19
#define SUMMARY_HOUR_OFFSET 3
#define SUMMARY_MINUTE_OFFSET 4
#define SUMMARY_WVHT_OFFSET 8
#define SUMMARY_DPD_OFFSET 9
#define SUMMARY_DIRECTION_OFFSET 11
#define SUMMARY_TEMPERATURE_OFFSET 14

// Detail data locations
#define DETAIL_DATA_HEADER_LENGTH 30
#define DETAIL_DATA_LINE_LENGTH 15
#define DETAIL_HOUR_OFFSET 3
#define DETAIL_MINUTE_OFFSET 4
#define DETAIL_WVHT_OFFSET 5
#define DETAIL_SWELL_WAVE_HEIGHT_OFFSET 6
#define DETAIL_SWELL_PERIOD_OFFSET 7
#define DETAIL_WIND_WAVE_HEIGHT_OFFSET 8
#define DETAIL_WIND_PERIOD_OFFSET 9
#define DETAIL_SWELL_DIRECTION 10
#define DETAIL_WIND_WAVE_DIRECTION 11

// URLs
#define BI_SUMMARY_URL [NSURL URLWithString:@"http://www.ndbc.noaa.gov/data/realtime2/44097.txt"]
#define BI_DETAIL_URL [NSURL URLWithString:@"http://www.ndbc.noaa.gov/data/realtime2/44097.spec"]
#define MTK_SUMMARY_URL [NSURL URLWithString:@"http://www.ndbc.noaa.gov/data/realtime2/44017.txt"]
#define MTK_DETAIL_URL [NSURL URLWithString:@"http://www.ndbc.noaa.gov/data/realtime2/44017.spec"]
#define ACK_SUMMARY_URL [NSURL URLWithString:@"http://www.ndbc.noaa.gov/data/realtime2/44008.txt"]
#define ACK_DETAIL_URL [NSURL URLWithString:@"http://www.ndbc.noaa.gov/data/realtime2/44008.spec"]

#import "BuoyModel.h"
#import "BuoyDataContainer.h"

@interface BuoyModel ()

// Private methods
- (void) initBuoyContainers;
- (BOOL) parseBuoyData:(NSString*)location;
- (NSArray*) retrieveBuoyDataForLocation:(NSString*)location Detailed:(BOOL)isDetailed;
- (BOOL) getBuoySummaryForIndex:(int)index FromData:(NSArray*)rawData FillBuoy:(Buoy*)buoy;
- (BOOL) getBuoyDetailsForIndex:(int)index FromData:(NSArray*)rawData FillBuoy:(Buoy*)buoy;
- (NSInteger) getCorrectedHourValue:(NSInteger)rawHour;
- (double) getFootConvertedFromMetric:(double)metricValue;
- (BOOL) check24HourClock;

@end

@implementation BuoyModel
{
    int timeOffset;
}

+ (instancetype) sharedModel {
    static BuoyModel *_sharedModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // code to be executed once - thread safe version!
        _sharedModel = [[self alloc] init];
    });
    
    return _sharedModel;
}

- (id)init {
    self = [super init];
    
    [self initBuoyContainers];
    
    // Check if daylight savings is in effect. Make sure the time scaling is for EST (GMT-5)
    NSTimeZone* eastnTZ = [NSTimeZone timeZoneWithName:@"EST5EDT"];
    int daylightoff = [eastnTZ daylightSavingTimeOffset]/3600;
    timeOffset = -5 + daylightoff;
    
    return self;
}

- (void) initBuoyContainers {
    self.buoyDataSets = [[NSMutableDictionary alloc] init];
    
    // Block Island
    BuoyDataContainer *biContainer = [[BuoyDataContainer alloc] init];
    biContainer.summaryURL = BI_SUMMARY_URL;
    biContainer.detailedURL = BI_DETAIL_URL;
    [self.buoyDataSets setValue:biContainer forKey:BLOCK_ISLAND_LOCATION];
    
    // Montauk
    BuoyDataContainer *mtkContainer = [[BuoyDataContainer alloc] init];
    mtkContainer.summaryURL = MTK_SUMMARY_URL;
    mtkContainer.detailedURL = MTK_DETAIL_URL;
    [self.buoyDataSets setValue:mtkContainer forKey:MONTAUK_LOCATION];
    
    // Nantucket
    BuoyDataContainer *ackContainer = [[BuoyDataContainer alloc] init];
    ackContainer.summaryURL = ACK_SUMMARY_URL;
    ackContainer.detailedURL = ACK_DETAIL_URL;
    [self.buoyDataSets setValue:ackContainer forKey:NANTUCKET_LOCATION];
    
}

- (BOOL) fetchBuoyDataForLocation:(NSString*)location {
    const BuoyDataContainer *buoyContainer = [self.buoyDataSets objectForKey:location];
    if (buoyContainer.buoyData.count == 0) {
        return [self parseBuoyData:location];
    } else {
        return YES;
    }
}

- (int) getTimeOffset {
    return timeOffset;
}

- (void) resetData {
    
}

- (NSMutableArray *) getBuoyDataForLocation:(NSString*)location {
    return [[self.buoyDataSets objectForKey:location] buoyData];
}

- (NSMutableArray *) getWaveHeightForLocation:(NSString*)location ForMode:(NSString *)mode {
    if ([mode isEqualToString:SUMMARY_DATA_MODE]) {
        return [[self.buoyDataSets objectForKey:location] waveHeights];
    } else if ([mode isEqualToString:SWELL_DATA_MODE]) {
        return [[self.buoyDataSets objectForKey:location] swellWaveHeights];
    } else if ([mode isEqualToString:WIND_DATA_MODE]) {
        return [[self.buoyDataSets objectForKey:location] windWaveHeights];
    } else {
        return nil;
    }
}

+ (Buoy*) getLatestBuoyDataOnlyForLocation:(NSString*)location {
    // Get the model instance
    BuoyModel *buoyModel = [[BuoyModel alloc] init];
    
    NSArray *rawBuoyData = [buoyModel retrieveBuoyDataForLocation:location Detailed:NO];
    if (rawBuoyData == nil) {
        return nil;
    }
    
    Buoy *latestBuoy = [[Buoy alloc] init];
    [buoyModel getBuoySummaryForIndex:0 FromData:rawBuoyData FillBuoy:latestBuoy];
    
    return latestBuoy;
}

- (BOOL) parseBuoyData:(NSString*)location {
    // Get the raw data from ndbc
    NSArray *rawSummaryBuoyData = [self retrieveBuoyDataForLocation:location Detailed:NO];
    if (rawSummaryBuoyData == nil) {
        return NO;
    }
    
    NSArray *rawDetailedBuoyData = [self retrieveBuoyDataForLocation:location Detailed:YES];
    if (rawDetailedBuoyData == nil) {
        return NO;
    }
    
    BuoyDataContainer *buoyContainer = [self.buoyDataSets objectForKey:location];
    int dataPointCount = 0;
    while (dataPointCount < BUOY_DATA_POINTS) {
        // Get the next buoy object
        Buoy *newBuoy = [[Buoy alloc] init];
        [self getBuoySummaryForIndex:dataPointCount FromData:rawSummaryBuoyData FillBuoy:newBuoy];
        [self getBuoyDetailsForIndex:dataPointCount FromData:rawDetailedBuoyData FillBuoy:newBuoy];
        
        dataPointCount++;
        
        [buoyContainer.buoyData addObject:newBuoy];
        [buoyContainer.waveHeights addObject:[NSString stringWithFormat:@"%@", newBuoy.SignificantWaveHeight]];
        [buoyContainer.swellWaveHeights addObject:[NSString stringWithFormat:@"%@", newBuoy.SwellWaveHeight]];
        [buoyContainer.windWaveHeights addObject:[NSString stringWithFormat:@"%@", newBuoy.WindWaveHeight]];
    }
    return YES;
}

- (NSArray*) retrieveBuoyDataForLocation:(NSString*)location Detailed:(BOOL)isDetailed {
    // Get the buoy data
    NSError *err = nil;
    
    // Get the buoy data
    NSURL *dataURL = [[NSURL alloc] init];
    if (isDetailed) {
        dataURL = [[self.buoyDataSets objectForKey:location] detailedURL];
    } else {
        dataURL = [[self.buoyDataSets objectForKey:location] summaryURL];
    }
    NSString* buoyData = [NSString stringWithContentsOfURL:dataURL encoding:NSUTF8StringEncoding error:&err];
    
    // If it was unsuccessful, return false
    if (err != nil) {
        return nil;
    }
    
    // Strip everything thats not relevant
    NSCharacterSet *whitespaces = [NSCharacterSet whitespaceCharacterSet];
    NSPredicate *noEmptyStrings = [NSPredicate predicateWithFormat:@"SELF != ''"];
    NSArray *parts = [buoyData componentsSeparatedByCharactersInSet:whitespaces];
    NSArray *filteredArray = [parts filteredArrayUsingPredicate:noEmptyStrings];
    buoyData = [filteredArray componentsJoinedByString:@" "];
    return [buoyData componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (BOOL) getBuoySummaryForIndex:(int)index FromData:(NSArray *)rawData FillBuoy:(Buoy *)buoy {
    int baseOffset = SUMMARY_DATA_HEADER_LENGTH + (SUMMARY_DATA_LINE_LENGTH * index);
    if (baseOffset >= (SUMMARY_DATA_HEADER_LENGTH+(SUMMARY_DATA_LINE_LENGTH*BUOY_DATA_POINTS))) {
        return NO;
    }
    
    if (buoy.Time == nil) {
    
        // Get the time value from the file, make sure that the hour offset is correct for the regions daylight savings
        NSInteger originalHour = [[rawData objectAtIndex:baseOffset+SUMMARY_HOUR_OFFSET] integerValue] + [self getTimeOffset];
        NSInteger convertedHour = [self getCorrectedHourValue:originalHour];
    
        // Set the time value for the object
        NSString *minute = [rawData objectAtIndex:baseOffset+SUMMARY_MINUTE_OFFSET];
        buoy.Time = [NSString stringWithFormat:@"%ld:%@", (long)convertedHour, minute];
    }
    
    // Period and wind direction values
    buoy.DominantPeriod =[rawData objectAtIndex:baseOffset+SUMMARY_DPD_OFFSET];
    buoy.MeanDirection = [rawData objectAtIndex:baseOffset+SUMMARY_DIRECTION_OFFSET];
    
    // Water Temperature Values converted from celsius to fahrenheit
    double waterTemp = (([[rawData objectAtIndex:baseOffset+SUMMARY_TEMPERATURE_OFFSET] doubleValue] * (9.0 / 5.0) +32.0 ) / 0.05) * 0.05;
    buoy.WaterTemperature = [NSString stringWithFormat:@"%4.2f", waterTemp];
    
    // Change the wave height to feet and set it
    NSString *wv = [rawData objectAtIndex:baseOffset+SUMMARY_WVHT_OFFSET];
    buoy.SignificantWaveHeight = [NSString stringWithFormat:@"%2.2f", [self getFootConvertedFromMetric:[wv doubleValue]]];
    
    return YES;
}

- (BOOL) getBuoyDetailsForIndex:(int)index FromData:(NSArray *)rawData FillBuoy:(Buoy *)buoy {
    int baseOffset = DETAIL_DATA_HEADER_LENGTH + (DETAIL_DATA_LINE_LENGTH * index);
    if (baseOffset >= (DETAIL_DATA_HEADER_LENGTH+(DETAIL_DATA_LINE_LENGTH*BUOY_DATA_POINTS))) {
        return NO;
    }
    
    if (buoy.Time == nil) {
        // Get the time value from the file, make sure that the hour offset is correct for the regions daylight savings
        NSInteger originalHour = [[rawData objectAtIndex:baseOffset+DETAIL_HOUR_OFFSET] integerValue] + [self getTimeOffset];
        NSInteger convertedHour = [self getCorrectedHourValue:originalHour];
        
        // Set the time value for the object
        NSString *minute = [rawData objectAtIndex:baseOffset+DETAIL_MINUTE_OFFSET];
        buoy.Time = [NSString stringWithFormat:@"%ld:%@", (long)convertedHour, minute];
    }
    
    // Wave heights
    NSString *swellHeight = [rawData objectAtIndex:baseOffset+DETAIL_SWELL_WAVE_HEIGHT_OFFSET];
    NSString *windHeight = [rawData objectAtIndex:baseOffset+DETAIL_WIND_WAVE_HEIGHT_OFFSET];
    buoy.SwellWaveHeight = [NSString stringWithFormat:@"%2.2f", [self getFootConvertedFromMetric:[swellHeight doubleValue]]];
    buoy.WindWaveHeight = [NSString stringWithFormat:@"%2.2f", [self getFootConvertedFromMetric:[windHeight doubleValue]]];
    
    // Periods
    buoy.SwellPeriod = [rawData objectAtIndex:baseOffset+DETAIL_SWELL_PERIOD_OFFSET];
    buoy.WindWavePeriod = [rawData objectAtIndex:baseOffset+DETAIL_WIND_PERIOD_OFFSET];
    
    // Directions
    buoy.SwellDirection = [rawData objectAtIndex:baseOffset+DETAIL_SWELL_DIRECTION];
    buoy.WindWaveDirection = [rawData objectAtIndex:baseOffset+DETAIL_WIND_WAVE_DIRECTION];
    
    return YES;
}

- (NSInteger) getCorrectedHourValue:(NSInteger)rawHour {
    NSInteger convertedHour = 0;
    
    // Formate the hour correctly if the user has 24 hour time enabled
    if ([self check24HourClock]) {
        convertedHour = (rawHour + 24) % 24;
        if (convertedHour == 0) {
            if ((rawHour + [self getTimeOffset]) > 0) {
                convertedHour = 12;
            }
        }
    } else {
        convertedHour = (rawHour + 12) % 12;
        if (convertedHour == 0) {
            convertedHour = 12;
        }
    }
    
    return convertedHour;
}

- (double) getFootConvertedFromMetric:(double)metricValue {
    return metricValue * 3.28;
}

- (BOOL) check24HourClock {
    // Slightly different than the ofrecast model check.. not caching the value at all
    NSLocale *locale = [NSLocale currentLocale];
    NSString *dateCheck = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:locale];
    return ([dateCheck rangeOfString:@"a"].location == NSNotFound);
}

@end