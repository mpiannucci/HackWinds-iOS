//
//  BuoyModel.m
//  HackWinds
//
//  Created by Matthew Iannucci on 12/14/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//
#define DATA_HEADER_LENGTH 38
#define DATA_LINE_LEN 19
#define HOUR_OFFSET 3
#define MINUTE_OFFSET 4
#define WVHT_OFFSET 8
#define DPD_OFFSET 9
#define DIRECTION_OFFSET 11
#define TEMPERATURE_OFFSET 14
#define BI_URL [NSURL URLWithString:@"http://www.ndbc.noaa.gov/data/realtime2/44097.txt"]
#define MTK_URL [NSURL URLWithString:@"http://www.ndbc.noaa.gov/data/realtime2/44017.txt"]
#define ACK_URL [NSURL URLWithString:@"http://www.ndbc.noaa.gov/data/realtime2/44008.txt"]

#import "BuoyModel.h"
#import "BuoyDataContainer.h"

@interface BuoyModel ()

// Private methods
- (void) initBuoyContainers;
- (BOOL) parseBuoyData:(NSString*)location;
- (NSArray*) retrieveBuoyDataForLocation:(NSString*)location;
- (Buoy*) getBuoyObjectForIndex:(int)index FromData:(NSArray*)rawData;
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

- (id)init
{
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
    biContainer.url = BI_URL;
    [self.buoyDataSets setValue:biContainer forKey:BLOCK_ISLAND_LOCATION];
    
    // Montauk
    BuoyDataContainer *mtkContainer = [[BuoyDataContainer alloc] init];
    mtkContainer.url = MTK_URL;
    [self.buoyDataSets setValue:mtkContainer forKey:MONTAUK_LOCATION];
    
    // Nantucket
    BuoyDataContainer *ackContainer = [[BuoyDataContainer alloc] init];
    ackContainer.url = ACK_URL;
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

- (NSMutableArray *) getBuoyDataForLocation:(NSString*)location {
    return [[self.buoyDataSets objectForKey:location] buoyData];
}

- (void) resetData {
    
}

- (NSMutableArray *) getWaveHeightForLocation:(NSString*)location {
    return [[self.buoyDataSets objectForKey:location] waveHeights];
}

- (BOOL) parseBuoyData:(NSString*)location {
    // Get the raw data from ndbc
    NSArray *rawBuoyData = [self retrieveBuoyDataForLocation:location];
    if (rawBuoyData == nil) {
        return NO;
    }
    
    BuoyDataContainer *buoyContainer = [self.buoyDataSets objectForKey:location];
    int dataPointCount = 0;
    while (dataPointCount < BUOY_DATA_POINTS) {
        // Get the next buoy object
        Buoy *newBuoy = [self getBuoyObjectForIndex:dataPointCount FromData:rawBuoyData];
        dataPointCount++;
        
        [buoyContainer.buoyData addObject:newBuoy];
        [buoyContainer.waveHeights addObject:[NSString stringWithFormat:@"%@", newBuoy.WaveHeight]];
    }
    return YES;
}

+ (Buoy*) getLatestBuoyDataOnlyForLocation:(NSString*)location {
    // Get the model instance
    BuoyModel *buoyModel = [[BuoyModel alloc] init];
    
    // Get the raw buoy data from ndbc
    NSArray *rawBuoyData = [buoyModel retrieveBuoyDataForLocation:location];
    if (rawBuoyData == nil) {
        return nil;
    }
    
    return [buoyModel getBuoyObjectForIndex:0 FromData:rawBuoyData];
}

- (NSArray*) retrieveBuoyDataForLocation:(NSString*)location {
    // Get the buoy data
    NSError *err = nil;
    
    // Get the buoy data
    NSURL *dataURL = [[self.buoyDataSets objectForKey:location] url];
    NSString* buoyData = [NSString stringWithContentsOfURL:dataURL encoding:NSUTF8StringEncoding error:&err];
    
    // If it was unsuccessful, return false
    if (err != nil) {
        return nil;
    }
    
    NSCharacterSet *whitespaces = [NSCharacterSet whitespaceCharacterSet];
    NSPredicate *noEmptyStrings = [NSPredicate predicateWithFormat:@"SELF != ''"];
    NSArray *parts = [buoyData componentsSeparatedByCharactersInSet:whitespaces];
    NSArray *filteredArray = [parts filteredArrayUsingPredicate:noEmptyStrings];
    buoyData = [filteredArray componentsJoinedByString:@" "];
    return [buoyData componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (Buoy*) getBuoyObjectForIndex:(int)index FromData:(NSArray *)rawData {
    int baseOffset = DATA_HEADER_LENGTH + (DATA_LINE_LEN * index);
    if (baseOffset >= (DATA_HEADER_LENGTH+(DATA_LINE_LEN*BUOY_DATA_POINTS))) {
        return nil;
    }
    
    Buoy *newBuoy = [[Buoy alloc] init];
    
    // Get the time value from the file, make sure that the hour offset is correct for the regions daylight savings
    NSInteger originalHour = [[rawData objectAtIndex:baseOffset+HOUR_OFFSET] integerValue] + [self getTimeOffset];
    NSInteger convertedHour = 0;
    
    // Formate the hour correctly if the user has 24 hour time enabled
    if ([self check24HourClock]) {
        convertedHour = (originalHour + 24) % 24;
        if (convertedHour == 0) {
            if ((originalHour + [self getTimeOffset]) > 0) {
                convertedHour = 12;
            }
        }
    } else {
        convertedHour = (originalHour + 12) % 12;
        if (convertedHour == 0) {
            convertedHour = 12;
        }
    }
    
    // Set the time value for the object
    NSString *minute = [rawData objectAtIndex:baseOffset+MINUTE_OFFSET];
    [newBuoy setTime:[NSString stringWithFormat:@"%ld:%@", (long)convertedHour, minute]];
    
    // Period and wind direction values
    [newBuoy setDominantPeriod:[rawData objectAtIndex:baseOffset+DPD_OFFSET]];
    [newBuoy setDirection:[rawData objectAtIndex:baseOffset+DIRECTION_OFFSET]];
    
    // Water Temperature Values converted from celsius to fahrenheit
    double waterTemp = (([[rawData objectAtIndex:baseOffset+TEMPERATURE_OFFSET] doubleValue] * (9.0 / 5.0) +32.0 ) / 0.05) * 0.05;
    [newBuoy setWaterTemperature:[NSString stringWithFormat:@"%4.2f", waterTemp]];
    
    // Change the wave height to feet
    NSString *wv = [rawData objectAtIndex:baseOffset+WVHT_OFFSET];
    double h = [wv doubleValue]*3.28;
    
    // Set the wave height
    [newBuoy setWaveHeight:[NSString stringWithFormat:@"%2.2f", h]];
    
    return newBuoy;
}

- (BOOL) check24HourClock {
    // Slightly different than the ofrecast model check.. not caching the value at all
    NSLocale *locale = [NSLocale currentLocale];
    NSString *dateCheck = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:locale];
    return ([dateCheck rangeOfString:@"a"].location == NSNotFound);
}

@end