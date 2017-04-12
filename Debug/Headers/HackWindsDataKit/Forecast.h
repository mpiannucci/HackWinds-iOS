//
//  Forecast.h
//  HackWinds
//
//  Created by Matthew Iannucci on 9/18/14.
//  Copyright (c) 2014 Matthew Iannucci. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Swell.h"

@interface Forecast : NSObject

// Define a simplified model for the forecast data
@property (strong, nonatomic) NSString *dateString;
@property (strong, nonatomic) NSString *timeString;
@property (strong, nonatomic) NSNumber *minimumBreakingHeight;
@property (strong, nonatomic) NSNumber *maximumBreakingHeight;
@property (strong, nonatomic) NSNumber *windSpeed;
@property (strong, nonatomic) NSNumber *windDirection;
@property (strong, nonatomic) NSString *windCompassDirection;
@property (strong, nonatomic) Swell *primarySwellComponent;
@property (strong, nonatomic) Swell *secondarySwellComponent;
@property (strong, nonatomic) Swell *tertiarySwellComponent;

- (NSString*) timeToTwentyFourHourClock;
- (NSString*) timeStringNoZero;

@end
