//
//  CameraModel.m
//  HackWinds
//
//  Created by Matthew Iannucci on 5/17/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import "CameraModel.h"
#import "Camera.h"

static NSString * const HACKWINDS_API_URL = @"https://hackwinds.appspot.com/api/hackwinds_camera_locations_v5.json";
NSString * const CAMERA_DATA_UPDATED_TAG = @"CameraModelDataUpdatedNotification";
NSString * const CAMERA_DATA_UPDATE_FAILED_TAG = @"CameraModelDataUpdateFailedNotification";

@interface CameraModel()

- (BOOL) parseCamerasFromData:(NSData*)rawData;

@end

@implementation CameraModel {
    BOOL forceReload;
}

@synthesize defaultCamera;

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
    
    defaultCamera = nil;
    
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
    
    // Grab the latest user defaults
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.mpiannucci.HackWinds"];
    [defaults synchronize];
    BOOL showPremium = [defaults boolForKey:@"ShowPremiumContent"];
    
    NSDictionary *cameraDict = [NSMutableDictionary dictionaryWithDictionary:[settingsData objectForKey:@"CameraLocations"]];
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    
    for (NSString* locationName in cameraDict) {
        tempDict[locationName] = [[NSMutableDictionary alloc] init];
        
        for (NSString *cameraName in [cameraDict objectForKey:locationName]) {
            
            NSDictionary *thisCameraDict = [[cameraDict objectForKey:locationName] objectForKey:cameraName];
            Camera *thisCamera = [[Camera alloc] init];
            
            thisCamera.imageURL = [NSURL URLWithString:[thisCameraDict objectForKey:@"Image"]];
            thisCamera.videoURL = [NSURL URLWithString:[thisCameraDict objectForKey:@"Video"]];
            thisCamera.webURL = [NSURL URLWithString:[thisCameraDict objectForKey:@"Web"]];
            [thisCamera setIsRefreshable:[[thisCameraDict objectForKey:@"Refreshable"] boolValue]];
            [thisCamera setRefreshDuration:[[thisCameraDict objectForKey:@"RefreshInterval"] intValue]];
            [thisCamera setPremium:[[thisCameraDict objectForKey:@"Premium"] boolValue]];
            
            if ([cameraName isEqualToString:@"Warm Winds"]) {
                // For now hard code this default camera
                defaultCamera = thisCamera;
            }
            
            if ([thisCamera isPremium] && !showPremium) {
                continue;
            }
            
            tempDict[locationName][cameraName] = thisCamera;
        }
        
        if ([tempDict[locationName] count] < 1) {
            [tempDict removeObjectForKey:locationName];
        }
    }
    
    self.cameraURLS = tempDict;
    
    // Save the camera urls to defaults and set the reload state
    forceReload = NO;
    
    return YES;
}

- (Camera*) cameraForLocation:(NSString*) locationName camera:(NSString*) cameraName {
    return [[self.cameraURLS objectForKey:locationName] objectForKey:cameraName];
}

@end
