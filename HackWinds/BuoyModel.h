//
//  BuoyModel.h
//  HackWinds
//
//  Created by Matthew Iannucci on 12/14/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//
#define BLOCK_ISLAND_LOCATION 41
#define MONTAUK_LOCATION 42

#import <Foundation/Foundation.h>

@interface BuoyModel : NSObject

- (NSMutableArray*) getBuoyDataForLocation:(int)location;
- (NSMutableArray*) getWaveHeightForLocation:(int)location;
+ (instancetype) sharedModel;

@end
