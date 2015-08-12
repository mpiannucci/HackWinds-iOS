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
        self.WaveHeight = [aDecoder decodeObjectForKey:@"waveHeight"];
        self.DominantPeriod = [aDecoder decodeObjectForKey:@"period"];
        self.Direction = [aDecoder decodeObjectForKey:@"direction"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.Time forKey:@"time"];
    [aCoder encodeObject:self.WaveHeight forKey:@"waveHeight"];
    [aCoder encodeObject:self.DominantPeriod forKey:@"period"];
    [aCoder encodeObject:self.Direction forKey:@"direction"];
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