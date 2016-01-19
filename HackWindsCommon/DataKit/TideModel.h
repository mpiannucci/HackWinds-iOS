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

@interface TideModel : NSObject

@property (strong, nonatomic) NSMutableArray *tides;

- (void) fetchTideData;
- (void) fetchLatestTidalEventOnly:(void(^)(Tide*))completionHandler;
- (void) resetData;

+ (instancetype) sharedModel;

@end