//
//  TideViewController.m
//  HackWinds
//
//  Created by Matthew Iannucci on 7/27/14.
//  Copyright (c) 2014 Matthew Iannucci. All rights reserved.
//

#import "TideViewController.h"
#import <HackWindsDataKit/HackWindsDataKit.h>
#import "Reachability.h"
#import "NavigationBarTitleWithSubtitleView.h"

static const int TIDE_DATA_FONT_SIZE = 25;

@interface TideViewController ()

@property (strong, nonatomic) NavigationBarTitleWithSubtitleView *navigationBarTitle;

@property (strong, nonatomic) TideModel *tideModel;
@property (strong, nonatomic) BuoyModel *buoyModel;

@end

@implementation TideViewController {
    NSString *buoyLocation;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set up the custom nav bar with the forecast location
    self.navigationBarTitle = [[NavigationBarTitleWithSubtitleView alloc] init];
    [self.navigationItem setTitleView: self.navigationBarTitle];
    [self.navigationBarTitle setTitleText:@"HackWinds"];
    [self.navigationBarTitle setDetailText:@"Location: Point Judith Harbor"];
    
    self.tideModel = [TideModel sharedModel];
    self.buoyModel = [BuoyModel sharedModel];
    
    // Load the buoy data for the defualt location so we can get the water temp
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.nucc.HackWinds"];
    [defaults synchronize];
    buoyLocation = [defaults objectForKey:@"DefaultBuoyLocation"];
    [self.buoyModel fetchLatestBuoyReadingForLocation:buoyLocation withCompletionHandler:^(Buoy *buoy) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateBuoyView:buoy];
        });
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Update the tide view in case we missed a notification
    [self updateTideView];
    
    // Register listener for the data model update
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTideView)
                                                 name:TIDE_DATA_UPDATED_TAG
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    // Remove the notifcation lsitener when the view is not in focus
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:TIDE_DATA_UPDATED_TAG
                                                  object:nil];
    
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateTideView {
    // If there are no tide items return early
    NSArray* tideData = self.tideModel.tides;
    
    if (tideData.count == 0) {
        return;
    }
    
    int tideCount = 0;
    for (int i = 0; i < tideData.count; i++) {
        // Then check what is is again, and set correct text box
        Tide* thisTide = [tideData objectAtIndex:i];
        if ([thisTide isSunrise]) {
            // Get the first row in the sunrise and sunset section and set the text of the label to the time
            UILabel* sunriseLabel = (UILabel*)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]] viewWithTag:61];
            NSString* sunrisetext = [NSString stringWithFormat:@"Sunrise: %@", thisTide.timestamp];
            [sunriseLabel setAttributedText:[self makeTideViewDataString:sunrisetext]];
            
        } else if ([thisTide isSunset]) {
            // Get the second row in the sunrise and sunset section and set the text of the label to the time
            UILabel* sunsetLabel = (UILabel*)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]] viewWithTag:61];
            NSString* sunsetText = [NSString stringWithFormat:@"Sunset: %@", thisTide.timestamp];
            [sunsetLabel setAttributedText:[self makeTideViewDataString:sunsetText]];
            
        } else if ([[thisTide eventType] isEqualToString:HIGH_TIDE_TAG] ||
                   [[thisTide eventType] isEqualToString:LOW_TIDE_TAG] ) {
            // Get the next cell and its label so we can update it
            UILabel* tideLabel = (UILabel*)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:tideCount inSection:1]] viewWithTag:51];
            NSString* tideText = [NSString stringWithFormat:@"%@: %@ at %@", thisTide.eventType, thisTide.height, thisTide.timestamp];
            
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
    
    [self.tableView reloadData];
}

- (void)updateBuoyView:(Buoy*)buoy {
    UILabel* currentWaterTempLabel = (UILabel*)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]] viewWithTag:71];
    NSString* waterTempStatus = [NSString stringWithFormat:@"%@: %@ %@F", buoyLocation, buoy.waterTemperature, @"\u00B0"];
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