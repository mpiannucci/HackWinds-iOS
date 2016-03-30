//
//  Buoy.h
//  HackWinds
//
//  Created by Matthew Iannucci on 10/9/14.
//  Copyright (c) 2014 Matthew Iannucci. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Buoy : NSObject

// Define data for the buoy data model
@property (strong, nonatomic) NSDate *timestamp;

// Wave Heights
@property (strong, nonatomic) NSString *significantWaveHeight;
@property (strong, nonatomic) NSString *swellWaveHeight;
@property (strong, nonatomic) NSString *windWaveHeight;

// Period
@property (strong, nonatomic) NSString *dominantPeriod;
@property (strong, nonatomic) NSString *swellPeriod;
@property (strong, nonatomic) NSString *windWavePeriod;

// Steepness
@property (strong, nonatomic) NSString *steepness;

// Direction
@property (strong, nonatomic) NSString *meanDirection;
@property (strong, nonatomic) NSString *swellDirection;
@property (strong, nonatomic) NSString *windWaveDirection;

@property (strong, nonatomic) NSString *waterTemperature;

- (NSString *) timeString;
- (NSString *) dateString;
- (void) interpolateDominantPeriod;
- (void) interpolateMeanDirection;
- (NSString*) getWaveSummaryStatusText;
- (NSString*) getDominantSwellText;
- (NSString*) getSecondarySwellText;

+ (NSString*) getCompassDirection:(NSString*)degreeDirection;

@end
