//
//  CameraModel.h
//  HackWinds
//
//  Created by Matthew Iannucci on 5/17/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Camera.h"

// Notification Constants
extern NSString * const CAMERA_DATA_UPDATED_TAG;
extern NSString * const CAMERA_DATA_UPDATE_FAILED_TAG;

@interface CameraModel : NSObject

@property (strong, nonatomic, readonly) Camera* defaultCamera;
@property (strong, nonatomic) NSDictionary *cameraURLS;

- (void) forceFetchCameraURLs;
- (void) fetchCameraURLs;
- (Camera*) cameraForLocation:(NSString*) locationName camera:(NSString*) cameraName;
- (Camera*) defaultCamera;
+ (instancetype) sharedModel;

@end
