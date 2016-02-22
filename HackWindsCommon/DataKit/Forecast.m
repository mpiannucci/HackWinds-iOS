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
        self.dateString = [aDecoder decodeObjectForKey:@"dateString"];
        self.timeString = [aDecoder decodeObjectForKey:@"timeString"];
        self.minimumBreakingHeight = [aDecoder decodeObjectForKey:@"minimumBreakingHeight"];
        self.maximumBreakingHeight = [aDecoder decodeObjectForKey:@"maximumBreakingHeight"];
        self.windSpeed = [aDecoder decodeObjectForKey:@"windSpeed"];
        self.windDirection = [aDecoder decodeObjectForKey:@"windDir"];
        self.windCompassDirection = [aDecoder decodeObjectForKey:@"windCompassDirection"];
        self.primarySwellComponent = [aDecoder decodeObjectForKey:@"primarySwellComponent"];
        self.secondarySwellComponent = [aDecoder decodeObjectForKey:@"secondarySwellComponent"];
        self.tertiarySwellComponent = [aDecoder decodeObjectForKey:@"tertiarySwellComponent"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.dateString forKey:@"dateString"];
    [aCoder encodeObject:self.timeString forKey:@"timeString"];
    [aCoder encodeObject:self.minimumBreakingHeight forKey:@"minimumBreakingHeight"];
    [aCoder encodeObject:self.maximumBreakingHeight forKey:@"maximumBreakingHeight"];
    [aCoder encodeObject:self.windSpeed forKey:@"windSpeed"];
    [aCoder encodeObject:self.windDirection forKey:@"windDirection"];
    [aCoder encodeObject:self.windCompassDirection forKey:@"windCompassDirection"];
    [aCoder encodeObject:self.primarySwellComponent forKey:@"primarySwellComponent"];
    [aCoder encodeObject:self.secondarySwellComponent forKey:@"secondarySwellComponent"];
    [aCoder encodeObject:self.tertiarySwellComponent forKey:@"tertiarySwellComponent"];
}

@end
