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
NSString * const NEWPORT_LOCATION = @"Newport";
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
static const int DETAIL_YEAR_OFFSET = 0;
static const int DETAIL_MONTH_OFFSET = 1;
static const int DETAIL_DAY_OFFSET = 2;
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
static NSString * const BI_BUOY_ID = @"44097";
static NSString * const MTK_BUOY_ID = @"44017";
static NSString * const ACK_BUOY_ID = @"44008";
static NSString * const NEWPORT_BUOY_ID = @"nwpr1";

@interface BuoyModel ()

// Private methods
- (void) initBuoyContainers;
- (void) fetchRawBuoyDataFromURL:(NSURL*)url withCompletionHandler:(void(^)(NSData*))completionHandler;
- (BOOL) parseBuoyData:(NSData*)rawBuoyData;
- (Buoy*) parseLatestBuoyData:(NSData*)rawBuoyData;
- (NSURL *) getCurrentLatestBuoyDataURL;
- (double) getFootConvertedFromMetric:(double)metricValue;

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
    biContainer.buoyID = BI_BUOY_ID;
    [self.buoyDataContainers setValue:biContainer forKey:BLOCK_ISLAND_LOCATION];
    
    // Montauk
    BuoyDataContainer *mtkContainer = [[BuoyDataContainer alloc] init];
    mtkContainer.buoyID = MTK_BUOY_ID;
    [self.buoyDataContainers setValue:mtkContainer forKey:MONTAUK_LOCATION];
    
    // Nantucket
    BuoyDataContainer *ackContainer = [[BuoyDataContainer alloc] init];
    ackContainer.buoyID = ACK_BUOY_ID;
    [self.buoyDataContainers setValue:ackContainer forKey:NANTUCKET_LOCATION];
    
    // Newport
    BuoyDataContainer *newportContainer = [[BuoyDataContainer alloc] init];
    newportContainer.buoyID = NEWPORT_BUOY_ID;
    [self.buoyDataContainers setValue:newportContainer forKey:NEWPORT_LOCATION];
}

- (int) getTimeOffset {
    return timeOffset;
}

- (void) resetData {
    [currentContainer.buoyData removeAllObjects];
}

- (NSMutableArray *) getBuoyData {
    return currentContainer.buoyData;
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

- (void) checkForUpdate {
    if ([currentContainer.buoyData count] < 1) {
        return;
    }
    
    if ([[currentContainer.buoyData objectAtIndex:0] timestamp] == nil) {
        return;
    }
    
    NSDate *previousDate = [[currentContainer.buoyData objectAtIndex:0] timestamp];
    NSTimeInterval rawTimeDiff = [[NSDate date] timeIntervalSinceDate:previousDate];
    NSInteger minuteDiff = rawTimeDiff / 60;
    
    if (minuteDiff > [[currentContainer.buoyData objectAtIndex:0] updateInterval]) {
        [self resetData];
    }
}

- (void) fetchRawBuoyDataFromURL:(NSURL*)url withCompletionHandler:(void(^)(NSData*))completionHandler {
    NSURLSessionTask *buoyTask = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
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
    
    [buoyTask resume];
}

- (void) fetchBuoyData {
    @synchronized(self) {
        [self checkForUpdate];
        
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
    @synchronized (self) {
        [self checkForUpdate];
    
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
        
        // Get the raw date values from the data
        NSInteger year = [[rawBuoyArray objectAtIndex:baseOffset+DETAIL_YEAR_OFFSET] integerValue];
        NSInteger month = [[rawBuoyArray objectAtIndex:baseOffset+DETAIL_MONTH_OFFSET] integerValue];
        NSInteger day = [[rawBuoyArray objectAtIndex:baseOffset+DETAIL_DAY_OFFSET] integerValue];
        NSInteger hour = [[rawBuoyArray objectAtIndex:baseOffset+DETAIL_HOUR_OFFSET] integerValue];
        NSInteger minute = [[rawBuoyArray objectAtIndex:baseOffset+DETAIL_MINUTE_OFFSET] integerValue];
        
        // Create and the set the timestamp NSDate object
        NSDateComponents *dateComps = [[NSDateComponents alloc] init];
        dateComps.year = year;
        dateComps.month = month;
        dateComps.day = day;
        dateComps.hour = hour;
        dateComps.minute = minute;
        dateComps.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        newBuoy.timestamp = [calendar dateFromComponents:dateComps];
        
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
        
        // Directions
        NSString *rawMeanDirection = [rawBuoyArray objectAtIndex:baseOffset+DETAIL_MEAN_WAVE_DIRECTION_OFFSET];
        newBuoy.meanDirection = [Buoy getCompassDirection:rawMeanDirection];
        newBuoy.swellDirection = [rawBuoyArray objectAtIndex:baseOffset+DETAIL_SWELL_DIRECTION_OFFSET];
        newBuoy.windWaveDirection = [rawBuoyArray objectAtIndex:baseOffset+DETAIL_WIND_WAVE_DIRECTION_OFFSET];
        
        // Get the dominant period
        [newBuoy interpolateDominantPeriod];
        
        // Bump the count
        dataPointCount++;
        
        // Add the buoy to the array
        [currentContainer.buoyData addObject:newBuoy];
    }
    
    return YES;
}

- (Buoy*) parseLatestBuoyData:(NSData *)rawBuoyData {
    NSString *rawData = [[NSString alloc] initWithData:rawBuoyData encoding:NSASCIIStringEncoding];
    NSArray *rawBuoyArray = [rawData componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    if (rawBuoyArray == nil) {
        return nil;
    } else if (rawBuoyArray.count < 6) {
        return nil;
    }
    
    Buoy *latestBuoy = [[Buoy alloc] init];
    
    // Start with the time
    NSString *rawDateTime = [rawBuoyArray objectAtIndex:4];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HHmm ZZZ MM/dd/yy"];
    latestBuoy.timestamp = [dateFormatter dateFromString:rawDateTime];
    
    BOOL swellPeriodParsed = NO;
    BOOL swellDirectionParsed = NO;
    for (int i = 5; i < rawBuoyArray.count; i++) {
        NSArray *components = [[rawBuoyArray objectAtIndex:i] componentsSeparatedByString:@":"];
        if (components == nil) {
            continue;
        } else if (components.count < 2) {
            continue;
        }
        
        NSString *var = [components objectAtIndex:0];
        NSString *value = [components objectAtIndex:1];
        if ([var isEqualToString:@"Water Temp"]) {
            NSScanner *doubleScanner = [NSScanner scannerWithString:value];
            double value;
            [doubleScanner scanDouble:&value];
            latestBuoy.waterTemperature = [NSString stringWithFormat:@"%2.2f", value];
        } else if ([var isEqualToString:@"Seas"]) {
            NSScanner *doubleScanner = [NSScanner scannerWithString:value];
            double value;
            [doubleScanner scanDouble:&value];
            latestBuoy.significantWaveHeight = [NSString stringWithFormat:@"%2.2f", value];
        } else if ([var isEqualToString:@"Peak Period"]) {
            NSScanner *doubleScanner = [NSScanner scannerWithString:value];
            double value;
            [doubleScanner scanDouble:&value];
            latestBuoy.dominantPeriod = [NSString stringWithFormat:@"%2.2f", value];
        } else if ([var isEqualToString:@"Swell"]) {
            NSScanner *doubleScanner = [NSScanner scannerWithString:value];
            double value;
            [doubleScanner scanDouble:&value];
            latestBuoy.swellWaveHeight = [NSString stringWithFormat:@"%2.2f", value];
            if (fabs(value - 0) < 0.00001) {
                swellPeriodParsed = YES;
                swellDirectionParsed = YES;
            }
        } else if ([var isEqualToString:@"Wind Wave"]) {
            NSScanner *doubleScanner = [NSScanner scannerWithString:value];
            double value;
            [doubleScanner scanDouble:&value];
            latestBuoy.windWaveHeight = [NSString stringWithFormat:@"%2.2f", value];
        } else if ([var isEqualToString:@"Period"]) {
            NSScanner *doubleScanner = [NSScanner scannerWithString:value];
            double value;
            [doubleScanner scanDouble:&value];
            if (!swellPeriodParsed) {
                latestBuoy.swellPeriod = [NSString stringWithFormat:@"%2.2f", value];
                swellPeriodParsed = YES;
            } else {
                latestBuoy.windWavePeriod = [NSString stringWithFormat:@"%2.2f", value];
            }
        } else if ([var isEqualToString:@"Direction"]) {
            if (!swellDirectionParsed) {
                latestBuoy.swellDirection = value;
                swellDirectionParsed = YES;
            } else {
                latestBuoy.windWaveDirection = value;
            }
        }
    }
    
    // Find the wave direction
    [latestBuoy interpolateMeanDirection];
    
    // At a bare minimum water temp needs to be there 
    if (latestBuoy.waterTemperature == nil) {
        return nil;
    }
    
    return latestBuoy;
}

- (double) getFootConvertedFromMetric:(double)metricValue {
    return metricValue * 3.28;
}

@end