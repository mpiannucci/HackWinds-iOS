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

- (WCSessionUserInfoTransfer*) transferUserInfo:(NSDictionary*)userInfo {
    if (![self validSession]) {
        return nil;
    }
    
    return [[self session] transferUserInfo:userInfo];
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
    if (activationState != WCSessionActivationStateActivated) {
        return;
    }
    
    NSUserDefaults *defaultPreferences = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.mpiannucci.HackWinds"];
    [self transferUserInfo:[defaultPreferences dictionaryRepresentation]];
}

- (void) sessionDidBecomeInactive:(WCSession *)session {
    
}

- (void) sessionDidDeactivate:(WCSession *)session {
    
}

@end
