//
//  BuoyModel.m
//  HackWinds
//
//  Created by Matthew Iannucci on 12/14/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//

#import "BuoyModel.h"
#import "BuoyDataContainer.h"
#import "XMLReader.h"

// Global Constants
NSString * const BLOCK_ISLAND_LOCATION = @"Block Island";
NSString * const MONTAUK_LOCATION = @"Montauk";
NSString * const NANTUCKET_LOCATION =  @"Nantucket";
NSString * const SUMMARY_DATA_MODE = @"Summary";
NSString * const SWELL_DATA_MODE = @"Swell";
NSString * const WIND_DATA_MODE = @"Wind Wave";
NSString * const BUOY_DATA_UPDATED_TAG = @"BuoyModelDidUpdateDataNotification";
NSString * const BUOY_LOCATION_CHANGED_TAG = @"BuoyLocationChangedNotification";
NSString * const DEFAULT_BUOY_LOCATION_CHANGED_TAG = @"DefaultBuoyLocationChangedNotification";
NSString * const BUOY_UPDATE_FAILED_TAG = @"BuoyModelUpdatedFailedNotification";

// Detail data locations
static const int DETAIL_DATA_HEADER_LENGTH = 30;
static const int DETAIL_DATA_LINE_LENGTH = 15;
static const int DETAIL_HOUR_OFFSET = 3;
static const int DETAIL_MINUTE_OFFSET = 4;
static const int DETAIL_WVHT_OFFSET = 5;
static const int DETAIL_SWELL_WAVE_HEIGHT_OFFSET = 6;
static const int DETAIL_SWELL_PERIOD_OFFSET = 7;
static const int DETAIL_WIND_WAVE_HEIGHT_OFFSET  = 8;
static const int DETAIL_WIND_PERIOD_OFFSET = 9;
static const int DETAIL_SWELL_DIRECTION_OFFSET = 10;
static const int DETAIL_WIND_WAVE_DIRECTION_OFFSET = 11;
static const int DETAIL_STEEPNESS_OFFSET = 12;
static const int DETAIL_MEAN_WAVE_DIRECTION_OFFSET = 14;

// URLs
static const int BI_BUOY_NUMBER = 44097;
static const int MTK_BUOY_NUMBER = 44017;
static const int ACK_BUOY_NUMBER = 44008;

@interface BuoyModel ()

// Private methods
- (void) initBuoyContainers;
- (void) fetchRawBuoyDataFromURL:(NSURL*)url withCompletionHandler:(void(^)(NSData*))completionHandler;
- (BOOL) parseBuoyData:(NSData*)rawBuoyData;
- (Buoy*) parseLatestBuoyData:(NSData*)rawBuoyData;
- (NSURL *) getCurrentLatestBuoyDataURL;
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
    self.defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.mpiannucci.HackWinds"];
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
- (NSURL *) getCurrentLatestBuoyDataURL {
    return [currentContainer createLatestReportOnlyURL];
}

- (NSURL*) getSpectraPlotURL {
    return [currentContainer createSpectraPlotURL];
}

- (void) changeBuoyLocation {
    [self.defaults synchronize];
    
    // Get the correct container and send out the notification for everything to update
    currentContainer = [self.buoyDataContainers objectForKey:[self.defaults objectForKey:@"BuoyLocation"]];
    
    [self fetchBuoyData];
}

- (void) forceChangeLocation:(NSString *)location {
    // Get the correct container and send out the notification for everything to update
    currentContainer = [self.buoyDataContainers objectForKey:location];
    
    // NOTE: For the force we dont automatically refetch
}

- (void) fetchRawBuoyDataFromURL:(NSURL*)url withCompletionHandler:(void(^)(NSData*))completionHandler {
    NSURLSessionTask *tideTask = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error != nil) {
            NSLog(@"Failed to retreive tide data from API");
            
            // Send failure notification
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:BUOY_UPDATE_FAILED_TAG
                 object:self];
            });
            
            return;
        }
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        if (httpResponse.statusCode != 200) {
            NSLog(@"HTTP Error receiving buoy data");
            
            // Send failure notification
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:BUOY_UPDATE_FAILED_TAG
                 object:self];
            });
            
            return;
        }
        
        completionHandler(data);
    }];
    
    [tideTask resume];
}

- (void) fetchBuoyData {
    @synchronized(self) {
        if (currentContainer.buoyData.count != 0) {
            // Tell everything you have buoy data
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:BUOY_DATA_UPDATED_TAG
                 object:self];
            });
            return;
        }
        
        [self fetchRawBuoyDataFromURL:[currentContainer createDetailedWaveDataURL] withCompletionHandler:^(NSData *data) {
            BOOL parsedBuoys = [self parseBuoyData:data];
            
            if (parsedBuoys) {
                // Tell everything you have buoy data
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:BUOY_DATA_UPDATED_TAG
                     object:self];
                });
            }
        }];
        
    }
}

- (void) fetchLatestBuoyReading {
    [self fetchRawBuoyDataFromURL:[self getCurrentLatestBuoyDataURL] withCompletionHandler:^(NSData *rawData) {
        Buoy *latestBuoy = [self parseLatestBuoyData:rawData];
        
        if (latestBuoy == nil) {
            return;
        }
        
        // Only add the buoy to the list if there are no other buoys read in yet
        if (currentContainer.buoyData.count == 0) {
            [currentContainer.buoyData addObject:latestBuoy];
        } else {
            Buoy *firstBuoy = [currentContainer.buoyData objectAtIndex:0];
            
            // Merge the latest buoy props that werent read in with the detailed wave read.
            firstBuoy.waterTemperature = latestBuoy.waterTemperature;
        }
        
        // Tell everything you have buoy data
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]
             postNotificationName:BUOY_DATA_UPDATED_TAG
             object:self];
        });
        
    }];
}

- (void) fetchLatestBuoyReadingForLocation:(NSString *)location withCompletionHandler:(void (^)(Buoy *))completionHandler {
    NSString *originalLocation = [self.defaults objectForKey:@"BuoyLocation"];
    [self forceChangeLocation:location];
    
    [self fetchRawBuoyDataFromURL:[self getCurrentLatestBuoyDataURL] withCompletionHandler:^(NSData *rawData) {
        Buoy *latestBuoy = [self parseLatestBuoyData:rawData];
        
        // Pass the buoy down to the completion handler
        completionHandler(latestBuoy);
    }];
    
    [self forceChangeLocation:originalLocation];
}

- (BOOL) parseBuoyData:(NSData*)rawBuoyData {
    // Parse the data
    NSString *rawData = [[NSString alloc] initWithData:rawBuoyData encoding:NSUTF8StringEncoding];
    
    // Strip everything thats not relevant
    NSCharacterSet *whitespaces = [NSCharacterSet whitespaceCharacterSet];
    NSPredicate *noEmptyStrings = [NSPredicate predicateWithFormat:@"SELF != ''"];
    NSArray *parts = [rawData componentsSeparatedByCharactersInSet:whitespaces];
    NSArray *filteredArray = [parts filteredArrayUsingPredicate:noEmptyStrings];
    rawData = [filteredArray componentsJoinedByString:@" "];
    NSArray *rawBuoyArray = [rawData componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (rawBuoyArray == nil) {
        return NO;
    }
    
    int dataPointCount = 0;
    while (dataPointCount < BUOY_DATA_POINTS) {
        // Get the next buoy object
        Buoy *newBuoy = [[Buoy alloc] init];
        
        // Get the line index to parse this buoy from
        int baseOffset = DETAIL_DATA_HEADER_LENGTH + (DETAIL_DATA_LINE_LENGTH * dataPointCount);
        if (baseOffset >= (DETAIL_DATA_HEADER_LENGTH+(DETAIL_DATA_LINE_LENGTH*BUOY_DATA_POINTS))) {
            return NO;
        }
        
        // Get the time value from the file, make sure that the hour offset is correct for the regions daylight savings
        NSInteger originalHour = [[rawBuoyArray objectAtIndex:baseOffset+DETAIL_HOUR_OFFSET] integerValue] + [self getTimeOffset];
        NSInteger convertedHour = [self getCorrectedHourValue:originalHour];
        
        // Set the time value for the object
        NSString *minute = [rawBuoyArray objectAtIndex:baseOffset+DETAIL_MINUTE_OFFSET];
        newBuoy.timestamp = [NSString stringWithFormat:@"%ld:%@", (long)convertedHour, minute];
        
        // Wave heights
        NSString *significantHeight = [rawBuoyArray objectAtIndex:baseOffset+DETAIL_WVHT_OFFSET];
        NSString *swellHeight = [rawBuoyArray objectAtIndex:baseOffset+DETAIL_SWELL_WAVE_HEIGHT_OFFSET];
        NSString *windHeight = [rawBuoyArray objectAtIndex:baseOffset+DETAIL_WIND_WAVE_HEIGHT_OFFSET];
        newBuoy.significantWaveHeight = [NSString stringWithFormat:@"%2.2f", [self getFootConvertedFromMetric:[significantHeight doubleValue]]];
        newBuoy.swellWaveHeight = [NSString stringWithFormat:@"%2.2f", [self getFootConvertedFromMetric:[swellHeight doubleValue]]];
        newBuoy.windWaveHeight = [NSString stringWithFormat:@"%2.2f", [self getFootConvertedFromMetric:[windHeight doubleValue]]];
        
        // Steepness
        newBuoy.steepness = [rawBuoyArray objectAtIndex:baseOffset+DETAIL_STEEPNESS_OFFSET];
        
        // Periods
        newBuoy.swellPeriod = [rawBuoyArray objectAtIndex:baseOffset+DETAIL_SWELL_PERIOD_OFFSET];
        newBuoy.windWavePeriod = [rawBuoyArray objectAtIndex:baseOffset+DETAIL_WIND_PERIOD_OFFSET];
        [newBuoy interpolateDominantPeriod];
        
        // Directions
        NSString *rawMeanDirection = [rawBuoyArray objectAtIndex:baseOffset+DETAIL_MEAN_WAVE_DIRECTION_OFFSET];
        newBuoy.meanDirection = [Buoy getCompassDirection:rawMeanDirection];
        newBuoy.swellDirection = [rawBuoyArray objectAtIndex:baseOffset+DETAIL_SWELL_DIRECTION_OFFSET];
        newBuoy.windWaveDirection = [rawBuoyArray objectAtIndex:baseOffset+DETAIL_WIND_WAVE_DIRECTION_OFFSET];
        
        // Bump the count
        dataPointCount++;
        
        // Add the buoy to the array
        [currentContainer.buoyData addObject:newBuoy];
        
        // Add all of the correct wave height objects
        [[currentContainer.waveHeights objectForKey:SUMMARY_DATA_MODE] addObject:[NSString stringWithFormat:@"%@", newBuoy.significantWaveHeight]];
        [[currentContainer.waveHeights objectForKey:SWELL_DATA_MODE] addObject:[NSString stringWithFormat:@"%@", newBuoy.swellWaveHeight]];
        [[currentContainer.waveHeights objectForKey:WIND_DATA_MODE] addObject:[NSString stringWithFormat:@"%@", newBuoy.windWaveHeight]];
    }
    
    return YES;
}

- (Buoy*) parseLatestBuoyData:(NSData *)rawBuoyData {
    NSString *rawData = [[NSString alloc] initWithData:rawBuoyData encoding:NSUTF8StringEncoding];
    NSError *xmlError;
    NSDictionary *rawBuoyDataDict = [XMLReader dictionaryForXMLString:rawData error:&xmlError];
    if (xmlError != nil) {
        return nil;
    }
    
    NSDictionary *buoyDataDict = [rawBuoyDataDict objectForKey:@"observation"];
    
    // Cast the xml to the buoy item
    Buoy *latestBuoy = [[Buoy alloc] init];
    NSString *rawTime = [[buoyDataDict objectForKey:@"datetime"] objectForKey:@"text"];
    latestBuoy.timestamp = [self getFormattedTimeFromXMLDateTime:rawTime];
    latestBuoy.significantWaveHeight = [[buoyDataDict objectForKey:@"waveht"] objectForKey:@"text"];
    latestBuoy.dominantPeriod = [[buoyDataDict objectForKey:@"domperiod"] objectForKey:@"text"];
    latestBuoy.meanDirection = [Buoy getCompassDirection:[[buoyDataDict objectForKey:@"meanwavedir"] objectForKey:@"text" ]];
    latestBuoy.waterTemperature = [[buoyDataDict objectForKey:@"watertemp"] objectForKey:@"text"];
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