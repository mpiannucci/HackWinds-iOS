//
//  CameraModel.m
//  HackWinds
//
//  Created by Matthew Iannucci on 5/17/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import "CameraModel.h"


static NSString * const HACKWINDS_API_URL = @"https://hackwinds.appspot.com/api/hackwinds_camera_locations_v5.json";
NSString * const CAMERA_DATA_UPDATED_TAG = @"CameraModelDataUpdatedNotification";
NSString * const CAMERA_DATA_UPDATE_FAILED_TAG = @"CameraModelDataUpdateFailedNotification";

static NSString * const HACKWINDS_API_KEY = @"AIzaSyB5oaqXIWcUgQ08jyF6Kf47Xh3zkXbXlts";

@interface CameraModel()

@end

@implementation CameraModel {
    BOOL forceReload;
}

@synthesize cameras;
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
    
    cameras = nil;
    
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
        
        // Grab the latest user defaults
        NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.mpiannucci.HackWinds"];
        [defaults synchronize];
        BOOL showPremium = [defaults boolForKey:@"ShowPremiumContent"];
        
        GTLRCameraQuery_Cameras *camerasQuery = [GTLRCameraQuery_Cameras queryWithPremium:showPremium];
        GTLRCameraService *service = [[GTLRCameraService alloc] init];
        service.APIKey = HACKWINDS_API_KEY;
        [service executeQuery:camerasQuery completionHandler:^(GTLRServiceTicket * _Nonnull callbackTicket, id  _Nullable object, NSError * _Nullable callbackError) {
            if (callbackError != nil || object == nil) {
                NSLog(@"HackWinds Camera API Error: %@", callbackError);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:CAMERA_DATA_UPDATE_FAILED_TAG
                     object:self];
                });
                return;
            }
            
            if ([object isKindOfClass:[GTLRCamera_ModelCameraMessagesCameraLocationsMessage class]]) {
                cameras = (GTLRCamera_ModelCameraMessagesCameraLocationsMessage*)object;
            }
            
            if (cameras != nil) {
                defaultCamera = [self cameraForRegion:@"Narragansett" camera:@"Warm Winds"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:CAMERA_DATA_UPDATED_TAG
                                   object:self];
                });
            }
        }];
    }
}

- (void) forceFetchCameraURLs {
    forceReload = YES;
    return [self fetchCameraURLs];
}

- (GTLRCamera_ModelCameraMessagesCameraMessage*) cameraForRegionIndex:(NSInteger) regionIndex cameraIndex:(NSInteger) cameraIndex {
    if (regionIndex >= self.cameras.cameraLocations.count) {
        return nil;
    }
    
    GTLRCamera_ModelCameraMessagesCameraRegionMessage *region = [self.cameras.cameraLocations objectAtIndex:regionIndex];
    if (cameraIndex >= region.cameras.count) {
        return nil;
    }
    
    return [[region cameras] objectAtIndex:cameraIndex];
}

- (GTLRCamera_ModelCameraMessagesCameraMessage*) cameraForRegion:(NSString *)regionName camera:(NSString *)cameraName {
    NSInteger regionIndex = [self indexForRegion:regionName];
    if (regionIndex < 0) {
        return nil;
    }
    GTLRCamera_ModelCameraMessagesCameraRegionMessage *region = [self.cameras.cameraLocations objectAtIndex:regionIndex];
    
    for (GTLRCamera_ModelCameraMessagesCameraMessage *camera in region.cameras) {
        if (![camera.name isEqualToString:cameraName]) {
            continue;
        }
        
        return camera;
    }
    
    return nil;
}

- (NSString*) regionForIndex:(NSInteger) index {
    if (index >= self.cameras.cameraLocations.count) {
        return @"";
    }
    
    return [[self.cameras.cameraLocations objectAtIndex:index] name];
}

- (NSInteger) indexForRegion:(NSString*) regionName {
    for (int i = 0; i < self.cameras.cameraLocations.count; i++) {
        if ([[[self.cameras.cameraLocations objectAtIndex:i] name] isEqualToString:regionName]) {
            return i;
        }
    }
    
    return -1;
}

- (NSInteger) cameraCountForRegion:(NSString*) regionName {
    NSInteger regionIndex = [self indexForRegion:regionName];
    if (regionIndex < 1) {
        return 0;
    }
    
    return [self cameraCountForRegionIndex:regionIndex];
}

- (NSInteger) cameraCountForRegionIndex:(NSInteger) regionIndex {
    if (regionIndex >= self.cameras.cameraLocations.count) {
        return 0;
    }
    
    return [[[self.cameras.cameraLocations objectAtIndex:regionIndex] cameras] count];
}

- (NSString*) cameraNameForRegionIndex:(NSInteger)regionIndex cameraIndex:(NSInteger) cameraIndex {
    GTLRCamera_ModelCameraMessagesCameraMessage *camera = [self cameraForRegionIndex:regionIndex cameraIndex:cameraIndex];
    if (camera == nil) {
        return nil;
    }
    
    return camera.name;
}

@end
