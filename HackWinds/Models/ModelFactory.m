//
//  ModelFactory.m
//  HackWinds
//
//  Created by Matthew Iannucci on 7/22/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import "ModelFactory.h"

@interface ModelFactory()

@end

@implementation ModelFactory

+ (instancetype) sharedFactory {
    static ModelFactory *_sharedFactory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // code to be executed once - thread safe version!
        _sharedFactory = [[self alloc] init];
    });
    return _sharedFactory;
}

- (id)init
{
    self = [super init];
    
    return self;
}

+ (GoHackwindsdataCameraModel *) getCameraModel {
    static GoHackwindsdataCameraModel *_sharedCameraModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // code to be executed once - thread safe version!
        _sharedCameraModel = GoHackwindsdataNewCameraModel();
    });
    return _sharedCameraModel;
}

+ (GoHackwindsdataForecastModel *) getForecastModel {
    static GoHackwindsdataForecastModel *_sharedForecastModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // code to be executed once - thread safe version!
        _sharedForecastModel = GoHackwindsdataNewForecastModel();
        
        // Get the current location and setup the settings listener
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [[NSUserDefaults standardUserDefaults] addObserver:[ModelFactory sharedFactory]
                                                forKeyPath:@"ForecastLocation"
                                                   options:NSKeyValueObservingOptionNew
                                                   context:NULL];
        [_sharedForecastModel ChangeForecastLocation:[defaults objectForKey:@"ForecastLocation"]];
    });
    return _sharedForecastModel;
}

+ (GoHackwindsdataBuoyModel *) getBuoyModel {
    static GoHackwindsdataBuoyModel *_sharedBuoyModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // code to be executed once - thread safe version!
        _sharedBuoyModel = GoHackwindsdataNewBuoyModel();
    });
    return _sharedBuoyModel;
}

+ (GoHackwindsdataTideModel *) getTideModel {
    static GoHackwindsdataTideModel *_sharedTideModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // code to be executed once - thread safe version!
        _sharedTideModel = GoHackwindsdataNewTideModel();
    });
    return _sharedTideModel;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    GoHackwindsdataForecastModel *forecastModel = [ModelFactory getForecastModel];
    
    if (forecastModel == nil) {
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [forecastModel ChangeForecastLocation:[defaults objectForKey:@"ForecastLocation"]];
    
    // Tell everyone the data has to be updated
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"ForecastModelDidUpdateDataNotification"
         object:self];
    });
}

@end
