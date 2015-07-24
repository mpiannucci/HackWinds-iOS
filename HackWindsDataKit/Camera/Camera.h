//
//  Camera.h
//  HackWinds
//
//  Created by Matthew Iannucci on 7/24/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Camera : NSObject

@property (strong, nonatomic) NSURL *ImageURL;
@property (strong, nonatomic) NSURL *VideoURL;
@property (strong, nonatomic) NSString *Info;

@end
