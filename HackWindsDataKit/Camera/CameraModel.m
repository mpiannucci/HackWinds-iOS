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

- (BOOL) fetchPointJudithURLs;

@end

@implementation CameraModel {
    BOOL forceReload;
    int cameraCount;
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
    
    int cameraCount = 0;
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
            Camera *thisCamera = [[Camera alloc] init];
            
            if ([cameraName isEqualToString:@"Point Judith"]) {
                // TODO: PJ Support
                continue;
            }
            
            // Create a new camera object to store
            thisCamera.ImageURL = [NSURL URLWithString:[[[cameraDict objectForKey:locationName] objectForKey:cameraName] objectForKey:@"Image"]];
            thisCamera.VideoURL = [NSURL URLWithString:[[[cameraDict objectForKey:locationName] objectForKey:cameraName] objectForKey:@"Video"]];
            thisCamera.Info = [[[cameraDict objectForKey:locationName] objectForKey:cameraName] objectForKey:@"Info"];
            
            tempDict[locationName][cameraName] = thisCamera;
        }
    }
    
    self.cameraURLS = tempDict;
    
    // Handle the special point judith camera
//    if ([narragansettDict count] > 3) {
//        NSURL *pointJudithURL = [NSURL URLWithString:[narragansettDict objectForKey:@"Point Judith"]];
//        NSData *pointJudithResponse = [NSData dataWithContentsOfURL:pointJudithURL];
//        NSError *pjError;
//        NSDictionary *pointJudithData = [NSJSONSerialization
//                                         JSONObjectWithData:pointJudithResponse
//                                         options:kNilOptions
//                                         error:&pjError];
//        NSDictionary *pointJudithStreamData = [[[pointJudithData objectForKey:@"streamInfo"] objectForKey:@"stream"] objectAtIndex:0];
//        [narragansettDict setObject:pointJudithStreamData forKey:@"Point Judith"];
//        [cameraDict setObject:[NSDictionary dictionaryWithDictionary:narragansettDict] forKey:@"Narragansett"];
//    }
    
    // Save the camera urls to defaults and set the reload state
    forceReload = NO;
    
    return YES;
}

- (BOOL) forceFetchCameraURLs {
    forceReload = YES;
    return [self fetchCameraURLs];
}

- (BOOL) fetchPointJudithURLs {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL needsFetch = [defaults boolForKey:@"NeedCameraLocationFetch"];
    
    if (needsFetch) {
        return NO;
    }
    
    NSMutableDictionary *narragansettDict = [[defaults objectForKey:@"CameraLocations"] objectForKey:@"Narragansett"];
    NSURL *pointJudithURL = [NSURL URLWithString:[narragansettDict objectForKey:@"Point Judith"]];
    NSData *pointJudithResponse = [NSData dataWithContentsOfURL:pointJudithURL];
    NSError *error;
    NSDictionary *pointJudithData = [NSJSONSerialization
                                  JSONObjectWithData:pointJudithResponse
                                  options:kNilOptions
                                  error:&error];
    NSDictionary *pointJudithStreamData = [[[pointJudithData objectForKey:@"streamInfo"] objectForKey:@"stream"] objectAtIndex:0];
    [narragansettDict setValue:pointJudithStreamData forKey:@"Point Judith"];
    
    return YES;
}

@end
