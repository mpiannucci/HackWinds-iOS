//
//  BuoyModel.h
//  HackWinds
//
//  Created by Matthew Iannucci on 12/14/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Buoy.h"

// Location Constants
extern NSString * const BLOCK_ISLAND_LOCATION;
extern NSString * const MONTAUK_LOCATION;
extern NSString * const NANTUCKET_LOCATION;

// Data Mode Constants
extern NSString * const SUMMARY_DATA_MODE;
extern NSString * const SWELL_DATA_MODE;
extern NSString * const WIND_DATA_MODE;

// Notifcation Constants
extern NSString * const BUOY_DATA_UPDATED_TAG;
extern NSString * const BUOY_LOCATION_CHANGED_TAG;
extern NSString * const DEFAULT_BUOY_LOCATION_CHANGED_TAG;

@interface BuoyModel : NSObject

- (int) getTimeOffset;
- (void) resetData;
- (NSMutableArray*) getBuoyData;
- (NSMutableArray*) getWaveHeightForMode:(NSString*)mode;
- (NSURL*) getSpectraPlotURL;
- (void) changeBuoyLocation;
- (void) forceChangeLocation:(NSString*)location;
- (void) fetchBuoyData;
- (void) fetchLatestBuoyReadingForLocation:(NSString*)location withCompletionHandler:(void(^)(Buoy*))completionHandler;

+ (instancetype) sharedModel;

@end