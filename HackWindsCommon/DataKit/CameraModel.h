//
//  CameraModel.h
//  HackWinds
//
//  Created by Matthew Iannucci on 5/17/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import <Foundation/Foundation.h>

// Notification Constants
extern NSString * const CAMERA_DATA_UPDATED_TAG;

@interface CameraModel : NSObject

@property (strong, nonatomic) NSDictionary *cameraURLS;

- (void) forceFetchCameraURLs;
- (void) fetchCameraURLs;
+ (instancetype) sharedModel;

@end
