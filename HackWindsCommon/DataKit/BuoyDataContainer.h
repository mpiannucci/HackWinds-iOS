//
//  BuoyDataContainer.h
//  HackWinds
//
//  Created by Matthew Iannucci on 8/23/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Buoy.h"


@interface BuoyDataContainer : NSObject

@property (strong, nonatomic) NSString *buoyID;
@property (strong, nonatomic) Buoy *buoyData;
@property NSInteger updateInterval;
@property NSDate *fetchTimestamp;

- (NSURL*) getLatestWaveDataURL;
- (NSURL*) getLatestSummaryURL;
- (void) resetData;

@end
