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

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.Time = [aDecoder decodeObjectForKey:@"time"];
        self.SignificantWaveHeight = [aDecoder decodeObjectForKey:@"significantWaveHeight"];
        self.SwellWaveHeight = [aDecoder decodeObjectForKey:@"swellWaveHeight"];
        self.WindWaveHeight = [aDecoder decodeObjectForKey:@"windWaveHeight"];
        self.DominantPeriod = [aDecoder decodeObjectForKey:@"dominantPeriod"];
        self.SwellPeriod = [aDecoder decodeObjectForKey:@"swellPeriod"];
        self.WindWavePeriod = [aDecoder decodeObjectForKey:@"windWavePeriod"];
        self.MeanDirection = [aDecoder decodeObjectForKey:@"meanDirection"];
        self.SwellDirection = [aDecoder decodeObjectForKey:@"swellDirection"];
        self.WindWaveDirection = [aDecoder decodeObjectForKey:@"windWaveDirection"];
        self.WaterTemperature = [aDecoder decodeObjectForKey:@"waterTemperature"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.Time forKey:@"time"];
    [aCoder encodeObject:self.SignificantWaveHeight forKey:@"significantWaveHeight"];
    [aCoder encodeObject:self.SwellWaveHeight forKey:@"swellWaveHeight"];
    [aCoder encodeObject:self.WindWaveHeight forKey:@"windWaveHeight"];
    [aCoder encodeObject:self.DominantPeriod forKey:@"dominantPeriod"];
    [aCoder encodeObject:self.SwellPeriod forKey:@"swellPeriod"];
    [aCoder encodeObject:self.WindWavePeriod forKey:@"windWavePeriod"];
    [aCoder encodeObject:self.MeanDirection forKey:@"meanDirection"];
    [aCoder encodeObject:self.SwellDirection forKey:@"swellDirection"];
    [aCoder encodeObject:self.WindWaveDirection forKey:@"windWaveDirection"];
    [aCoder encodeObject:self.WaterTemperature forKey:@"waterTemperature"];
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