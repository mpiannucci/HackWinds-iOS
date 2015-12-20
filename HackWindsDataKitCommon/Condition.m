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
        self.Date = [aDecoder decodeObjectForKey:@"date"];
        self.MinBreakHeight = [aDecoder decodeObjectForKey:@"minBreakHeight"];
        self.MaxBreakHeight = [aDecoder decodeObjectForKey:@"maxBreakHeight"];
        self.WindSpeed = [aDecoder decodeObjectForKey:@"windSpeed"];
        self.WindDeg = [aDecoder decodeObjectForKey:@"windDeg"];
        self.WindDirection = [aDecoder decodeObjectForKey:@"windDirection"];
        self.SwellHeight = [aDecoder decodeObjectForKey:@"swellHeight"];
        self.SwellPeriod = [aDecoder decodeObjectForKey:@"swellPeriod"];
        self.SwellDirection = [aDecoder decodeObjectForKey:@"swellDirection"];
        self.SwellChartURL = [aDecoder decodeObjectForKey:@"swellChartURL"];
        self.WindChartURL = [aDecoder decodeObjectForKey:@"windChartURL"];
        self.PeriodChartURL = [aDecoder decodeObjectForKey:@"periodChartURL"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.Date forKey:@"date"];
    [aCoder encodeObject:self.MinBreakHeight forKey:@"minBreakHeight"];
    [aCoder encodeObject:self.MaxBreakHeight forKey:@"maxBreakHeight"];
    [aCoder encodeObject:self.WindSpeed forKey:@"windSpeed"];
    [aCoder encodeObject:self.WindDeg forKey:@"windDeg"];
    [aCoder encodeObject:self.WindDirection forKey:@"windDirection"];
    [aCoder encodeObject:self.SwellHeight forKey:@"swellHeight"];
    [aCoder encodeObject:self.SwellPeriod forKey:@"swellperiod"];
    [aCoder encodeObject:self.SwellDirection forKey:@"swellDirection"];
    [aCoder encodeObject:self.SwellChartURL forKey:@"swellChartURL"];
    [aCoder encodeObject:self.WindChartURL forKey:@"windChartURL"];
    [aCoder encodeObject:self.PeriodChartURL forKey:@"periodChartURL"];
}

@end
