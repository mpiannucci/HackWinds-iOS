//
//  Condition.m
//  HackWinds
//
//  Created by Matthew Iannucci on 7/27/14.
//  Copyright (c) 2014 Matthew Iannucci. All rights reserved.
//

#import "Condition.h"

@implementation Condition

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.timestamp = [aDecoder decodeObjectForKey:@"date"];
        self.minBreakHeight = [aDecoder decodeObjectForKey:@"minBreakHeight"];
        self.maxBreakHeight = [aDecoder decodeObjectForKey:@"maxBreakHeight"];
        self.windSpeed = [aDecoder decodeObjectForKey:@"windSpeed"];
        self.windDeg = [aDecoder decodeObjectForKey:@"windDeg"];
        self.windDirection = [aDecoder decodeObjectForKey:@"windDirection"];
        self.swellHeight = [aDecoder decodeObjectForKey:@"swellHeight"];
        self.swellPeriod = [aDecoder decodeObjectForKey:@"swellPeriod"];
        self.swellDirection = [aDecoder decodeObjectForKey:@"swellDirection"];
        self.swellChartURL = [aDecoder decodeObjectForKey:@"swellChartURL"];
        self.windChartURL = [aDecoder decodeObjectForKey:@"windChartURL"];
        self.periodChartURL = [aDecoder decodeObjectForKey:@"periodChartURL"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.timestamp forKey:@"date"];
    [aCoder encodeObject:self.minBreakHeight forKey:@"minBreakHeight"];
    [aCoder encodeObject:self.maxBreakHeight forKey:@"maxBreakHeight"];
    [aCoder encodeObject:self.windSpeed forKey:@"windSpeed"];
    [aCoder encodeObject:self.windDeg forKey:@"windDeg"];
    [aCoder encodeObject:self.windDirection forKey:@"windDirection"];
    [aCoder encodeObject:self.swellHeight forKey:@"swellHeight"];
    [aCoder encodeObject:self.swellPeriod forKey:@"swellperiod"];
    [aCoder encodeObject:self.swellDirection forKey:@"swellDirection"];
    [aCoder encodeObject:self.swellChartURL forKey:@"swellChartURL"];
    [aCoder encodeObject:self.windChartURL forKey:@"windChartURL"];
    [aCoder encodeObject:self.periodChartURL forKey:@"periodChartURL"];
}

@end
