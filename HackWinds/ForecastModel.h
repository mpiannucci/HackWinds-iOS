//
//  ForecastModel.h
//  HackWinds
//
//  Created by Matthew Iannucci on 12/14/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ForecastModel : NSObject

@property (strong, nonatomic) NSMutableArray *conditions;
@property (strong, nonatomic) NSMutableArray *forecasts;

- (NSMutableArray *) getCurrentConditions;
- (NSMutableArray *) getForecasts;
+ (instancetype) sharedModel;

@end
