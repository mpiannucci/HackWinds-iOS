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
#import "Colors.h"

@interface TideViewController ()

@property (strong, nonatomic) TideModel *tideModel;

@end

@implementation TideViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Get the tide model
    _tideModel = [TideModel sharedModel];
    
    // Get the buoy data and reload the views
    dispatch_async(TIDE_FETCH_BG_QUEUE, ^{
        NSMutableArray *tideData = [_tideModel getTideData];
        [self performSelectorOnMainThread:@selector(reloadView:)
                               withObject:tideData waitUntilDone:YES];
    });
}

- (void)viewDidLayoutSubviews {
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadView:(NSMutableArray* ) tideData {
    // If there are no tide items return early
    if ([tideData count] == 0) {
        return;
    }
    
    // First, if it is the first item, check what it is,
    // then set the status accordingly
    int firstIndex = 0;
    if (([[[tideData objectAtIndex:0] EventType] isEqualToString:SUNRISE_TAG]) ||
        ([[[tideData objectAtIndex:0] EventType] isEqualToString:SUNSET_TAG])) {
        // If its sunrise or sunset we dont care for now, skip it.
        firstIndex++;
    }
    NSString* firstEvent = [[tideData objectAtIndex:firstIndex] EventType];
    UILabel* currentTideLabel = (UILabel*)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] viewWithTag:41];
    if ([firstEvent isEqualToString:HIGH_TIDE_TAG]) {
        // Show that the tide is incoming, using green because typically surf increases with incoming tides
        [currentTideLabel setText:@"Incoming"];
        [currentTideLabel setTextColor:GREEN_COLOR];
        
    } else if ([firstEvent isEqualToString:LOW_TIDE_TAG]) {
        // Show that the tide is outgoing, use red because the surf typically decreases with an outgoing tide
        [currentTideLabel setText:@"Outgoing"];
        [currentTideLabel setTextColor:RED_COLOR];
    }
    
    int tideCount = 0;
    for (int i = 0; i < [tideData count]; i++) {
        // Then check what is is again, and set correct text box
        Tide* thisTide = [tideData objectAtIndex:i];
        if ([[thisTide EventType] isEqualToString:SUNRISE_TAG]) {
            // Get the first row in the sunrise and sunset section and set the text of the label to the time
            UILabel* sunriseLabel = (UILabel*)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]] viewWithTag:61];
            NSString* sunrisetext = [NSString stringWithFormat:@"Sunrise: %@", thisTide.Time];
            [sunriseLabel setText:sunrisetext];
        } else if ([[thisTide EventType] isEqualToString:SUNSET_TAG]) {
            // Get the second row in the sunrise and sunset section and set the text of the label to the time
            UILabel* sunsetLabel = (UILabel*)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]] viewWithTag:61];
            NSString* sunsetText = [NSString stringWithFormat:@"Sunset: %@", thisTide.Time];
            [sunsetLabel setText:sunsetText];
        } else if ([[thisTide EventType] isEqualToString:HIGH_TIDE_TAG]) {
            // Get the next cell and its label so we can update it
            UILabel* highTideLabel = (UILabel*)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:tideCount inSection:1]] viewWithTag:51];
            NSString* highTideText = [NSString stringWithFormat:@"High Tide: %@ at %@", thisTide.Height, thisTide.Time];
            [highTideLabel setText:highTideText];
            
            // Only increment the tide count for a tide event and not a sunrise or sunset
            tideCount++;
        } else if ([[thisTide EventType] isEqualToString:LOW_TIDE_TAG]) {
            // Get the next cell and its label so we can update it
            UILabel* lowTideLabel = (UILabel*)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:tideCount inSection:1]] viewWithTag:51];
            NSString* lowTideText = [NSString stringWithFormat:@"Low Tide: %@ at %@", thisTide.Height, thisTide.Time];
            [lowTideLabel setText:lowTideText];
            
            // Only increment the tide count for a tide event and not a sunrise or sunset
            tideCount++;
        }
    }
    [self.tableView reloadData];
}

@end
