//
//  Condition.h
//  HackWinds
//
//  Created by Matthew Iannucci on 7/27/14.
//  Copyright (c) 2014 Matthew Iannucci. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Condition : NSObject

// Define the data for the condition model
@property (strong, nonatomic) NSString *timestamp;
@property (strong, nonatomic) NSString *minBreakHeight;
@property (strong, nonatomic) NSString *maxBreakHeight;
@property (strong, nonatomic) NSString *windSpeed;
@property (strong, nonatomic) NSString *windDeg;
@property (strong, nonatomic) NSString *windDirection;
@property (strong, nonatomic) NSString *swellHeight;
@property (strong, nonatomic) NSString *swellPeriod;
@property (strong, nonatomic) NSString *swellDirection;
@property (strong, nonatomic) NSString *swellChartURL;
@property (strong, nonatomic) NSString *windChartURL;
@property (strong, nonatomic) NSString *periodChartURL;

@end
