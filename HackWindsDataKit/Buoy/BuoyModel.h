//
//  BuoyModel.h
//  HackWinds
//
//  Created by Matthew Iannucci on 12/14/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//
#define BLOCK_ISLAND_LOCATION 41
#define MONTAUK_LOCATION 42
#define NANTUCKET_LOCATION 43

#import <Foundation/Foundation.h>
#import "Buoy.h"

@interface BuoyModel : NSObject

@property (strong, nonatomic) NSMutableArray *blockIslandBuoys;
@property (strong, nonatomic) NSMutableArray *blockIslandWaveHeights;
@property (strong, nonatomic) NSMutableArray *montaukBuoys;
@property (strong, nonatomic) NSMutableArray *montaukWaveHeights;
@property (strong, nonatomic) NSMutableArray *nantucketBuoys;
@property (strong, nonatomic) NSMutableArray *nantucketWaveHeights;

- (BOOL) fetchBuoyDataForLocation:(int)location;
- (void) resetData;
- (int) getTimeOffset;
- (NSMutableArray*) getBuoyDataForLocation:(int)location;
- (NSMutableArray*) getWaveHeightForLocation:(int)location;

+ (Buoy*) getLatestBuoyDataOnlyForLocation:(int)location;
+ (instancetype) sharedModel;

@end