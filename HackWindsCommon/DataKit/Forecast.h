//
//  Forecast.h
//  HackWinds
//
//  Created by Matthew Iannucci on 9/18/14.
//  Copyright (c) 2014 Matthew Iannucci. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Forecast : NSObject

// Define a simplified model for the forecast data
@property (strong, nonatomic) NSString *timestamp;
@property (strong, nonatomic) NSString *minBreakHeight;
@property (strong, nonatomic) NSString *maxBreakHeight;
@property (strong, nonatomic) NSString *windSpeed;
@property (strong, nonatomic) NSString *windDirection;

@end
