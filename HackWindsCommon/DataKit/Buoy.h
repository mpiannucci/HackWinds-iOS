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
@property (strong, nonatomic) NSString *Time;

// Wave Heights
@property (strong, nonatomic) NSString *SignificantWaveHeight;
@property (strong, nonatomic) NSString *SwellWaveHeight;
@property (strong, nonatomic) NSString *WindWaveHeight;

// Period
@property (strong, nonatomic) NSString *DominantPeriod;
@property (strong, nonatomic) NSString *SwellPeriod;
@property (strong, nonatomic) NSString *WindWavePeriod;

// Direction
@property (strong, nonatomic) NSString *MeanDirection;
@property (strong, nonatomic) NSString *SwellDirection;
@property (strong, nonatomic) NSString *WindWaveDirection;

@property (strong, nonatomic) NSString *WaterTemperature;

+ (NSString*) getCompassDirection:(NSString*)degreeDirection;

@end
