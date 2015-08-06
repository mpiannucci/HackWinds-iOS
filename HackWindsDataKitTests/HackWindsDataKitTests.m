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
    XCTAssert([self.forecastModel fetchForecastData]);
    
    // Check theres the correct amount of data objects
    XCTAssert(self.forecastModel.conditions.count == 30);
    XCTAssert(self.forecastModel.forecasts.count == 10);
    
    // Check the condition splitting
    NSArray *firstConditions = [self.forecastModel getConditionsForIndex:0];
    XCTAssert(firstConditions.count == 6);
    XCTAssert([[[firstConditions objectAtIndex:0] Date] isEqualToString:@"6 AM"]);
    XCTAssert([[[firstConditions objectAtIndex:5] Date] isEqualToString:@"9 PM"]);
}

- (void) testBuoyModelFetch {
    XCTAssert([self.buoyModel fetchBuoyDataForLocation:BLOCK_ISLAND_LOCATION]);
    XCTAssert([[self.buoyModel getBuoyDataForLocation:BLOCK_ISLAND_LOCATION] count] == 20);
    
    XCTAssert([self.buoyModel fetchBuoyDataForLocation:MONTAUK_LOCATION]);
    XCTAssert([[self.buoyModel getBuoyDataForLocation:MONTAUK_LOCATION] count] == 20);
}

- (void) testTideModelFetch {
    XCTAssert([self.tideModel fetchTideData]);
    
    // Check for the correct amount of data points
    XCTAssert(self.tideModel.tides.count == 6);
    
    // Check for each data type there should be
    int sunriseCount = 0;
    int sunsetCount = 0;
    int highTideCount = 0;
    int lowTideCount = 0;
    
    for (Tide *tide in self.tideModel.tides) {
        if ([tide isSunrise]) {
            sunriseCount++;
        } else if ([tide isSunset]) {
            sunsetCount++;
        } else if ([tide isHighTide]) {
            highTideCount++;
        } else if ([tide isLowTide]) {
            lowTideCount++;
        }
    }
    
    XCTAssert(sunriseCount == 1);
    XCTAssert(sunsetCount == 1);
    XCTAssert(highTideCount == 2);
    XCTAssert(lowTideCount == 2);
}

@end
