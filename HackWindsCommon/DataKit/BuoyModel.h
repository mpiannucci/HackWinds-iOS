//
//  BuoyModel.h
//  HackWinds
//
//  Created by Matthew Iannucci on 12/14/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLRStation.h"

// Location Constants
extern NSString * const BLOCK_ISLAND_LOCATION;
extern NSString * const MONTAUK_LOCATION;
extern NSString * const NANTUCKET_LOCATION;
extern NSString * const LONG_ISLAND_LOCATION;
extern NSString * const NEWPORT_LOCATION;
extern NSString * const TEXAS_TOWER_LOCATION;

// Data Mode Constants
extern NSString * const SUMMARY_DATA_MODE;
extern NSString * const SWELL_DATA_MODE;
extern NSString * const WIND_DATA_MODE;

// Notifcation Constants
extern NSString * const BUOY_DATA_UPDATED_TAG;
extern NSString * const BUOY_LOCATION_CHANGED_TAG;
extern NSString * const DEFAULT_BUOY_LOCATION_CHANGED_TAG;
extern NSString * const BUOY_UPDATE_FAILED_TAG;

@interface BuoyModel : NSObject

- (void) resetData;
- (NSArray*) getBuoyLocations;
- (GTLRStation_ApiApiMessagesDataMessage*) getBuoyData;
- (void) changeBuoyLocation;
- (void) changeBuoyLocationAndUpdate;
- (void) forceChangeLocation:(NSString*)location;
- (void) checkForUpdate;
- (void) refreshBuoyData;
- (void) fetchBuoyActive:(void(^)(bool))completionHandler;
- (void) fetchBuoyData;
- (void) fetchLatestSummaryData;
- (void) fetchLatestBuoyDataForLocation:(NSString*)location withCompletionHandler:(void(^)(GTLRStation_ApiApiMessagesDataMessage*))completionHandler;
- (NSMutableURLRequest*) fetchLatestBuoyDataRequestForLocation:(NSString*)location;
- (BOOL) isFetching;

+ (instancetype) sharedModel;
+ (GTLRStation_ApiApiMessagesDataMessage*) buoyDataFromRawData:(NSData*)data;

@end
