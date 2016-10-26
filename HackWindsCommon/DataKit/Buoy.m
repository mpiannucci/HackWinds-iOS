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
        self.directionalWaveSpectraBase64 = [aDecoder decodeObjectForKey:@"directionalWaveSpectraBase64"];
        self.waveEnergySpectraBase64 = [aDecoder decodeObjectForKey:@"waveEnergySpectraBase64"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.timestamp forKey:@"time"];
    [aCoder encodeObject:self.waveSummary forKey:@"waveSummary"];
    [aCoder encodeObject:self.swellComponents forKey:@"swellComponents"];
    [aCoder encodeObject:self.waterTemperature forKey:@"waterTemperature"];
    [aCoder encodeObject:self.directionalWaveSpectraBase64 forKey:@"directionalWaveSpectraBase64"];
    [aCoder encodeObject:self.waveEnergySpectraBase64 forKey:@"waveEnergySpectraBase64"];
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

- (NSString*) getWaveSummaryStatusText {
    return [NSString stringWithFormat:@"%.2f ft @ %.1f s %@", self.waveSummary.waveHeight.doubleValue, self.waveSummary.period.doubleValue, self.waveSummary.compassDirection];
}

- (NSString*) getSimpleSwellText {
    return [NSString stringWithFormat:@"%.1f ft @ %d s %@", self.waveSummary.waveHeight.doubleValue, self.waveSummary.period.intValue, self.waveSummary.compassDirection];
}

- (NSString*) getWaveHeightText {
    return [NSString stringWithFormat:@"%.1f ft", self.waveSummary.waveHeight.doubleValue];
}

- (NSString*) getWaveDirectionText {
    return self.waveSummary.compassDirection;
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
