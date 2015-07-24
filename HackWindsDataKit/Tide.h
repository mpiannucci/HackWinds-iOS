//
//  Tide.h
//  HackWinds
//
//  Created by Matthew Iannucci on 7/27/14.
//  Copyright (c) 2014 Matthew Iannucci. All rights reserved.
//
#define LOW_TIDE_TAG @"Low Tide"
#define HIGH_TIDE_TAG @"High Tide"
#define SUNRISE_TAG @"Sunrise"
#define SUNSET_TAG @"Sunset"

#import <Foundation/Foundation.h>

@interface Tide : NSObject

// Define the data for the tide model
@property (strong, nonatomic) NSString *Time;
@property (strong, nonatomic) NSString *EventType;
@property (strong, nonatomic) NSString *Height;

// Conveinence methods
- (BOOL) isSunrise;
- (BOOL) isSunset;
- (BOOL) isSolarEvent;
- (BOOL) isHighTide;
- (BOOL) isLowTide;
- (BOOL) isTidalEvent;

@end