//
//  ForecastDailySummary.h
//  HackWinds
//
//  Created by Matthew Iannucci on 2/19/16.
//  Copyright © 2016 Rhodysurf Development. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ForecastDailySummary : NSObject

@property (strong, nonatomic) NSNumber *morningMinimumBreakingHeight;
@property (strong, nonatomic) NSNumber *morningMaximumBreakingHeight;
@property (strong, nonatomic) NSNumber *morningWindSpeed;
@property (strong, nonatomic) NSString *morningWindCompassDirection;

@property (strong, nonatomic) NSNumber *afternoonMinimumBreakingHeight;
@property (strong, nonatomic) NSNumber *afternoonMaximumBreakingHeight;
@property (strong, nonatomic) NSNumber *afternoonWindSpeed;
@property (strong, nonatomic) NSString *afternoonWindCompassDirection;

@end
