//
//  ConditionDelegate.h
//  HackWinds
//
//  Created by Matthew Iannucci on 7/27/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ConditionDelegate <NSObject>
- (void)receivedConditionJSON:(NSData *)objectNotation;
- (void)fetchingConditionFailedWithError:(NSError *)error;
@end