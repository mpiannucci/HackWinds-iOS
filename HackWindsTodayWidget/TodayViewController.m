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
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;

// Model Properties
@property (strong, nonatomic) BuoyModel *buoyModel;
@property (strong, nonatomic) TideModel *tideModel;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self updateViewAynsc];
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
    [self updateViewAynsc];
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    completionHandler(NCUpdateResultNewData);
}

- (BOOL)updateData {
    // Make sure the models are not null
    if (self.buoyModel == nil) {
        self.buoyModel = [BuoyModel sharedModel];
    }
    if (self.tideModel == nil) {
        self.tideModel = [TideModel sharedModel];
    }
    
    // Reset the models
    [self.buoyModel resetData];
    [self.tideModel resetData];
    
    // Fetch new data
    bool buoyFetchSuccess = [self.buoyModel fetchBuoyDataForLocation:BLOCK_ISLAND_LOCATION];
    bool tideFetchSuccess = [self.tideModel fetchTideData];
    
    return (buoyFetchSuccess && tideFetchSuccess) && true;
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
    // Load the buoy UI
    Buoy *thisBuoy = [[self.buoyModel getBuoyDataForLocation:BLOCK_ISLAND_LOCATION] objectAtIndex:0];
    NSString *buoyStatus = [NSString stringWithFormat:@"%@ ft @ %@s %@", thisBuoy.WaveHeight, thisBuoy.DominantPeriod, [Buoy getCompassDirection:thisBuoy.Direction]];
    [self.buoyStatusLabel setText:buoyStatus];
    
    // Load the tide UI
    NSString *tideCurrentStatus = @"";
    NSString *nextTideEvent = @"";
    for ( Tide *thisTide in self.tideModel.tides) {
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
    
    // Set the button title to be the time of the last update
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *dateString = [formatter stringFromDate:now];
    [self.refreshButton setTitle:[NSString stringWithFormat:@"Updated: %@ - Click to Refresh", dateString] forState:UIControlStateNormal];
}

- (IBAction)refreshButtonClick:(id)sender {
    [self updateViewAynsc];
}

@end
