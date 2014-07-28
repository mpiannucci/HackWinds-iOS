//
//  ConditionCommunicator.h
//  HackWinds
//
//  Created by Matthew Iannucci on 7/27/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ConditionDelegate;

@interface ConditionCommunicator : NSObject

@property (weak, nonatomic) id<ConditionDelegate> delegate;
- (void)getConditionData:(int)numData forOffset:(int)offset;

@end
