//
//  TideModel.h
//  HackWinds
//
//  Created by Matthew Iannucci on 12/14/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "Tide.h"

@interface TideModel : NSObject

@property (strong, nonatomic) NSMutableArray *tides;

- (BOOL) fetchTideData;
- (void) resetData;

+ (Tide*) getLatestTidalEventOnly;
+ (instancetype) sharedModel;

@end