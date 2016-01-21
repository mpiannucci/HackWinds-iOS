//
//  CameraModel.m
//  HackWinds
//
//  Created by Matthew Iannucci on 5/17/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import "CameraModel.h"
#import "Camera.h"

static NSString * const HACKWINDS_API_URL = @"https://mpiannucci.appspot.com/static/API/hackwinds_camera_locations_v3.json";
NSString * const CAMERA_DATA_UPDATED_TAG = @"CameraModelDataUpdatedNotification";
NSString * const CAMERA_DATA_UPDATE_FAILED_TAG = @"CameraModelDataUpdateFailedNotification";

@interface CameraModel()

- (BOOL) parseCamerasFromData:(NSData*)rawData;
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

- (void) fetchCameraURLs {
    @synchronized(self) {
        if (!forceReload) {
            // Tell everything you have camera data
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:CAMERA_DATA_UPDATED_TAG
                 object:self];
            });
        }
        
        NSURLSessionTask *cameraTask = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:HACKWINDS_API_URL] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (error != nil) {
                NSLog(@"Failed to fetch camera data from API");
                
                // Send failure notification
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:CAMERA_DATA_UPDATE_FAILED_TAG
                     object:self];
                });
                
                return;
            }
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
            if (httpResponse.statusCode != 200) {
                NSLog(@"HTTP Error receiving camera data");
                
                // Send failure notification
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:CAMERA_DATA_UPDATE_FAILED_TAG
                     object:self];
                });
                
                return;
            }
            
            BOOL parsedCameras = [self parseCamerasFromData:data];
            if (parsedCameras) {
                // Tell everything you have camera data
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:CAMERA_DATA_UPDATED_TAG
                     object:self];
                });
            }
        }];
        
        [cameraTask resume];
    }
}

- (void) forceFetchCameraURLs {
    forceReload = YES;
    return [self fetchCameraURLs];
}

- (BOOL) parseCamerasFromData:(NSData *)rawData {
    NSError *error;
    NSDictionary *settingsData = [NSJSONSerialization
                                  JSONObjectWithData:rawData
                                  options:kNilOptions
                                  error:&error];
    
    if ((settingsData == nil) || (error != nil)) {
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
                // Skip this for now!!!
                // TODO: Refactor to support more cameras and better supplimentary fetching
                continue;
                //thisCamera = [self fetchPointJudithURLs:[thisCameraDict objectForKey:@"Info"]];
            } else {
                thisCamera.videoURL = [NSURL URLWithString:[thisCameraDict objectForKey:@"Video"]];
            }
            
            if (thisCamera == nil) {
                continue;
            }
            
            // For now, the image is common
            thisCamera.imageURL = [NSURL URLWithString:[thisCameraDict objectForKey:@"Image"]];
            [thisCamera setIsRefreshable:[[thisCameraDict objectForKey:@"Refreshable"] boolValue]];
            [thisCamera setRefreshDuration:[[thisCameraDict objectForKey:@"RefreshInterval"] intValue]];
            
            tempDict[locationName][cameraName] = thisCamera;
        }
    }
    
    self.cameraURLS = tempDict;
    
    // Save the camera urls to defaults and set the reload state
    forceReload = NO;
    
    return YES;
}

- (Camera *) fetchPointJudithURLs:(NSString *)locationURL {
    NSURL *pointJudithURL = [NSURL URLWithString:locationURL];
    NSData *pointJudithResponse = [NSData dataWithContentsOfURL:pointJudithURL];
    NSError *error = nil;
    NSDictionary *pointJudithData = [NSJSONSerialization
                                    JSONObjectWithData:pointJudithResponse
                                    options:kNilOptions
                                    error:&error];
    if (error != nil) {
        // Nothing was read so give a null pointer back
        return nil;
    }
    
    NSDictionary *pointJudithStreamData = [[[pointJudithData objectForKey:@"streamInfo"] objectForKey:@"stream"] objectAtIndex:0];
    
    Camera *thisCamera = [[Camera alloc] init];
    thisCamera.videoURL = [NSURL URLWithString:[pointJudithStreamData objectForKey:@"file"]];
    thisCamera.info = [NSString stringWithFormat:@"Camera Status: %@\nDate: %@\nTime: %@\n\nIf the video does not play, the camera may be down. It is a daily upload during the summer and it becomes unavailable each evening.", [pointJudithStreamData objectForKey:@"camStatus"],
                       [pointJudithStreamData objectForKey:@"reportDate"], [pointJudithStreamData objectForKey:@"reportTime"]];
    
    return thisCamera;

}

@end
