//
//  TideModel.m
//  HackWinds
//
//  Created by Matthew Iannucci on 12/14/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//
#import "TideModel.h"

static NSString * const WUNDERGROUND_URL = @"http://api.wunderground.com/api/2e5424aab8c91757/tide/q/RI/Point_Judith.json";
NSString * const TIDE_DATA_UPDATED_TAG = @"TideModelDataUpdatedNotification";
NSString * const TIDE_DATA_UPDATE_FAILED_TAG = @"TideModelDataUpdateFailedNotification";

@interface TideModel ()

@property (strong, nonatomic) NSMutableArray *dayIds;
@property (strong, nonatomic) NSMutableArray *dayDataCounts;

// Private methods
- (void) fetchRawTideData:(void(^)(NSData*))completionHandler;
- (Tide*) getTideObjectAtIndex:(int)index fromData:(NSArray*)rawTideData;
- (BOOL) parseTideDataFromData:(NSData*)rawData;
- (BOOL) check24HourClock;

@end

@implementation TideModel

+ (instancetype) sharedModel {
    static TideModel *_sharedModel = nil;
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
    
    // Array to load the data into
    self.tides = [[NSMutableArray alloc] init];
    self.dayIds = [[NSMutableArray alloc] initWithCapacity:4];
    self.dayDataCounts = [[NSMutableArray alloc] initWithCapacity:4];
    self.dayCount = [NSNumber numberWithInt:0];
    
    return self;
}

- (void) fetchRawTideData:(void(^)(NSData*))completionHandler {
    NSURLSessionTask *tideTask = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:WUNDERGROUND_URL] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error != nil) {
            NSLog(@"Failed to retreive tide data from API");
            
            // Send failure notification
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:TIDE_DATA_UPDATE_FAILED_TAG
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
                 postNotificationName:TIDE_DATA_UPDATE_FAILED_TAG
                 object:self];
            });
            
            return;
        }
        
        completionHandler(data);
    }];
    
    [tideTask resume];
}

- (void) fetchTideData {
    @synchronized(self) {
        if (self.tides.count != 0) {
            // Tell everything you have tide data
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:TIDE_DATA_UPDATED_TAG
                 object:self];
            });
            return;
        }
        
        [self fetchRawTideData:^(NSData *data) {
            // Parse the data
            BOOL parsedTides = [self parseTideDataFromData:data];
            
            // Tell all the listeners to update
            if (parsedTides) {
                // Tell everything you have tide data
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:TIDE_DATA_UPDATED_TAG
                     object:self];
                });
            }
        }];
    }
}

- (void) fetchLatestTidalEventOnly:(void(^)(Tide*))completionHandler {
    
    // Check if data already exist and we can skip the parse and network request
    if (self.tides.count != 0) {
        completionHandler([self.tides objectAtIndex:0]);
        return;
    }
    
    [self fetchRawTideData:^(NSData* data) {
        // Parse out the Wunderground json data
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:data
                              options:kNilOptions
                              error:&error];
        if (error != nil) {
            return;
        }
        NSArray* tideSummary = [[json objectForKey:@"tide"] objectForKey:@"tideSummary"];
        if (tideSummary == nil) {
            return;
        }
        
        // Loop through and parse the tide data until a tidal event is found
        Tide *latestTide = [[Tide alloc] init];
        int tideCount = 0;
        while(![latestTide isTidalEvent]) {
            latestTide = [self getTideObjectAtIndex:tideCount fromData:tideSummary];
            tideCount++;
        }
        
        // Trigger the callback
        completionHandler(latestTide);
    }];
}

- (void) resetData {
    [self.tides removeAllObjects];
    self.dayCount = [NSNumber numberWithInt:0];
    [self.dayDataCounts removeAllObjects];
    [self.dayIds removeAllObjects];
}

- (int) dataCountForIndex:(int)index {
    return [[self.dayDataCounts objectAtIndex:index] intValue];
}

- (Tide*) tideDataAtIndex:(int)index forDay:(int)dayIndex {
    int totalIndex = 0;
    for (int day = 0; day < dayIndex; day++) {
        totalIndex += [[self.dayDataCounts objectAtIndex:day] intValue];
    }
    totalIndex += index;
    return [self.tides objectAtIndex:totalIndex];
}

- (BOOL) parseTideDataFromData:(NSData *)rawData {
    //parse out the Wunderground json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:rawData
                          options:kNilOptions
                          error:&error];
    if (error != nil) {
        return NO;
    }
    
    NSArray* tideSummary = [[json objectForKey:@"tide"] objectForKey:@"tideSummary"];
    if (tideSummary == nil) {
        return NO;
    }
    
    // Loop through the data and sort it into Tide objects
    int dayCount = 0;
    int currentDataDataCount = 0;
    NSString *currentDay = @"";
    for (int i = 0; i < tideSummary.count; i++) {
        // Get the tide object for the index
        Tide *thisTide = [self getTideObjectAtIndex:i fromData:tideSummary];
        
        if ([thisTide isTidalEvent] || [thisTide isSolarEvent]) {
            // Add the tide object to the array
            if (![currentDay isEqualToString:thisTide.day]) {
                dayCount++;
                currentDay = thisTide.day;
                [self.dayIds addObject:currentDay];
                
                if (dayCount != 1) {
                    [self.dayDataCounts addObject:[NSNumber numberWithInt:currentDataDataCount]];
                    currentDataDataCount = 0;
                }
            }
            [self.tides addObject:thisTide];
            currentDataDataCount++;
        }
        [self.dayDataCounts addObject:[NSNumber numberWithInt:currentDataDataCount]];
        self.dayCount = [NSNumber numberWithInt:dayCount];
    }
    return YES;
}

- (Tide*) getTideObjectAtIndex:(int)index fromData:(NSArray*)rawtideData {
    // Get the data type and timestamp
    NSDictionary* thisTide = [rawtideData objectAtIndex:index];
    NSString* dataType = [[thisTide objectForKey:@"data"] objectForKey:@"type"];
    NSString* height = [[thisTide objectForKey:@"data"] objectForKey:@"height"];
    NSString* day = [[thisTide objectForKey:@"date"] objectForKey:@"mday"];
    NSString* hour = [[thisTide objectForKey:@"date"] objectForKey:@"hour"];
    NSString* minute = [[thisTide objectForKey:@"date"] objectForKey:@"min"];
    NSString *ampm = @"";
    
    if (![self check24HourClock]) {
        long hourValue = [hour integerValue];
        
        // Check am, pm
        if (hourValue < 12) {
            ampm = @"am";
        } else {
            ampm = @"pm";
        }
        
        NSInteger convertedHour = hourValue % 12;
        if (convertedHour == 0) {
            convertedHour = 12;
        }
        
        // Convert to twelve hour
        hour = [NSString stringWithFormat:@"%ld", (long)convertedHour];
    }
    
    // Create the tide string
    NSString* time = [NSString stringWithFormat:@"%@:%@ %@", hour, minute, ampm];
    
    // Check for the type and set it to the object. We dont care about anything but these tidal events
    Tide* tide = [[Tide alloc] init];
    if ([dataType isEqualToString:SUNRISE_TAG] ||
        [dataType isEqualToString:SUNSET_TAG] ||
        [dataType isEqualToString:HIGH_TIDE_TAG] ||
        [dataType isEqualToString:LOW_TIDE_TAG]) {
        
        // Create the new tide object
        [tide setEventType:dataType];
        [tide setDay:day];
        [tide setTimestamp:time];
        [tide setHeight:height];
    } else {
        [tide setEventType:@"Invalid"];
    }
    return tide;
}

- (BOOL)check24HourClock {
    // Slightly different than the ofrecast model check.. not caching the value at all
    NSLocale *locale = [NSLocale currentLocale];
    NSString *dateCheck = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:locale];
    return ([dateCheck rangeOfString:@"a"].location == NSNotFound);
}

@end