//
//  TideModel.m
//  HackWinds
//
//  Created by Matthew Iannucci on 12/14/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//
#define WUNDERGROUND_URL [NSURL URLWithString:@"http://api.wunderground.com/api/2e5424aab8c91757/tide/q/RI/Point_Judith.json"]

#import "TideModel.h"
#import "Tide.h"

@interface TideModel ()

// Private methods
- (bool) parseTideData:(NSData *)responseData;
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
    if ([self.tides count] == 0) {
        // If theres no data yet, load the Wunderground Data and parse it asynchronously
        NSData* data = [NSData dataWithContentsOfURL:WUNDERGROUND_URL];
        return [self parseTideData:data];
    } else {
        return YES;
    }
}

- (void) resetData {
    [self.tides removeAllObjects];
}

- (bool) parseTideData:(NSData *)responseData {
    // If theres no data return false
    if (responseData == nil) {
        return NO;
    }
    
    //parse out the Wunderground json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:kNilOptions
                          error:&error];
    // Quick log to check the amount of json objects recieved
    NSArray* tideSummary = [[json objectForKey:@"tide"] objectForKey:@"tideSummary"];
    
    // Loop through the data and sort it into Tide objects
    int count = 0;
    int i = 0;
    while (count < 6) {
        
        // Get the data type and timestamp
        NSDictionary* thisTide = [tideSummary objectAtIndex:i];
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
        if ([dataType isEqualToString:SUNRISE_TAG] ||
            [dataType isEqualToString:SUNSET_TAG] ||
            [dataType isEqualToString:HIGH_TIDE_TAG] ||
            [dataType isEqualToString:LOW_TIDE_TAG]) {
            
            // Create the new tide object
            Tide* tide = [[Tide alloc] init];
            [tide setEventType:dataType];
            [tide setTime:time];
            [tide setHeight:height];
            
            // Add the tide to the array
            [self.tides addObject:tide];
            
            // Increment the count of the tide objects
            count++;
        }
        i++;
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