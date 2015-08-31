//
//  BuoyDataContainer.h
//  HackWinds
//
//  Created by Matthew Iannucci on 8/23/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//
#define BUOY_DATA_POINTS 20

#import <Foundation/Foundation.h>

@interface BuoyDataContainer : NSObject

@property (strong, nonatomic) NSURL *summaryURL;
@property (strong, nonatomic) NSURL *detailedURL;
@property (strong, nonatomic) NSMutableArray *buoyData;
@property (strong, nonatomic) NSMutableArray *waveHeights;
@property (strong, nonatomic) NSMutableArray *swellWaveHeights;
@property (strong, nonatomic) NSMutableArray *windWaveHeights;

@end
