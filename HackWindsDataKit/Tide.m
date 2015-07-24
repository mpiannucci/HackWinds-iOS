//
//  Tide.m
//  HackWinds
//
//  Created by Matthew Iannucci on 7/27/14.
//  Copyright (c) 2014 Matthew Iannucci. All rights reserved.
//

#import "Tide.h"

@implementation Tide

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
