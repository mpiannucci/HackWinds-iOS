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
        self.Time = [aDecoder decodeObjectForKey:@"time"];
        self.EventType = [aDecoder decodeObjectForKey:@"eventType"];
        self.Height = [aDecoder decodeObjectForKey:@"height"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.Time forKey:@"time"];
    [aCoder encodeObject:self.EventType forKey:@"eventType"];
    [aCoder encodeObject:self.Height forKey:@"height"];
}

- (BOOL) isSunrise {
    if ([self.EventType isEqualToString:SUNRISE_TAG]) {
        return YES;
    }
    return NO;
}

- (BOOL) isSunset {
    if ([self.EventType isEqualToString:SUNSET_TAG]) {
        return YES;
    }
    return NO;
}

- (BOOL) isSolarEvent {
    return ([self isSunrise] || [self isSunset]);
}

- (BOOL) isHighTide {
    if ([self.EventType isEqualToString:HIGH_TIDE_TAG]) {
        return YES;
    }
    return NO;
}

- (BOOL) isLowTide {
    if ([self.EventType isEqualToString:LOW_TIDE_TAG]) {
        return YES;
    }
    return NO;
}

- (BOOL) isTidalEvent {
    return ([self isHighTide] || [self isLowTide]);
}

@end
