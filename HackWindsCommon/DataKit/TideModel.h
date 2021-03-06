//
//  TideModel.h
//  HackWinds
//
//  Created by Matthew Iannucci on 12/14/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "Tide.h"

// Notification Constants
extern NSString * const TIDE_DATA_UPDATED_TAG;
extern NSString * const TIDE_DATA_UPDATE_FAILED_TAG;

@interface TideModel : NSObject

@property (strong, nonatomic) NSMutableArray *tides;
@property (strong, nonatomic) NSMutableArray *otherEvents;
@property NSInteger dayCount;

- (void) resetData;
- (void) checkForUpdate;
- (void) fetchTideData;
- (void) fetchLatestTidalEventOnly:(void(^)(Tide*))completionHandler;
- (NSInteger) dataCountForIndex:(NSInteger)index;
- (Tide*) tideDataAtIndex:(NSInteger)index forDay:(NSInteger)dayIndex;

+ (instancetype) sharedModel;

@end
