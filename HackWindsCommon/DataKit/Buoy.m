//
//  Buoy.m
//  HackWinds
//
//  Created by Matthew Iannucci on 10/9/14.
//  Copyright (c) 2014 Matthew Iannucci. All rights reserved.
//
#define WIND_DIRS [NSArray arrayWithObjects:@"N", @"NNE", @"NE", @"ENE", @"E", @"ESE", @"SE", @"SSE", @"S", @"SSW", @"SW", @"WSW", @"W", @"WNW", @"NW", @"NNW", nil]

#import "Buoy.h"

@implementation Buoy

- (id)init {
    self = [super init];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.timestamp = [aDecoder decodeObjectForKey:@"time"];
        self.significantWaveHeight = [aDecoder decodeObjectForKey:@"significantWaveHeight"];
        self.swellWaveHeight = [aDecoder decodeObjectForKey:@"swellWaveHeight"];
        self.windWaveHeight = [aDecoder decodeObjectForKey:@"windWaveHeight"];
        self.dominantPeriod = [aDecoder decodeObjectForKey:@"dominantPeriod"];
        self.swellPeriod = [aDecoder decodeObjectForKey:@"swellPeriod"];
        self.windWavePeriod = [aDecoder decodeObjectForKey:@"windWavePeriod"];
        self.steepness = [aDecoder decodeObjectForKey:@"steepness"];
        self.meanDirection = [aDecoder decodeObjectForKey:@"meanDirection"];
        self.swellDirection = [aDecoder decodeObjectForKey:@"swellDirection"];
        self.windWaveDirection = [aDecoder decodeObjectForKey:@"windWaveDirection"];
        self.waterTemperature = [aDecoder decodeObjectForKey:@"waterTemperature"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.timestamp forKey:@"time"];
    [aCoder encodeObject:self.significantWaveHeight forKey:@"significantWaveHeight"];
    [aCoder encodeObject:self.swellWaveHeight forKey:@"swellWaveHeight"];
    [aCoder encodeObject:self.windWaveHeight forKey:@"windWaveHeight"];
    [aCoder encodeObject:self.dominantPeriod forKey:@"dominantPeriod"];
    [aCoder encodeObject:self.swellPeriod forKey:@"swellPeriod"];
    [aCoder encodeObject:self.windWavePeriod forKey:@"windWavePeriod"];
    [aCoder encodeObject:self.steepness forKey:@"steepness"];
    [aCoder encodeObject:self.meanDirection forKey:@"meanDirection"];
    [aCoder encodeObject:self.swellDirection forKey:@"swellDirection"];
    [aCoder encodeObject:self.windWaveDirection forKey:@"windWaveDirection"];
    [aCoder encodeObject:self.waterTemperature forKey:@"waterTemperature"];
}

- (NSString *) timeString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeStyle = NSDateFormatterShortStyle;
    formatter.locale = [NSLocale currentLocale];
    return [formatter stringFromDate:self.timestamp];
}

- (NSString *) dateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.locale = [NSLocale currentLocale];
    return [formatter stringFromDate:self.timestamp];
}

- (void) interpolateDominantPeriod {
    if (self.steepness == nil) {
        return;
    }
    
    if ([self.steepness isEqualToString:@"SWELL"] || [self.steepness isEqualToString:@"AVERAGE"]) {
        self.dominantPeriod = self.swellPeriod;
    } else {
        self.dominantPeriod = self.windWavePeriod;
    }
}

- (void) interpolateMeanDirection {
    if (self.swellDirection == nil || self.windWaveDirection == nil) {
        return;
    }
    
    double period = [self.dominantPeriod doubleValue];
    double swellPeriod = [self.swellPeriod doubleValue];
    double windPeriod = [self.windWavePeriod doubleValue];
    
    if (fabs(period - windPeriod) > fabs(period - swellPeriod)) {
        self.meanDirection = self.swellDirection;
    } else {
        self.meanDirection = self.windWaveDirection;
    }
}

- (NSString*) getWaveSummaryStatusText {
    return [NSString stringWithFormat:@"%@ ft @ %@ s %@", self.significantWaveHeight, self.dominantPeriod, self.meanDirection];
}

- (NSString*) getDominantSwellText {
    if ([self.steepness isEqualToString:@"SWELL"] || [self.steepness isEqualToString:@"AVERAGE"]) {
        return [NSString stringWithFormat:@"%@ ft @ %@ s %@", self.swellWaveHeight, self.swellPeriod, self.swellDirection];
    } else {
        return [NSString stringWithFormat:@"%@ ft @ %@ s %@", self.windWaveHeight, self.windWavePeriod, self.windWaveDirection];
    }
}

- (NSString*) getSecondarySwellText {
    if ([self.steepness isEqualToString:@"SWELL"] || [self.steepness isEqualToString:@"AVERAGE"]) {
        return [NSString stringWithFormat:@"%@ ft @ %@ s %@", self.windWaveHeight, self.windWavePeriod, self.windWaveDirection];
    } else {
        if ([self.swellPeriod isEqualToString:@"MM"]) {
            return @"";
        } else {
            return [NSString stringWithFormat:@"%@ ft @ %@ s %@", self.swellWaveHeight, self.swellPeriod, self.swellDirection];
        }
    }
}

+ (NSString*) getCompassDirection:(NSString*)degreeDirection {
    // Set the direction to its letter value on a compass
    int windIndex = (int)[degreeDirection doubleValue]/(360/[WIND_DIRS count]);
    if (windIndex >= [WIND_DIRS count]) {
        // Quick hack to make sure it never crashes because of a precision error.
        // Basically if its larger than NNW, just assume North
        windIndex = 0;
    }
    return [WIND_DIRS objectAtIndex:windIndex];
}


@end