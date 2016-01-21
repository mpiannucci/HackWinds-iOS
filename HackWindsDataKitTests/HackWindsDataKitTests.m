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
//    XCTAssert([self.cameraModel fetchCameraURLs]);
//    
//    Camera *wwCamera = [[[self.cameraModel cameraURLS] objectForKey:@"Narragansett"] objectForKey:@"Warm Winds"];
//    XCTAssert(wwCamera.isRefreshable == false);
}

- (void) testForecastModelFetch {
    // Fetch the conditions and forecasts
//    XCTAssert([self.forecastModel fetchForecastData]);
//    
//    // Check theres the correct amount of data objects
//    XCTAssert([[self.forecastModel getConditions] count] == 30);
//    XCTAssert([[self.forecastModel getForecasts] count] == 10);
//    
//    // Check the condition splitting
//    NSArray *firstConditions = [self.forecastModel getConditionsForIndex:0];
//    XCTAssert(firstConditions.count == 6);
//    Condition *startCondition = [firstConditions objectAtIndex:0];
//    Condition *endCondition = [firstConditions objectAtIndex:5];
//    XCTAssert([startCondition.timestamp isEqualToString:@"6 AM"]);
//    XCTAssert([endCondition.timestamp isEqualToString:@"9 PM"]);
}

- (void) testBuoyModelFetch {
//    // Try fetching and parsing the block island buoy data
//    [self.buoyModel forceChangeLocation:MONTAUK_LOCATION];
//    XCTAssert([self.buoyModel fetchBuoyData]);
//    XCTAssert([[self.buoyModel getBuoyData] count] == 20);
//    
//    // Try getting and parsing the montauk data
//    XCTAssert([self.buoyModel fetchBuoyData]);
//    XCTAssert([[self.buoyModel getBuoyData] count] == 20);
//    
//    // Try getting and parsing the nantucket data
//    XCTAssert([self.buoyModel fetchBuoyData]);
//    XCTAssert([[self.buoyModel getBuoyData] count] == 20);
//    
//    // Try to get only the latest data point with the static method
//    XCTAssert([BuoyModel getOnlyLatestBuoyDataForLocation:@"Montauk"] != nil);
}

- (void) testTideModelFetch {
//    XCTAssert([self.tideModel fetchTideData]);
//    
//    // Check for the correct amount of data points
//    XCTAssert(self.tideModel.tides.count == 6);
//    
//    // Check for each data type there should be
//    int sunriseCount = 0;
//    int sunsetCount = 0;
//    int highTideCount = 0;
//    int lowTideCount = 0;
//    
//    for (Tide *tide in self.tideModel.tides) {
//        if ([tide isSunrise]) {
//            sunriseCount++;
//        } else if ([tide isSunset]) {
//            sunsetCount++;
//        } else if ([tide isHighTide]) {
//            highTideCount++;
//        } else if ([tide isLowTide]) {
//            lowTideCount++;
//        }
//    }
//    
//    // Make sure there are the correct amount of each event
//    XCTAssert(sunriseCount == 1);
//    XCTAssert(sunsetCount == 1);
//    XCTAssert(highTideCount == 2);
//    XCTAssert(lowTideCount == 2);
//    
//    // Try the static getter
//    Tide *newestTidalEvent = [TideModel getLatestTidalEventOnly];
//    XCTAssert(newestTidalEvent != nil);
//    XCTAssert([newestTidalEvent isTidalEvent]);
}

@end
