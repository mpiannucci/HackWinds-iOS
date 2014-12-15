//
//  TideModel.h
//  HackWinds
//
//  Created by Matthew Iannucci on 12/14/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TideModel : NSObject

- (NSMutableArray*) getTideData;
+ (instancetype) sharedModel;

@end
