//
//  BuoyModel.m
//  HackWinds
//
//  Created by Matthew Iannucci on 12/14/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//
#define DATA_POINTS 20
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

#import "BuoyModel.h"
#import "Buoy.h"

@interface BuoyModel ()

// Private methods
- (BOOL) parseBuoyData:(NSNumber* )location;
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
    
    // Initialize the BI and MTK arrays
    self.blockIslandBuoys = [NSMutableArray arrayWithCapacity:DATA_POINTS];
    self.blockIslandWaveHeights = [NSMutableArray arrayWithCapacity:DATA_POINTS];
    self.montaukBuoys = [NSMutableArray arrayWithCapacity:DATA_POINTS];
    self.montaukWaveHeights = [NSMutableArray arrayWithCapacity:DATA_POINTS];
    
    // Check if daylight savings is in effect. Make sure the time scaling is for EST (GMT-5)
    NSTimeZone* eastnTZ = [NSTimeZone timeZoneWithName:@"EST5EDT"];
    int daylightoff = [eastnTZ daylightSavingTimeOffset]/3600;
    timeOffset = -5 + daylightoff;
    
    return self;
}

- (BOOL) fetchBuoyDataForLocation:(int)location {
    if (location == BLOCK_ISLAND_LOCATION) {
        // If they want block island, check if its already been fetched, then return it
        if ([self.blockIslandBuoys count] == 0) {
            return [self parseBuoyData:[NSNumber numberWithInt:BLOCK_ISLAND_LOCATION]];
        } else {
            return YES;
        }
    } else {
        // Do the same for montauk
        if ([self.montaukBuoys count] == 0) {
            return [self parseBuoyData:[NSNumber numberWithInt:MONTAUK_LOCATION]];
        } else {
            return YES;
        }
    }
}

- (NSMutableArray *) getBuoyDataForLocation:(int)location {
    if (location == BLOCK_ISLAND_LOCATION) {
        // If they want block island, check if its already been fetched, then return it
        return self.blockIslandBuoys;
    } else {
        // Do the same for montauk
        return self.montaukBuoys;
    }
}

- (NSMutableArray *) getWaveHeightForLocation:(int)location {
    if (location == BLOCK_ISLAND_LOCATION) {
        // They want block island height
        return self.blockIslandWaveHeights;
    } else {
        // They want montauk heights
        return self.montaukWaveHeights;
    }
}

- (BOOL) parseBuoyData:(NSNumber* )location {
    // Get the buoy data
    NSString* buoyData;
    NSError *err = nil;
    if ([location isEqualToNumber:[NSNumber numberWithInt:BLOCK_ISLAND_LOCATION]]) {
        buoyData = [NSString stringWithContentsOfURL:BI_URL encoding:NSUTF8StringEncoding error:&err];
    } else {
        // Montauk
        buoyData = [NSString stringWithContentsOfURL:MTK_URL encoding:NSUTF8StringEncoding error:&err];
    }
    // If it was unsuccessful, return false
    if (err != nil) {
        return NO;
    }
    
    NSCharacterSet *whitespaces = [NSCharacterSet whitespaceCharacterSet];
    NSPredicate *noEmptyStrings = [NSPredicate predicateWithFormat:@"SELF != ''"];
    NSArray *parts = [buoyData componentsSeparatedByCharactersInSet:whitespaces];
    NSArray *filteredArray = [parts filteredArrayUsingPredicate:noEmptyStrings];
    buoyData = [filteredArray componentsJoinedByString:@" "];
    NSArray* cleanData = [buoyData componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // Parse the data into buoy objects
    for(int i=DATA_HEADER_LENGTH; i<(DATA_HEADER_LENGTH+(DATA_LINE_LEN*DATA_POINTS)); i+=DATA_LINE_LEN) {
        Buoy *newBuoy = [[Buoy alloc] init];
        
        // Get the time value from the file, make sure that the hour offset is correct for the regions daylight savings
        NSInteger originalHour = [[cleanData objectAtIndex:i+HOUR_OFFSET] integerValue] + timeOffset;
        NSInteger convertedHour = 0;
        
        // Formate the hour correctly if the user has 24 hour time enabled
        if ([self check24HourClock]) {
            convertedHour = (originalHour + 24) % 24;
            if (convertedHour == 0) {
                if ((originalHour + timeOffset) > 0) {
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
        NSString *minute = [cleanData objectAtIndex:i+MINUTE_OFFSET];
        [newBuoy setTime:[NSString stringWithFormat:@"%ld:%@", (long)convertedHour, minute]];
        
        // Period and wind direction values
        [newBuoy setDominantPeriod:[cleanData objectAtIndex:i+DPD_OFFSET]];
        [newBuoy setDirection:[cleanData objectAtIndex:i+DIRECTION_OFFSET]];
        
        // Water Temperature Values converted from celsius to fahrenheit
        double waterTemp = (([[cleanData objectAtIndex:i+TEMPERATURE_OFFSET] doubleValue] * (9.0 / 5.0) +32.0 ) / 0.05) * 0.05;
        [newBuoy setWaterTemperature:[NSString stringWithFormat:@"%4.2f", waterTemp]];
        
        // Change the wave height to feet
        NSString *wv = [cleanData objectAtIndex:i+WVHT_OFFSET];
        double h = [wv doubleValue]*3.28;
        
        // Set the wave height
        [newBuoy setWaveHeight:[NSString stringWithFormat:@"%2.2f", h]];
        
        // Append the buoy to the list of buoys
        if ([location isEqualToNumber:[NSNumber numberWithInt:BLOCK_ISLAND_LOCATION]]) {
            // Append to the BI array
            [self.blockIslandBuoys addObject:newBuoy];
            [self.blockIslandWaveHeights addObject:[NSString stringWithFormat:@"%2.2f", h]];
        }  else {
            // Append to the montauk array
            [self.montaukBuoys addObject:newBuoy];
            [self.montaukWaveHeights addObject:[NSString stringWithFormat:@"%2.2f", h]];
        }
    }
    return YES;
}

- (BOOL)check24HourClock {
    // Slightly different than the ofrecast model check.. not caching the value at all
    NSLocale *locale = [NSLocale currentLocale];
    NSString *dateCheck = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:locale];
    return ([dateCheck rangeOfString:@"a"].location == NSNotFound);
}

@end