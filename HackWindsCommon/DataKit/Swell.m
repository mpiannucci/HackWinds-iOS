//
//  Swell.m
//  HackWinds
//
//  Created by Matthew Iannucci on 2/19/16.
//  Copyright © 2016 Rhodysurf Development. All rights reserved.
//

#import "Swell.h"

@implementation Swell

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.waveHeight = [aDecoder decodeObjectForKey:@"waveHeight"];
        self.period = [aDecoder decodeObjectForKey:@"period"];
        self.direction = [aDecoder decodeObjectForKey:@"direction"];
        self.compassDirection = [aDecoder decodeObjectForKey:@"compassDirection"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.waveHeight forKey:@"waveHeight"];
    [aCoder encodeObject:self.period forKey:@"period"];
    [aCoder encodeObject:self.direction forKey:@"direction"];
    [aCoder encodeObject:self.compassDirection forKey:@"compassDirection"];
}

- (NSString *) getSwellSummmary {
    return [NSString stringWithFormat:@"%@ %2.2f ft @ %2.1fs", self.compassDirection, self.waveHeight.floatValue, self.period.floatValue];
}

@end
