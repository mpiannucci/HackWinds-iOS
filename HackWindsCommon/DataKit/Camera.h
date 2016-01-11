//
//  Camera.h
//  HackWinds
//
//  Created by Matthew Iannucci on 7/24/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Camera : NSObject

@property (strong, nonatomic) NSURL *imageURL;
@property (strong, nonatomic) NSURL *videoURL;
@property (strong, nonatomic) NSString *info;

- (void) setIsRefreshable:(BOOL)refresh;
- (BOOL) isRefreshable;
- (void) setRefreshDuration:(int)refreshDur;
- (int) getRefreshDuration;

@end
