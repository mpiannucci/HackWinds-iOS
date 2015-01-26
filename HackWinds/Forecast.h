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
@property (strong, nonatomic) NSString *Date;
@property (strong, nonatomic) NSString *MinBreakHeight;
@property (strong, nonatomic) NSString *MaxBreakHeight;
@property (strong, nonatomic) NSString *WindSpeed;
@property (strong, nonatomic) NSString *WindDir;

@end
