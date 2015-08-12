//
//  TodayViewController.m
//  HackWindsTodayWidget
//
//  Created by Matthew Iannucci on 8/5/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//
#define modelFetchBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#import "TodayViewController.h"
#import <HackWindsDataKit/HackWindsDataKit.h>
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>

// UI Properties
@property (weak, nonatomic) IBOutlet UILabel *buoyStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *tideCurrentStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextTideEventLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdatedLabel;

// Cached objects
@property (strong, nonatomic) Buoy *latestBuoy;
@property (strong, nonatomic) Tide *latestTide;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if ((self.latestBuoy != nil) && (self.latestTide !=nil)) {
        [self reloadUI];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    [self updateViewAynsc];
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    completionHandler(NCUpdateResultNewData);
}

- (BOOL)updateData {
    // Fetch new data
    self.latestBuoy = [BuoyModel getLatestBuoyDataOnlyForLocation:BLOCK_ISLAND_LOCATION];
    self.latestTide = [TideModel getLatestTidalEventOnly];
    
    return (self.latestBuoy != nil) && [self.latestTide isTidalEvent];
}

- (void) updateViewAynsc {
    // Load the date asynchronously
    dispatch_async(modelFetchBgQueue, ^{
        BOOL loadSuccess = [self updateData];
        if (loadSuccess) {
            [self performSelectorOnMainThread:@selector(reloadUI)
                                             withObject:nil waitUntilDone:YES];
        }
    });
}

- (void)reloadUI {
    if ((self.latestBuoy == nil) || (self.latestTide == nil)) {
        return;
    }
    
    // Load the buoy UI from the buoy point collected
    NSString *buoyStatus = [NSString stringWithFormat:@"%@ ft @ %@s %@", self.latestBuoy.WaveHeight, self.latestBuoy.DominantPeriod, [Buoy getCompassDirection:self.latestBuoy.Direction]];
    [self.buoyStatusLabel setText:buoyStatus];
    
    // Load the tide UI from the latest tide point collected
    NSString *tideCurrentStatus = @"";
    if ([self.latestTide isHighTide]) {
        tideCurrentStatus = @"Incoming";
    } else {
        tideCurrentStatus = @"Outgoing";
    }
    NSString *nextTideEvent = [NSString stringWithFormat:@"%@ - %@", self.latestTide.EventType, self.latestTide.Time];
    [self.tideCurrentStatusLabel setText:tideCurrentStatus];
    [self.nextTideEventLabel setText:nextTideEvent];
    
    // Set the button title to be the time of the last update
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *dateString = [formatter stringFromDate:now];
    [self.lastUpdatedLabel setText:[NSString stringWithFormat:@"last updated at %@", dateString]];
}

@end
