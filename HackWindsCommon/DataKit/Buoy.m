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
        self.waveSummary = [aDecoder decodeObjectForKey:@"waveSummary"];
        self.swellComponents = [aDecoder decodeObjectForKey:@"swellComponents"];
        self.waterTemperature = [aDecoder decodeObjectForKey:@"waterTemperature"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.timestamp forKey:@"time"];
    [aCoder encodeObject:self.waveSummary forKey:@"waveSummary"];
    [aCoder encodeObject:self.swellComponents forKey:@"swellComponents"];
    [aCoder encodeObject:self.waterTemperature forKey:@"waterTemperature"];
}




@end
