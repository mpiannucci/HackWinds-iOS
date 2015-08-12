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
        self.Date = [aDecoder decodeObjectForKey:@"date"];
        self.MinBreakHeight = [aDecoder decodeObjectForKey:@"minBreakHeight"];
        self.MaxBreakHeight = [aDecoder decodeObjectForKey:@"maxBreakHeight"];
        self.WindSpeed = [aDecoder decodeObjectForKey:@"windSpeed"];
        self.WindDir = [aDecoder decodeObjectForKey:@"windDir"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.Date forKey:@"date"];
    [aCoder encodeObject:self.MinBreakHeight forKey:@"minBreakHeight"];
    [aCoder encodeObject:self.MaxBreakHeight forKey:@"maxBreakHeight"];
    [aCoder encodeObject:self.WindSpeed forKey:@"windSpeed"];
    [aCoder encodeObject:self.WindDir forKey:@"windDir"];
}

@end
