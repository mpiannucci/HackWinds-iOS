//
//  TodayViewController.m
//  HackWindsTodayWidget
//
//  Created by Matthew Iannucci on 8/5/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import "TodayViewController.h"
#import <HackWindsDataKit/HackWindsDataKit.h>
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>

// UI Properties
@property (weak, nonatomic) IBOutlet UILabel *buoyStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *tideCurrentStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextTideEventLabel;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    static int i = 0;
    [self updateData];
    NSLog(@"%d", i);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    [self updateData];
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    completionHandler(NCUpdateResultNewData);
}

- (BOOL)updateData {
    // Update the buoy data
    BuoyModel *buoyModel = [BuoyModel sharedModel];
    bool buoyFetchSuccess = [buoyModel fetchBuoyDataForLocation:BLOCK_ISLAND_LOCATION];
    if (buoyFetchSuccess) {
        Buoy *thisBuoy = [[buoyModel getBuoyDataForLocation:BLOCK_ISLAND_LOCATION] objectAtIndex:0];
        NSString *buoyStatus = [NSString stringWithFormat:@"%@ ft @ %@s %@", thisBuoy.WaveHeight, thisBuoy.DominantPeriod, [Buoy getCompassDirection:thisBuoy.Direction]];
        [self.buoyStatusLabel setText:buoyStatus];
    }
    
    TideModel *tideModel = [TideModel sharedModel];
    bool tideFetchSuccess = [tideModel fetchTideData];
    if (tideFetchSuccess) {
        NSString *tideCurrentStatus = @"";
        NSString *nextTideEvent = @"";
        for ( Tide *thisTide in tideModel.tides) {
            if ([thisTide isSolarEvent]) {
                continue;
            }
            
            if ([thisTide isHighTide]) {
                tideCurrentStatus = @"Incoming";
            } else {
                tideCurrentStatus = @"Outgoing";
            }
            nextTideEvent = [NSString stringWithFormat:@"%@ - %@", thisTide.EventType, thisTide.Time];
            break;
        }
        [self.tideCurrentStatusLabel setText:tideCurrentStatus];
        [self.nextTideEventLabel setText:nextTideEvent];
    }
    
    return (buoyFetchSuccess && tideFetchSuccess) && true;
}

@end
