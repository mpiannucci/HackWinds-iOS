//
//  CameraModel.h
//  HackWinds
//
//  Created by Matthew Iannucci on 5/17/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CameraModel : NSObject

- (BOOL) forceFetchCameraURLs;
- (BOOL) fetchCameraURLs;
+ (instancetype) sharedModel;

@end
