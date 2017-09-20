//
//  WatchSessionManager.h
//  HackWinds
//
//  Created by Matthew Iannucci on 9/19/17.
//  Copyright © 2017 Rhodysurf Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchConnectivity/WatchConnectivity.h>

@interface WatchSessionManager : NSObject <WCSessionDelegate>

+ (instancetype) sharedManager;
- (void) startSession;
- (void) transferUserInfo;

@end
