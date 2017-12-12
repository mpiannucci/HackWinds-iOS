//
//  CameraModel.h
//  HackWinds
//
//  Created by Matthew Iannucci on 5/17/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLRCamera.h"

// Notification Constants
extern NSString * const CAMERA_DATA_UPDATED_TAG;
extern NSString * const CAMERA_DATA_UPDATE_FAILED_TAG;

@interface CameraModel : NSObject

@property (strong, nonatomic, readonly) GTLRCamera_ModelCameraMessagesCameraMessage* defaultCamera;
@property (strong, nonatomic, readonly) GTLRCamera_ModelCameraMessagesCameraLocationsMessage *cameras;

- (void) forceFetchCameraURLs;
- (void) fetchCameraURLs;
- (GTLRCamera_ModelCameraMessagesCameraMessage*) cameraForRegionIndex:(NSInteger) regionIndex cameraIndex:(NSInteger) cameraIndex;
- (GTLRCamera_ModelCameraMessagesCameraMessage*) cameraForRegion:(NSString*) regionName camera:(NSString*) cameraName;
- (GTLRCamera_ModelCameraMessagesCameraMessage*) defaultCamera;
- (NSString*) regionForIndex:(NSInteger) index;
- (NSInteger) indexForRegion:(NSString*) regionName;
- (NSInteger) cameraCountForRegion:(NSString*) regionName;
- (NSInteger) cameraCountForRegionIndex:(NSInteger) regionIndex;
- (NSString*) cameraNameForRegionIndex:(NSInteger)regionIndex cameraIndex:(NSInteger) cameraIndex;
+ (instancetype) sharedModel;

@end
