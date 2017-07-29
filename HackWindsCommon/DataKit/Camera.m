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
    bool premium;
}

- (id) init {
    self = [super init];
    
    refreshable = false;
    refreshDuration = 0;
    
    return self;
}

- (void) setIsRefreshable:(BOOL)isRefreshable {
    refreshable = isRefreshable;
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

- (void) setPremium:(BOOL)isPremium {
    premium = isPremium;
}

- (BOOL) isPremium {
    return premium;
}

- (NSURL*) url {
    if ([self hasVideoURL]) {
        return self.videoURL;
    } else if ([self hasWebURL]) {
        return self.webURL;
    }
    
    return self.imageURL;
}

- (BOOL) hasVideoURL {
    return ![[self.videoURL absoluteString] isEqualToString:@""];
}

- (BOOL) hasWebURL {
    return ![[self.webURL absoluteString] isEqualToString:@""];
}

- (BOOL) hasImageURL {
    return ![[self.imageURL absoluteString] isEqualToString:@""];
}

@end
