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
@property (strong, nonatomic) NSString *day;
@property (strong, nonatomic) NSDate *timestamp;
@property (strong, nonatomic) NSString *eventType;
@property (strong, nonatomic) NSString *height;

// Conveinence methods
- (NSString *) getTideEventSummary;
- (NSString *) getTideEventAbbreviation;
- (NSString *) getTideEventShortSummary;
- (BOOL) isSunrise;
- (BOOL) isSunset;
- (BOOL) isSolarEvent;
- (BOOL) isHighTide;
- (BOOL) isLowTide;
- (BOOL) isTidalEvent;
- (double) heightValue;
- (NSString*) timeString;

@end