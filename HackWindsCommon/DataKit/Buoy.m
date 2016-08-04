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
    formatter.dateStyle = NSDateFormatterMediumStyle;
    formatter.locale = [NSLocale currentLocale];
    return [formatter stringFromDate:self.timestamp];
}

- (void) interpolateDominantPeriod {
    if (self.swellDirection == nil && self.windWaveDirection == nil) {
        return;
    }
    
    if (self.swellDirection == nil) {
        self.dominantPeriod = self.windWavePeriod;
        return;
    }
    
    if (self.windWaveDirection == nil) {
        self.dominantPeriod = self.swellPeriod;
        return;
    }
    
    if ([self.swellDirection isEqualToString:self.meanDirection]) {
        self.dominantPeriod = self.swellPeriod;
    } else {
        self.dominantPeriod = self.windWavePeriod;
    }
}

- (void) interpolateDominantPeriodWithSteepness {
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
    if (self.swellDirection == nil && self.windWaveDirection == nil) {
        return;
    } else if (self.dominantPeriod == nil) {
        return;
    }
    
    if (self.swellPeriod == nil) {
        self.meanDirection = self.windWaveDirection;
        return;
    }
    
    if (self.windWavePeriod == nil) {
        self.meanDirection = self.swellDirection;
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
    return [NSString stringWithFormat:@"%.2f ft @ %.1f s %@", self.significantWaveHeight.doubleValue, self.dominantPeriod.doubleValue, self.meanDirection];
}

- (NSString*) getDominantSwellText {
    if ([self.steepness isEqualToString:@"SWELL"] || [self.steepness isEqualToString:@"AVERAGE"]) {
        return [NSString stringWithFormat:@"%.2f ft @ %.1f s %@", self.swellWaveHeight.doubleValue, self.swellPeriod.doubleValue, self.swellDirection];
    } else {
        return [NSString stringWithFormat:@"%.2f ft @ %.1f s %@", self.windWaveHeight.doubleValue, self.windWavePeriod.doubleValue, self.windWaveDirection];
    }
}

- (NSString*) getSecondarySwellText {
    if ([self.steepness isEqualToString:@"SWELL"] || [self.steepness isEqualToString:@"AVERAGE"]) {
        return [NSString stringWithFormat:@"%.2f ft @ %.1f s %@", self.windWaveHeight.doubleValue, self.windWavePeriod.doubleValue, self.windWaveDirection];
    } else {
        if (self.swellPeriod.intValue < 1) {
            return @"";
        } else {
            return [NSString stringWithFormat:@"%.2f ft @ %.1f s %@", self.swellWaveHeight.doubleValue, self.swellPeriod.doubleValue, self.swellDirection];
        }
    }
}

- (NSString*) getSimpleSwellText {
    return [NSString stringWithFormat:@"%.1f ft @ %.1f s", self.significantWaveHeight.doubleValue, self.dominantPeriod.doubleValue];
}

- (NSString*) getWaveHeightText {
    return [NSString stringWithFormat:@"%.1f ft", self.significantWaveHeight.doubleValue];
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