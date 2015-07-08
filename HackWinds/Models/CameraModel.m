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
    NSMutableDictionary *cameraDict = [NSMutableDictionary dictionaryWithDictionary:[settingsData objectForKey:@"camera_locations"]];
    NSMutableDictionary *narragansettDict = [NSMutableDictionary dictionaryWithDictionary:[cameraDict objectForKey:@"Narragansett"]];
    
    NSURL *pointJudithURL = [NSURL URLWithString:[narragansettDict objectForKey:@"Point Judith"]];
    NSData *pointJudithResponse = [NSData dataWithContentsOfURL:pointJudithURL];
    NSError *pjError;
    NSDictionary *pointJudithData = [NSJSONSerialization
                                     JSONObjectWithData:pointJudithResponse
                                     options:kNilOptions
                                     error:&pjError];
    NSDictionary *pointJudithStreamData = [[[pointJudithData objectForKey:@"streamInfo"] objectForKey:@"stream"] objectAtIndex:0];
    [narragansettDict setObject:pointJudithStreamData forKey:@"Point Judith"];
    [cameraDict setObject:[NSDictionary dictionaryWithDictionary:narragansettDict] forKey:@"Narragansett"];
    
    [defaults setObject:[NSDictionary dictionaryWithDictionary:cameraDict] forKey:@"CameraLocations"];
    [defaults setBool:NO forKey:@"NeedCameraLocationFetch"];
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
