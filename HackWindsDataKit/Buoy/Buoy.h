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
@property (strong, nonatomic) NSString *WaveHeight;
@property (strong, nonatomic) NSString *DominantPeriod;
@property (strong, nonatomic) NSString *Direction;
@property (strong, nonatomic) NSString *WaterTemperature;

+ (NSString*) getCompassDirection:(NSString*)degreeDirection;

@end
