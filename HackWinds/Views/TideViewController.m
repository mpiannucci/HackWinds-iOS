//
//  TideViewController.m
//  HackWinds
//
//  Created by Matthew Iannucci on 7/27/14.
//  Copyright (c) 2014 Matthew Iannucci. All rights reserved.
//
#define TIDE_FETCH_BG_QUEUE dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define TIDE_DATA_FONT_SIZE 25

#import "TideViewController.h"
#import <HackWindsDataKit/HackWindsDataKit.h>
#import "Reachability.h"

@interface TideViewController ()

@property (strong, nonatomic) TideModel *tideModel;
@property (strong, nonatomic) BuoyModel *buoyModel;

@end

@implementation TideViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Get the tide model and buoy model
    self.tideModel = [TideModel sharedModel];
    self.buoyModel = [BuoyModel sharedModel];
    
    // Get the buoy data and reload the views
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    if (networkStatus != NotReachable) {
        dispatch_async(TIDE_FETCH_BG_QUEUE, ^{
            [self.tideModel fetchTideData];
            [self.buoyModel fetchBuoyDataForLocation:BLOCK_ISLAND_LOCATION];
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
    NSArray* tideData = [self.tideModel tides];
    NSArray* buoyData = [self.buoyModel getBuoyDataForLocation:BLOCK_ISLAND_LOCATION];
    
    if ([tideData count] == 0) {
        return;
    }
    
    int tideCount = 0;
    for (int i = 0; i < [tideData count]; i++) {
        // Then check what is is again, and set correct text box
        Tide* thisTide = [tideData objectAtIndex:i];
        if ([thisTide isSunrise]) {
            // Get the first row in the sunrise and sunset section and set the text of the label to the time
            UILabel* sunriseLabel = (UILabel*)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]] viewWithTag:61];
            NSString* sunrisetext = [NSString stringWithFormat:@"Sunrise: %@", thisTide.Time];
            [sunriseLabel setAttributedText:[self makeTideViewDataString:sunrisetext]];
            
        } else if ([thisTide isSunset]) {
            // Get the second row in the sunrise and sunset section and set the text of the label to the time
            UILabel* sunsetLabel = (UILabel*)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]] viewWithTag:61];
            NSString* sunsetText = [NSString stringWithFormat:@"Sunset: %@", thisTide.Time];
            [sunsetLabel setAttributedText:[self makeTideViewDataString:sunsetText]];
            
        } else if ([[thisTide EventType] isEqualToString:HIGH_TIDE_TAG] ||
                   [[thisTide EventType] isEqualToString:LOW_TIDE_TAG] ) {
            // Get the next cell and its label so we can update it
            UILabel* tideLabel = (UILabel*)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:tideCount inSection:1]] viewWithTag:51];
            NSString* tideText = [NSString stringWithFormat:@"%@: %@ at %@", thisTide.EventType, thisTide.Height, thisTide.Time];
            
            [tideLabel setAttributedText:[self makeTideViewDataString:tideText]];
            
            // If its the first object, set it to the current status
            if (tideCount == 0) {
                // Get the current tide label
                UILabel* currentTideLabel = (UILabel*)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] viewWithTag:41];
                
                if ([thisTide isHighTide]) {
                    // Show that the tide is incoming, using green because typically surf increases with incoming tides
                    [currentTideLabel setText:@"Incoming"];
                    [currentTideLabel setTextColor:GREEN_COLOR];
                    
                } else if ([thisTide isLowTide]) {
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
    NSString* waterTemp = [[buoyData objectAtIndex:0] WaterTemperature];
    NSString* waterTempStatus = [NSString stringWithFormat:@"Block Island: %@ %@F", waterTemp, @"\u00B0"];
    [currentWaterTempLabel setAttributedText:[self makeTideViewDataString:waterTempStatus]];
    
    [self.tableView reloadData];
}

- (NSMutableAttributedString*)makeTideViewDataString:(NSString*)rawString {
    NSDictionary *subAttrs = @{
                               NSFontAttributeName:[UIFont boldSystemFontOfSize:TIDE_DATA_FONT_SIZE],
                               };
    NSDictionary *baseAttrs = @{
                                NSFontAttributeName:[UIFont systemFontOfSize:TIDE_DATA_FONT_SIZE]
                                };
    
    const NSRange seperatorRange = [rawString rangeOfString:@":"];
    const NSRange range = NSMakeRange(0, seperatorRange.location);
    
    // Create the attributed string (text + attributes)
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:rawString
                                           attributes:baseAttrs];
    [attributedText setAttributes:subAttrs range:range];
    return attributedText;
}

@end