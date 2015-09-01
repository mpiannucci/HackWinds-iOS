//
//  BuoyModel.h
//  HackWinds
//
//  Created by Matthew Iannucci on 12/14/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//
// Locations
#define BLOCK_ISLAND_LOCATION @"Block Island"
#define MONTAUK_LOCATION @"Montauk"
#define NANTUCKET_LOCATION @"Nantucket"

// Data mode
#define SUMMARY_DATA_MODE @"Summary"
#define SWELL_DATA_MODE @"Swell"
#define WIND_DATA_MODE @"Wind Wave"

// Notification tags
#define BUOY_DATA_UPDATED_TAG @"BuoyModelDidUpdateDataNotification"
#define BUOY_LOCATION_CHANGED_TAG @"BuoyLocationChangedNotification"

#import <Foundation/Foundation.h>
#import "Buoy.h"

@interface BuoyModel : NSObject

- (void) changeBuoyLocation;
- (void) forceChangeLocation:(NSString*)location;
- (BOOL) fetchBuoyData;
- (void) resetData;
- (int) getTimeOffset;
- (NSMutableArray*) getBuoyData;
- (NSMutableArray*) getWaveHeightForMode:(NSString*)mode;
- (NSURL*) getSpectraPlotURL;

+ (Buoy*) getLatestBuoyDataOnly;
+ (instancetype) sharedModel;

@end