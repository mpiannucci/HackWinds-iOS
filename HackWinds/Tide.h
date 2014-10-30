//
//  Tide.h
//  HackWinds
//
//  Created by Matthew Iannucci on 7/27/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//
#define LOW_TIDE_TAG @"Low Tide"
#define HIGH_TIDE_TAG @"High Tide"
#define SUNRISE_TAG @"Sunrise"
#define SUNSET_TAG @"Sunset"

#import "CorePLot-CocoaTouch.h"
#import <Foundation/Foundation.h>

@interface Tide : NSObject

// Define the data for the condition model
@property (strong, nonatomic) NSString *time;
@property (strong, nonatomic) NSString *eventType;
@property (strong, nonatomic) NSString *height;

@end