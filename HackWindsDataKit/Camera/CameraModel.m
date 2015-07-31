//
//  CameraModel.m
//  HackWinds
//
//  Created by Matthew Iannucci on 5/17/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//
#define HACKWINDS_API_URL [NSURL URLWithString:@"http://blog.mpiannucci.com/static/API/hackwinds_camera_locations_v3.json"]

#import "CameraModel.h"
#import "Camera.h"

@interface CameraModel()

- (Camera *) fetchPointJudithURLs:(NSString *)locationURL;

@end

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
    
    self.cameraURLS = [[NSDictionary alloc] init];
    
    return self;
}

- (BOOL) fetchCameraURLs {
    
    if (!forceReload) {
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

    NSDictionary *cameraDict = [NSMutableDictionary dictionaryWithDictionary:[settingsData objectForKey:@"camera_locations"]];
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    
    for (NSString* locationName in cameraDict) {
        tempDict[locationName] = [[NSMutableDictionary alloc] init];
        
        for (NSString *cameraName in [cameraDict objectForKey:locationName]) {
            
            NSDictionary *thisCameraDict = [[cameraDict objectForKey:locationName] objectForKey:cameraName];
            Camera *thisCamera = [[Camera alloc] init];
            
            if ([cameraName isEqualToString:@"Point Judith"]) {
                thisCamera = [self fetchPointJudithURLs:[thisCameraDict objectForKey:@"Info"]];
            } else {
                thisCamera.VideoURL = [NSURL URLWithString:[thisCameraDict objectForKey:@"Video"]];
            }
            
            // For now, the image is common
            thisCamera.ImageURL = [NSURL URLWithString:[thisCameraDict objectForKey:@"Image"]];
            [thisCamera setIsRefreshable:[[thisCameraDict objectForKey:@"Refreshable"] boolValue]];
            [thisCamera setRefreshDuration:(int)[[thisCameraDict objectForKey:@"RefreshDuration"] integerValue]];
            
            tempDict[locationName][cameraName] = thisCamera;
        }
    }
    
    self.cameraURLS = tempDict;
    
    // Save the camera urls to defaults and set the reload state
    forceReload = NO;
    
    return YES;
}

- (BOOL) forceFetchCameraURLs {
    forceReload = YES;
    return [self fetchCameraURLs];
}

- (Camera *) fetchPointJudithURLs:(NSString *)locationURL {
    NSURL *pointJudithURL = [NSURL URLWithString:locationURL];
    NSData *pointJudithResponse = [NSData dataWithContentsOfURL:pointJudithURL];
    NSError *error;
    NSDictionary *pointJudithData = [NSJSONSerialization
                                    JSONObjectWithData:pointJudithResponse
                                    options:kNilOptions
                                    error:&error];
    NSDictionary *pointJudithStreamData = [[[pointJudithData objectForKey:@"streamInfo"] objectForKey:@"stream"] objectAtIndex:0];
    
    Camera *thisCamera = [[Camera alloc] init];
    thisCamera.VideoURL = [NSURL URLWithString:[pointJudithStreamData objectForKey:@"file"]];
    thisCamera.Info = [NSString stringWithFormat:@"Camera Status: %@\nDate: %@\nTime: %@\n\nIf the video does not play, the camera may be down. It is a daily upload during the summer and it becomes unavailable each evening.", [pointJudithStreamData objectForKey:@"camStatus"],
                       [pointJudithStreamData objectForKey:@"reportDate"], [pointJudithStreamData objectForKey:@"reportTime"]];
    
    return thisCamera;

}

@end
