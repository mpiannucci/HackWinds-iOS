//
//  BuoyDataContainer.h
//  HackWinds
//
//  Created by Matthew Iannucci on 8/23/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const int BUOY_DATA_POINTS;

@interface BuoyDataContainer : NSObject

@property (strong, nonatomic) NSNumber *buoyID;
@property (strong, nonatomic) NSMutableArray *buoyData;
@property (strong, nonatomic) NSMutableDictionary *waveHeights;

- (NSURL*) createStandardMeteorologicalDataURL;
- (NSURL*) createDetailedWaveDataURL;
- (NSURL*) createLatestReportOnlyURL;
- (NSURL*) createSpectraPlotURL;

@end
