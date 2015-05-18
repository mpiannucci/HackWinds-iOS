//
//  CameraModel.m
//  HackWinds
//
//  Created by Matthew Iannucci on 5/17/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//
#define HACKWINDS_API_URL [NSURL URLWithString:@"http://blog.mpiannucci.com/static/hackwinds_camera_locations.json"]

#import "CameraModel.h"

@implementation CameraModel {
    BOOL forceReload;
}

+ (instancetype) sharedModel {
    static CameraModel *_sharedModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // code to be executed once - thread safe version!
        _sharedModel = [[self alloc] init];
    });
    
    return _sharedModel;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        forceReload = NO;
    }
    
    return self;
}

- (BOOL) fetchCameraURLs {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL needsFetch = [defaults boolForKey:@"NeedCameraLocationFetch"];
    
    if (!needsFetch && !forceReload) {
        return true;
    }
    
    NSData *cameraResponse = [NSData dataWithContentsOfURL:HACKWINDS_API_URL];
    NSError *error;
    NSDictionary *settingsData = [NSJSONSerialization
               JSONObjectWithData:cameraResponse
               options:kNilOptions
               error:&error];
    
    if (settingsData == nil) {
        return false;
    }
    
    // Save the camera urls to defaults and set the reload state
    [defaults setObject:[settingsData objectForKey:@"camera_locations"] forKey:@"CameraLocations"];
    [defaults setBool:NO forKey:@"NeedCameraLocationFetch"];
    forceReload = NO;
    return true;
}

- (BOOL) forceFetchCameraURLs {
    forceReload = YES;
    return [self fetchCameraURLs];
}

@end
