//
//  BuoyModel.h
//  HackWinds
//
//  Created by Matthew Iannucci on 12/14/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//
#define BLOCK_ISLAND_LOCATION @"Block Island"
#define MONTAUK_LOCATION @"Montauk"
#define NANTUCKET_LOCATION @"Nantucket"

#import <Foundation/Foundation.h>
#import "Buoy.h"

@interface BuoyModel : NSObject

@property (strong, nonatomic) NSMutableDictionary *buoyDataSets;

@property (strong, nonatomic) NSMutableArray *blockIslandBuoys;
@property (strong, nonatomic) NSMutableArray *blockIslandWaveHeights;
@property (strong, nonatomic) NSMutableArray *montaukBuoys;
@property (strong, nonatomic) NSMutableArray *montaukWaveHeights;
@property (strong, nonatomic) NSMutableArray *nantucketBuoys;
@property (strong, nonatomic) NSMutableArray *nantucketWaveHeights;

- (BOOL) fetchBuoyDataForLocation:(NSString*)location;
- (void) resetData;
- (int) getTimeOffset;
- (NSMutableArray*) getBuoyDataForLocation:(NSString*)location;
- (NSMutableArray*) getWaveHeightForLocation:(NSString*)location;

+ (Buoy*) getLatestBuoyDataOnlyForLocation:(NSString*)location;
+ (instancetype) sharedModel;

@end