//
//  Tide.m
//  HackWinds
//
//  Created by Matthew Iannucci on 7/27/14.
//  Copyright (c) 2014 Matthew Iannucci. All rights reserved.
//

#import "Tide.h"

// Define Constants
NSString * const LOW_TIDE_TAG = @"Low Tide";
NSString * const HIGH_TIDE_TAG = @"High Tide";
NSString * const SUNRISE_TAG = @"Sunrise";
NSString * const SUNSET_TAG = @"Sunset";

@implementation Tide

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.timestamp = [aDecoder decodeObjectForKey:@"time"];
        self.eventType = [aDecoder decodeObjectForKey:@"eventType"];
        self.height = [aDecoder decodeObjectForKey:@"height"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.timestamp forKey:@"time"];
    [aCoder encodeObject:self.eventType forKey:@"eventType"];
    [aCoder encodeObject:self.height forKey:@"height"];
}

- (NSString*)getTideEventSummary {
    return [NSString stringWithFormat:@"%@: %@", self.eventType, self.timestamp];
}

- (BOOL) isSunrise {
    if ([self.eventType isEqualToString:SUNRISE_TAG]) {
        return YES;
    }
    return NO;
}

- (BOOL) isSunset {
    if ([self.eventType isEqualToString:SUNSET_TAG]) {
        return YES;
    }
    return NO;
}

- (BOOL) isSolarEvent {
    return ([self isSunrise] || [self isSunset]);
}

- (BOOL) isHighTide {
    if ([self.eventType isEqualToString:HIGH_TIDE_TAG]) {
        return YES;
    }
    return NO;
}

- (BOOL) isLowTide {
    if ([self.eventType isEqualToString:LOW_TIDE_TAG]) {
        return YES;
    }
    return NO;
}

- (BOOL) isTidalEvent {
    return ([self isHighTide] || [self isLowTide]);
}

- (double) heightValue {
    if (![self isTidalEvent]) {
        return -5000;
    }
    
    double height;
    NSScanner *heightScanner = [[NSScanner alloc] initWithString:self.height];
    [heightScanner scanDouble:&height];
    return height;
}

@end
