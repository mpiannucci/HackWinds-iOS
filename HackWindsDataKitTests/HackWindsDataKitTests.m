//
//  HackWindsDataKitTests.m
//  HackWindsDataKitTests
//
//  Created by Matthew Iannucci on 7/24/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <HackWindsDataKit/HackWindsDataKit.h>

@interface HackWindsDataKitTests : XCTestCase

@property (strong, nonatomic) CameraModel *cameraModel;
@property (strong, nonatomic) ForecastModel *forecastModel;
@property (strong, nonatomic) BuoyModel *buoyModel;
@property (strong, nonatomic) TideModel *tideModel;

@end

@implementation HackWindsDataKitTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.cameraModel = [CameraModel sharedModel];
    self.forecastModel = [ForecastModel sharedModel];
    self.buoyModel = [BuoyModel sharedModel];
    self.tideModel = [TideModel sharedModel];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testCameraModelFetch {
    XCTAssert([self.cameraModel fetchCameraURLs]);
}

- (void) testForecastModelFetch {
    XCTAssert([[self.forecastModel getConditionsForIndex:0] count] > 0);
}

- (void) testBuoyModelFetch {
    XCTAssert([[self.buoyModel getBuoyDataForLocation:BLOCK_ISLAND_LOCATION] count] > 0);
}

- (void) testTideModelFetch {
    XCTAssert([[self.tideModel getTideData] count] > 0);
}

@end
