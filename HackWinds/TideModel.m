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
    _tides = [[NSMutableArray alloc] init];
    
    return self;
}

- (NSMutableArray*) getTideData {
    if ([_tides count] == 0) {
        // If theres no data yet, load the Wunderground Data and parse it asynchronously
        NSData* data = [NSData dataWithContentsOfURL:WUNDERGROUND_URL];
        [self parseTideData:data];
    }
    
    // Return the tide array
    return _tides;
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
        
        // Create the tide string
        NSString* time = [NSString stringWithFormat:@"%@:%@", hour, minute];
        
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
            [_tides addObject:tide];
            
            // Increment the count of the tide objects
            count++;
        }
        i++;
    }
    return YES;
}

@end
