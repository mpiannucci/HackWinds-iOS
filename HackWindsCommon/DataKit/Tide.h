//
//  Tide.h
//  HackWinds
//
//  Created by Matthew Iannucci on 7/27/14.
//  Copyright (c) 2014 Matthew Iannucci. All rights reserved.
//

#import <Foundation/Foundation.h>

// Constants
extern NSString * const LOW_TIDE_TAG;
extern NSString * const HIGH_TIDE_TAG;
extern NSString * const SUNRISE_TAG;
extern NSString * const SUNSET_TAG;

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