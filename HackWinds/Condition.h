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
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *minBreak;
@property (strong, nonatomic) NSString *maxBreak;
@property (strong, nonatomic) NSString *windSpeed;
@property (strong, nonatomic) NSString *windDeg;
@property (strong, nonatomic) NSString *windDir;
@property (strong, nonatomic) NSString *swellHeight;
@property (strong, nonatomic) NSString *swellPeriod;
@property (strong, nonatomic) NSString *swellDir;

@end
