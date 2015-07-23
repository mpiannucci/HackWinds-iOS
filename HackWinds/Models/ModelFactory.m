//
//  ModelFactory.m
//  HackWinds
//
//  Created by Matthew Iannucci on 7/22/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import "ModelFactory.h"

@interface ModelFactory()

@property (strong, nonatomic) GoHackwindsdataCameraModel *cameraModel;
@property (strong, nonatomic) GoHackwindsdataForecastModel *forecastModel;
@property (strong, nonatomic) GoHackwindsdataBuoyModel *buoyModel;
@property (strong, nonatomic) GoHackwindsdataTideModel *tideModel;

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

- (GoHackwindsdataCameraModel *) getCameraModel {
    if (self.cameraModel == nil) {
        self.cameraModel = GoHackwindsdataNewCameraModel();
    }
    return self.cameraModel;
}

- (GoHackwindsdataForecastModel *) getForecastModel {
    if (self.forecastModel == nil) {
        self.forecastModel = GoHackwindsdataNewForecastModel();
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        // Get the current location and setup the settings listener
        [defaults addObserver:self
                   forKeyPath:@"ForecastLocation"
                      options:NSKeyValueObservingOptionNew
                      context:NULL];
        
        // Initialize the location
        [self.forecastModel ChangeForecastLocation:[defaults objectForKey:@"ForecastLocation"]];
    }
    return self.forecastModel;
}

- (GoHackwindsdataBuoyModel *) getBuoyModel {
    if (self.buoyModel == nil) {
        self.buoyModel = GoHackwindsdataNewBuoyModel();
    }
    return self.buoyModel;
}

- (GoHackwindsdataTideModel *) getTideModel {
    if (self.tideModel == nil) {
        self.tideModel = GoHackwindsdataNewTideModel();
    }
    return self.tideModel;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (self.forecastModel == nil) {
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self.forecastModel ChangeForecastLocation:[defaults objectForKey:@"ForecastLocation"]];
    
    // Tell everyone the data has to be updated
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"ForecastModelDidUpdateDataNotification"
         object:self];
    });
}

@end
