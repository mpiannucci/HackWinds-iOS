//
//  Buoy.h
//  HackWinds
//
//  Created by Matthew Iannucci on 10/9/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Buoy : NSObject

@property (strong, nonatomic) NSString *time;
@property (strong, nonatomic) NSString *wvht;
@property (strong, nonatomic) NSString *apd;
@property (strong, nonatomic) NSString *steepness;

@end
