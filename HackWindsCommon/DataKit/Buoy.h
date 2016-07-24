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
@property (strong, nonatomic) NSNumber *significantWaveHeight;
@property (strong, nonatomic) NSNumber *swellWaveHeight;
@property (strong, nonatomic) NSNumber *windWaveHeight;

// Period
@property (strong, nonatomic) NSNumber *dominantPeriod;
@property (strong, nonatomic) NSNumber *swellPeriod;
@property (strong, nonatomic) NSNumber *windWavePeriod;

// Steepness
@property (strong, nonatomic) NSString *steepness;

// Direction
@property (strong, nonatomic) NSString *meanDirection;
@property (strong, nonatomic) NSString *swellDirection;
@property (strong, nonatomic) NSString *windWaveDirection;

@property (strong, nonatomic) NSNumber *waterTemperature;

- (NSString *) timeString;
- (NSString *) dateString;
- (void) interpolateDominantPeriod;
- (void) interpolateDominantPeriodWithSteepness;
- (void) interpolateMeanDirection;
- (NSString*) getWaveSummaryStatusText;
- (NSString*) getDominantSwellText;
- (NSString*) getSecondarySwellText;
- (NSString*) getSimpleSwellText;
- (NSString*) getWaveHeightText;

+ (NSString*) getCompassDirection:(NSString*)degreeDirection;

@end
