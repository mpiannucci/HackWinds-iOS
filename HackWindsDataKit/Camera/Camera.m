//
//  Camera.m
//  HackWinds
//
//  Created by Matthew Iannucci on 7/24/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import "Camera.h"

@implementation Camera {
    bool refreshable;
    int refreshDuration;
}

- (id) init {
    self = [super init];
    
    refreshable = false;
    refreshDuration = 0;
    
    return self;
}

- (void) setIsRefreshable:(BOOL)refresh {
    refreshable = refresh;
}

- (BOOL) isRefreshable {
    return refreshable;
}

- (void) setRefreshDuration:(int)refreshDur {
    refreshDuration = refreshDur;
}

- (int) getRefreshDuration {
    return refreshDuration;
}

@end
