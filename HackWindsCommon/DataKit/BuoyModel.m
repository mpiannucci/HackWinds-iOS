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
#define BI_BUOY_NUMBER 44097
#define MTK_BUOY_NUMBER 44017
#define ACK_BUOY_NUMBER 44008

#import "BuoyModel.h"
#import "BuoyDataContainer.h"
#import "XMLReader.h"

@interface BuoyModel ()

// Private methods
- (void) initBuoyContainers;
- (BOOL) parseBuoyData;
- (NSArray*) retrieveBuoyData:(BOOL)isDetailed;
- (BOOL) getBuoySummaryForIndex:(int)index FromData:(NSArray*)rawData FillBuoy:(Buoy*)buoy;
- (BOOL) getBuoyDetailsForIndex:(int)index FromData:(NSArray*)rawData FillBuoy:(Buoy*)buoy;
- (NSInteger) getCorrectedHourValue:(NSInteger)rawHour;
- (double) getFootConvertedFromMetric:(double)metricValue;
- (BOOL) check24HourClock;

// Private members
@property (strong, nonatomic) NSUserDefaults *defaults;
@property (strong, nonatomic) NSMutableDictionary *buoyDataContainers;

@end

@implementation BuoyModel
{
    int timeOffset;
    BuoyDataContainer *currentContainer;
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
    
    // Grab the latest user defaults
    self.defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.nucc.HackWinds"];
    [self.defaults synchronize];
    
    // Register to listen for the location being changed
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeBuoyLocation)
                                                 name:BUOY_LOCATION_CHANGED_TAG
                                               object:nil];
    
    // Initilize the location state
    [self changeBuoyLocation];
    
    return self;
}

- (void) initBuoyContainers {
    self.buoyDataContainers = [[NSMutableDictionary alloc] init];
    
    // Block Island
    BuoyDataContainer *biContainer = [[BuoyDataContainer alloc] init];
    biContainer.buoyID = [NSNumber numberWithInt:BI_BUOY_NUMBER];
    [self.buoyDataContainers setValue:biContainer forKey:BLOCK_ISLAND_LOCATION];
    
    // Montauk
    BuoyDataContainer *mtkContainer = [[BuoyDataContainer alloc] init];
    mtkContainer.buoyID = [NSNumber numberWithInt:MTK_BUOY_NUMBER];
    [self.buoyDataContainers setValue:mtkContainer forKey:MONTAUK_LOCATION];
    
    // Nantucket
    BuoyDataContainer *ackContainer = [[BuoyDataContainer alloc] init];
    ackContainer.buoyID = [NSNumber numberWithInt:ACK_BUOY_NUMBER];
    [self.buoyDataContainers setValue:ackContainer forKey:NANTUCKET_LOCATION];
    
}

- (void) changeBuoyLocation {
    [self.defaults synchronize];
    
    // Get the correct container and send out the notification for everything to update
    currentContainer = [self.buoyDataContainers objectForKey:[self.defaults objectForKey:@"BuoyLocation"]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]
         postNotificationName:BUOY_DATA_UPDATED_TAG
         object:self];
    });
}

- (void) forceChangeLocation:(NSString *)location {
    // Get the correct container and send out the notification for everything to update
    currentContainer = [self.buoyDataContainers objectForKey:location];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]
         postNotificationName:BUOY_DATA_UPDATED_TAG
         object:self];
    });
}

- (BOOL) fetchBuoyData {
    @synchronized(self) {
        if (currentContainer.buoyData.count == 0) {
            return [self parseBuoyData];
        } else {
            return YES;
        }
    }
}

- (int) getTimeOffset {
    return timeOffset;
}

- (void) resetData {
    // TODO
}

- (NSMutableArray *) getBuoyData {
    return currentContainer.buoyData;
}

- (NSMutableArray *) getWaveHeightForMode:(NSString *)mode {
    return [currentContainer.waveHeights objectForKey:mode];
}

- (NSURL*) getSpectraPlotURL {
    return [currentContainer createSpectraPlotURL];
}

+ (Buoy*) getOnlyLatestBuoyDataForLocation:(NSString *)location {
    // Get the model instance
    BuoyModel *buoyModel = [[BuoyModel alloc] init];
    
    // For now we are going to force the location to be what the user sets.
    [buoyModel forceChangeLocation:location];
    return [buoyModel fetchLatestBuoyReadingOnly];
}

- (BOOL) parseBuoyData {
    // Get the raw data from ndbc for both detailed and summary mode
    NSArray *rawSummaryBuoyData = [self retrieveBuoyData:NO];
    if (rawSummaryBuoyData == nil) {
        return NO;
    }
    
    NSArray *rawDetailedBuoyData = [self retrieveBuoyData:YES];
    if (rawDetailedBuoyData == nil) {
        return NO;
    }
    
    int dataPointCount = 0;
    while (dataPointCount < BUOY_DATA_POINTS) {
        // Get the next buoy object
        Buoy *newBuoy = [[Buoy alloc] init];
        
        // Fill the buoys from the raw data
        [self getBuoySummaryForIndex:dataPointCount FromData:rawSummaryBuoyData FillBuoy:newBuoy];
        [self getBuoyDetailsForIndex:dataPointCount FromData:rawDetailedBuoyData FillBuoy:newBuoy];
        dataPointCount++;
        
        // Add the buoy to the array
        [currentContainer.buoyData addObject:newBuoy];
        
        // Add all of the correct wave hieght objects
        [[currentContainer.waveHeights objectForKey:SUMMARY_DATA_MODE] addObject:[NSString stringWithFormat:@"%@", newBuoy.SignificantWaveHeight]];
        [[currentContainer.waveHeights objectForKey:SWELL_DATA_MODE] addObject:[NSString stringWithFormat:@"%@", newBuoy.SwellWaveHeight]];
        [[currentContainer.waveHeights objectForKey:WIND_DATA_MODE] addObject:[NSString stringWithFormat:@"%@", newBuoy.WindWaveHeight]];
    }
    return YES;
}

- (NSArray*) retrieveBuoyData:(BOOL)isDetailed {
    // Get the buoy data
    NSError *err = nil;
    
    // Get the buoy data
    NSURL *dataURL = [[NSURL alloc] init];
    if (isDetailed) {
        dataURL = [currentContainer createDetailedWaveDataURL];
    } else {
        dataURL = [currentContainer createStandardMeteorologicalDataURL];
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

- (Buoy *) fetchLatestBuoyReadingOnly {
    // Ignoring errors YOLO
    NSString *rawData = [NSString stringWithContentsOfURL:[currentContainer createLatestReportOnlyURL] encoding:NSUTF8StringEncoding error:nil];
    
    NSError *xmlError;
    NSDictionary *rawBuoyDataDict = [XMLReader dictionaryForXMLString:rawData error:&xmlError];
    if (xmlError != nil) {
        return nil;
    }
    
    NSDictionary *buoyDataDict = [rawBuoyDataDict objectForKey:@"observation"];
    
    // Cast the xml to the buoy item
    Buoy *latestBuoy = [[Buoy alloc] init];
    NSString *rawTime = [[buoyDataDict objectForKey:@"datetime"] objectForKey:@"text"];
    latestBuoy.Time = [self getFormattedTimeFromXMLDateTime:rawTime];
    latestBuoy.SignificantWaveHeight = [[buoyDataDict objectForKey:@"waveht"] objectForKey:@"text"];
    latestBuoy.DominantPeriod = [[buoyDataDict objectForKey:@"domperiod"] objectForKey:@"text"];
    latestBuoy.MeanDirection = [Buoy getCompassDirection:[[buoyDataDict objectForKey:@"meanwavedir"] objectForKey:@"text" ]];
    return latestBuoy;
}

- (NSString *) getFormattedTimeFromXMLDateTime:(NSString*) datetime {
    NSArray *timeComponents = [[[[[datetime componentsSeparatedByString:@"T"]
                                                         objectAtIndex:1]
                                           componentsSeparatedByString:@"U"]
                                                         objectAtIndex:0]
                                           componentsSeparatedByString:@":"];
    
    NSInteger rawHour = [[timeComponents objectAtIndex:0] integerValue];
    NSInteger rawMinute = [[timeComponents objectAtIndex:1] integerValue];
    
    NSInteger adjustedHour = [self getCorrectedHourValue:rawHour + [self getTimeOffset]];
    
    return [NSString stringWithFormat:@"%ld:%ld", (long)adjustedHour, (long)rawMinute];
    
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