//
//  BuoyDataContainer.m
//  HackWinds
//
//  Created by Matthew Iannucci on 8/23/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import "BuoyDataContainer.h"
#import "BuoyModel.h"

#define WIND_DIRS [NSArray arrayWithObjects:@"N", @"NNE", @"NE", @"ENE", @"E", @"ESE", @"SE", @"SSE", @"S", @"SSW", @"SW", @"WSW", @"W", @"WNW", @"NW", @"NNW", nil]

@implementation GTLRStation_ApiApiMessagesDataMessage (StringFormatting)

- (NSString *) timeString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeStyle = NSDateFormatterShortStyle;
    formatter.locale = [NSLocale currentLocale];
    return [formatter stringFromDate:self.date.date];
}

- (NSString *) dateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    formatter.locale = [NSLocale currentLocale];
    return [formatter stringFromDate:self.date.date];
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

@implementation GTLRStation_ApiApiMessagesSwellMessage (StringFormatting)

- (NSString *) getSwellSummmary {
    return [NSString stringWithFormat:@"%@ %2.2f ft @ %2.1f s", self.compassDirection, self.waveHeight.floatValue, self.period.floatValue];
}

- (NSString *) getDetailedSwellSummmary {
    return [NSString stringWithFormat:@"%2.2f ft @ %2.1f s %d\u00B0 %@ ", self.waveHeight.floatValue, self.period.floatValue, self.direction.intValue, self.compassDirection];
}

@end

@implementation BuoyDataContainer

-(id)init {
    self = [super init];
    
    self.buoyData = nil;
    
    // Default the update interval to 60 minutes
    self.updateInterval = 60;
    
    return self;
}

- (void) resetData {
    self.buoyData = nil;
}

@end
