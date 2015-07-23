//
//  ModelFactory.h
//  HackWinds
//
//  Created by Matthew Iannucci on 7/22/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HackWindsData/Hackwindsdata.h>

@interface ModelFactory : NSObject

- (GoHackwindsdataCameraModel *) getCameraModel;
- (GoHackwindsdataForecastModel *) getForecastModel;
- (GoHackwindsdataBuoyModel *) getBuoyModel;
- (GoHackwindsdataTideModel *) getTideModel;

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

+ (instancetype) sharedFactory;

@end
