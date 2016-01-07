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
@property (strong, nonatomic) NSString *Date;
@property (strong, nonatomic) NSString *MinBreakHeight;
@property (strong, nonatomic) NSString *MaxBreakHeight;
@property (strong, nonatomic) NSString *WindSpeed;
@property (strong, nonatomic) NSString *WindDeg;
@property (strong, nonatomic) NSString *WindDirection;
@property (strong, nonatomic) NSString *SwellHeight;
@property (strong, nonatomic) NSString *SwellPeriod;
@property (strong, nonatomic) NSString *SwellDirection;
@property (strong, nonatomic) NSString *SwellChartURL;
@property (strong, nonatomic) NSString *WindChartURL;
@property (strong, nonatomic) NSString *PeriodChartURL;

@end
