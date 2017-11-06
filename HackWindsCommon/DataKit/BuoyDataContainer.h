//
//  BuoyDataContainer.h
//  HackWinds
//
//  Created by Matthew Iannucci on 8/23/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLRStation.h"

@interface GTLRStation_ApiApiMessagesDataMessage (StringFormatting)
- (NSString *) timeString;
- (NSString *) dateString;
- (NSString*) getWaveSummaryStatusText;
- (NSString*) getSimpleSwellText;
- (NSString*) getWaveHeightText;
+ (NSString*) getCompassDirection:(NSString*)degreeDirection;
@end

@interface GTLRStation_ApiApiMessagesSwellMessage (StringFormatting)
- (NSString *) getSwellSummmary;
- (NSString *) getDetailedSwellSummmary;
@end

@interface BuoyDataContainer : NSObject

@property (strong, nonatomic) NSString *buoyID;
@property (strong, nonatomic) GTLRStation_ApiApiMessagesDataMessage *buoyData;
@property NSInteger updateInterval;
@property NSDate *fetchTimestamp;
@property BOOL active;

- (void) resetData;

@end
