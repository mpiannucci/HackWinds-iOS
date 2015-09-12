//
//  TideModel.m
//  HackWinds
//
//  Created by Matthew Iannucci on 12/14/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//
#define WUNDERGROUND_URL [NSURL URLWithString:@"http://api.wunderground.com/api/2e5424aab8c91757/tide/q/RI/Point_Judith.json"]

#import "TideModel.h"

@interface TideModel ()

// Private methods
- (NSArray*) retrieveTideDataArray;
- (Tide*) getTideObjectAtIndex:(int)index fromData:(NSArray*)rawTideData;
- (BOOL) parseTideData;
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
    self.tides = [NSMutableArray arrayWithCapacity:6];
    
    return self;
}

- (BOOL) fetchTideData {
    @synchronized(self) {
        if ([self.tides count] == 0) {
            // If theres no data yet, load the Wunderground Data and parse it asynchronously
            return [self parseTideData];
        } else {
            return YES;
        }
    }
}

- (void) resetData {
    [self.tides removeAllObjects];
}

- (BOOL) parseTideData {
    NSArray *tideSummary = [self retrieveTideDataArray];
    if (tideSummary == nil) {
        return NO;
    }
    
    // Loop through the data and sort it into Tide objects
    int count = 0;
    int i = 0;
    while (count < 6) {
        // Get the tide object for the index
        Tide *thisTide = [self getTideObjectAtIndex:i fromData:tideSummary];
        
        if ([thisTide isTidalEvent] || [thisTide isSolarEvent]) {
            // Add the tide object to the array
            [self.tides addObject:thisTide];
            
            // Increment the count of the tide objects
            count++;
        }
        i++;
    }
    return YES;
}

+ (Tide*) getLatestTidalEventOnly {
    // Create the model instance
    TideModel *tideModel = [[TideModel alloc] init];
    
    // Fetch the raw tide json summary
    NSArray *tideSummary = [tideModel retrieveTideDataArray];
    
    // Loop through and parse the tide data until a tidal event is found
    Tide *latestTide = [[Tide alloc] init];
    int tideCount = 0;
    while(![latestTide isTidalEvent]) {
        latestTide = [tideModel getTideObjectAtIndex:tideCount fromData:tideSummary];
        tideCount++;
    }
    
    return latestTide;
}

- (NSArray*) retrieveTideDataArray {
    // Get the data from the wunderground api
    NSData* data = [NSData dataWithContentsOfURL:WUNDERGROUND_URL];
    
    // If theres no data return false
    if (data == nil) {
        return NULL;
    }
    
    //parse out the Wunderground json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:data
                          options:kNilOptions
                          error:&error];
    NSArray* tideSummary = [[json objectForKey:@"tide"] objectForKey:@"tideSummary"];
    return tideSummary;
}

- (Tide*) getTideObjectAtIndex:(int)index fromData:(NSArray*)rawtideData {
    // Get the data type and timestamp
    NSDictionary* thisTide = [rawtideData objectAtIndex:index];
    NSString* dataType = [[thisTide objectForKey:@"data"] objectForKey:@"type"];
    NSString* height = [[thisTide objectForKey:@"data"] objectForKey:@"height"];
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
        [tide setTime:time];
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