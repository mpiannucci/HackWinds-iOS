//
//  Buoy.h
//  HackWinds
//
//  Created by Matthew Iannucci on 10/9/14.
//  Copyright (c) 2014 Matthew Iannucci. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Buoy : NSObject

// Define data for the buoy data model
@property (strong, nonatomic) NSString *time;
@property (strong, nonatomic) NSString *wvht;
@property (strong, nonatomic) NSString *dpd;
@property (strong, nonatomic) NSString *direction;

@end
