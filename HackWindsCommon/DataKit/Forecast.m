//
//  Forecast.m
//  HackWinds
//
//  Created by Matthew Iannucci on 9/18/14.
//  Copyright (c) 2014 Matthew Iannucci. All rights reserved.
//

#import "Forecast.h"

@implementation Forecast

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.timestamp = [aDecoder decodeObjectForKey:@"date"];
        self.minBreakHeight = [aDecoder decodeObjectForKey:@"minBreakHeight"];
        self.maxBreakHeight = [aDecoder decodeObjectForKey:@"maxBreakHeight"];
        self.windSpeed = [aDecoder decodeObjectForKey:@"windSpeed"];
        self.windDirection = [aDecoder decodeObjectForKey:@"windDir"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.timestamp forKey:@"date"];
    [aCoder encodeObject:self.minBreakHeight forKey:@"minBreakHeight"];
    [aCoder encodeObject:self.maxBreakHeight forKey:@"maxBreakHeight"];
    [aCoder encodeObject:self.windSpeed forKey:@"windSpeed"];
    [aCoder encodeObject:self.windDirection forKey:@"windDir"];
}

@end
