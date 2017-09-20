//
//  WatchSessionManager.m
//  HackWinds
//
//  Created by Matthew Iannucci on 9/19/17.
//  Copyright © 2017 Rhodysurf Development. All rights reserved.
//

#import "WatchSessionManager.h"

@interface WatchSessionManager ()

- (BOOL) validSession;
- (WCSession*) session;

@end

@implementation WatchSessionManager

+ (instancetype) sharedManager {
    static WatchSessionManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // code to be executed once - thread safe version!
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (id)init {
    self = [super init];
    return self;
}

- (void) startSession {
    WCSession* sesh = [self session];
    if (sesh == nil) {
        return;
    }
    
    sesh.delegate = self;
    [sesh activateSession];
}

- (void) transferUserInfo {
    // TODO
}

- (BOOL) validSession {
    WCSession* sesh = [self session];
    if (sesh== nil) {
        return NO;
    }
    
    return [sesh isPaired] && [sesh isWatchAppInstalled];
}

- (WCSession*) session {
    if (![WCSession isSupported]) {
        return nil;
    }
    
    return [WCSession defaultSession];
}

// DELEGATE

- (void) session:(WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(NSError *)error {
    
}

- (void) sessionDidBecomeInactive:(WCSession *)session {
    
}

- (void) sessionDidDeactivate:(WCSession *)session {
    
}

@end
