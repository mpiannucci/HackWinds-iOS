//
//  Buoy.h
//  HackWinds
//
//  Created by Matthew Iannucci on 10/9/14.
//  Copyright (c) 2014 Matthew Iannucci. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Swell.h"


@interface Buoy : NSObject

// Define data for the buoy data model
@property (strong, nonatomic) NSDate *timestamp;

// Wave Data
@property (strong, nonatomic) Swell *waveSummary;
@property (strong, nonatomic) NSMutableArray *swellComponents;

// Meteorological data
@property (strong, nonatomic) NSNumber *waterTemperature;

// Charts
@property (strong, nonatomic) NSString* directionalWaveSpectraPlotURL;
@property (strong, nonatomic) NSString* waveEnergySpectraPlotURL;

- (NSString *) timeString;
- (NSString *) dateString;
- (NSString*) getWaveSummaryStatusText;
- (NSString*) getSimpleSwellText;
- (NSString*) getWaveHeightText;

+ (NSString*) getCompassDirection:(NSString*)degreeDirection;

@end
