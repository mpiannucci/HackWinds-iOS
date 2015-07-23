//
//  TideViewController.m
//  HackWinds
//
//  Created by Matthew Iannucci on 7/27/14.
//  Copyright (c) 2014 Matthew Iannucci. All rights reserved.
//
#define TIDE_FETCH_BG_QUEUE dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#import "TideViewController.h"
#import "TideModel.h"
#import "Tide.h"
#import "BuoyModel.h"
#import "Buoy.h"
#import "Colors.h"
#import "Reachability.h"
#import "ModelFactory.h"
#import <HackWindsData/Hackwindsdata.h>

@implementation TideViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Get the buoy data and reload the views
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    if (networkStatus != NotReachable) {
        dispatch_async(TIDE_FETCH_BG_QUEUE, ^{
            [[ModelFactory getTideModel] FetchTideData];
            [[ModelFactory getBuoyModel] FetchBlockIslandBuoyData];
            [self performSelectorOnMainThread:@selector(reloadView) withObject:nil waitUntilDone:YES];
        });
    }
}

- (void)viewDidLayoutSubviews {
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadView {
    // If there are no tide items return early
    if ([[ModelFactory getTideModel] TideCount] == 0) {
        return;
    }
    
    int tideCount = 0;
    for (int i = 0; i < [[ModelFactory getTideModel] TideCount]; i++) {
        // Then check what is is again, and set correct text box
        GoHackwindsdataTide *tideEvent = [[ModelFactory getTideModel] GetTideEventForIndex:i];
        if ([[tideEvent EventType] isEqualToString:SUNRISE_TAG]) {
            // Get the first row in the sunrise and sunset section and set the text of the label to the time
            UILabel* sunriseLabel = (UILabel*)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]] viewWithTag:61];
            NSString* sunrisetext = [NSString stringWithFormat:@"Sunrise: %@", tideEvent.Time];
            [sunriseLabel setText:sunrisetext];
            
        } else if ([[tideEvent EventType] isEqualToString:SUNSET_TAG]) {
            // Get the second row in the sunrise and sunset section and set the text of the label to the time
            UILabel* sunsetLabel = (UILabel*)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]] viewWithTag:61];
            NSString* sunsetText = [NSString stringWithFormat:@"Sunset: %@", tideEvent.Time];
            [sunsetLabel setText:sunsetText];
            
        } else if ([[tideEvent EventType] isEqualToString:HIGH_TIDE_TAG] ||
                   [[tideEvent EventType] isEqualToString:LOW_TIDE_TAG] ) {
            // Get the next cell and its label so we can update it
            UILabel* tideLabel = (UILabel*)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:tideCount inSection:1]] viewWithTag:51];
            NSString* tideText = [NSString stringWithFormat:@"%@: %@ at %@", tideEvent.EventType, tideEvent.Height, tideEvent.Time];
            [tideLabel setText:tideText];
            
            // If its the first object, set it to the current status
            if (tideCount == 0) {
                // Get the current tide label
                UILabel* currentTideLabel = (UILabel*)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] viewWithTag:41];
                
                if ([tideEvent.EventType isEqualToString:HIGH_TIDE_TAG]) {
                    // Show that the tide is incoming, using green because typically surf increases with incoming tides
                    [currentTideLabel setText:@"Incoming"];
                    [currentTideLabel setTextColor:GREEN_COLOR];
                    
                } else if ([tideEvent.EventType isEqualToString:LOW_TIDE_TAG]) {
                    // Show that the tide is outgoing, use red because the surf typically decreases with an outgoing tide
                    [currentTideLabel setText:@"Outgoing"];
                    [currentTideLabel setTextColor:RED_COLOR];
                }
            }
            // Only increment the tide count for a tide event and not a sunrise or sunset
            tideCount++;
        }
    }

    UILabel* currentWaterTempLabel = (UILabel*)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]] viewWithTag:71];
    NSString* waterTemp = [[[ModelFactory getBuoyModel] GetBlockIslandBuoyAtIndex:0] WaterTemperature];
    NSString* waterTempStatus = [NSString stringWithFormat:@"Block Island: %@ %@F", waterTemp, @"\u00B0"];
    [currentWaterTempLabel setText:waterTempStatus];
    
    [self.tableView reloadData];
}

@end
