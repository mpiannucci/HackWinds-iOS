//
//  BuoyViewController.m
//  HackWinds
//
//  Created by Matthew Iannucci on 1/21/16.
//  Copyright © 2016 Rhodysurf Development. All rights reserved.
//

#import "BuoyViewController.h"
#import "NavigationBarTitleWithSubtitleView.h"
#import "AsyncImageView.h"
#import <HackWindsDataKit/HackWindsDataKit.h>

@interface BuoyViewController ()

@property (strong, nonatomic) NavigationBarTitleWithSubtitleView *navigationBarTitle;
@property (strong, nonatomic) Buoy *latestBuoy;
@property (strong, nonatomic) NSURL *waveSpectraURL;

@end

@implementation BuoyViewController {
    NSString *buoyLocation;
    BOOL lastFetchFailed;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Set up the custom nav bar with the buoy location
    self.navigationBarTitle = [[NavigationBarTitleWithSubtitleView alloc] init];
    [self.navigationItem setTitleView: self.navigationBarTitle];
    [self.navigationBarTitle setTitleText:@"HackWinds"];
    [self.navigationBarTitle.detailButton addTarget:self action:@selector(locationButtonClicked:)  forControlEvents:UIControlEventTouchDown];
    
    // Load the buoy settings
    [self loadBuoySettings];
    
    // Initialize the failure flag to NO
    lastFetchFailed = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Reload the UI in case we missed a notification
    [self updateUI];
    
    // Register the notification center listener when the view appears
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUI)
                                                 name:BUOY_DATA_UPDATED_TAG
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showFailureUI)
                                                 name:BUOY_UPDATE_FAILED_TAG
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    // Remove the listener when the view goes out of focus
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BUOY_DATA_UPDATED_TAG
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BUOY_UPDATE_FAILED_TAG
                                                  object:nil];
    
    [super viewDidDisappear:animated];
}

- (void)updateUI {
    NSMutableArray *buoys = [[BuoyModel sharedModel] getBuoyData];
    
    if (buoys.count < 1) {
        lastFetchFailed = YES;
        return;
    }
    
    // Save the latest buoy reading and the spectra plot url
    self.latestBuoy = [buoys objectAtIndex:0];
    self.waveSpectraURL = [[BuoyModel sharedModel] getSpectraPlotURL];
    
    // The fetch succeeded!
    lastFetchFailed = NO;
    
    [self.tableView reloadData];
}

- (void)showFailureUI {
    lastFetchFailed = YES;
    
    [self.tableView reloadData];
}

- (void)loadBuoySettings {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.nucc.HackWinds"];
    [defaults synchronize];

    // Grab the last set or default location
    buoyLocation = [defaults objectForKey:@"BuoyLocation"];
    [self.navigationBarTitle setDetailText:[NSString stringWithFormat:@"Location: %@", buoyLocation]];
}

- (void)locationButtonClicked:(id)sender{
    UIActionSheet *locationActionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Buoy Location"
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:BUOY_LOCATIONS];
    // Show the action sheet
    [locationActionSheet setTintColor:HACKWINDS_BLUE_COLOR];
    [locationActionSheet showInView:self.view];
}

#pragma mark - ActionSheet

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.nucc.HackWinds"];

    if (buttonIndex != [actionSheet numberOfButtons] - 1) {
        // If the user selects a location, set the settings key to the new location
        [defaults setObject:[actionSheet buttonTitleAtIndex:buttonIndex] forKey:@"BuoyLocation"];
        [defaults synchronize];
        [self loadBuoySettings];

        // Tell everyone the data has updated
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]
             postNotificationName:BUOY_LOCATION_CHANGED_TAG
             object:self];
        });

    } else {
        NSLog(@"Buoy Location change cancelled, keep location at %@", [defaults objectForKey:@"BuoyLocation"]);
    }
}

#pragma mark - TableView

- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (lastFetchFailed) {
        if ([cell.reuseIdentifier isEqualToString:@"buoyStatusCell"]) {
            UILabel *currentBuoyStatusLabel = (UILabel*)[cell viewWithTag:41];
            UILabel *currentDominantSpectraLabel = (UILabel*)[cell viewWithTag:42];
            UILabel *currentSecondarySpectraLabel = (UILabel*)[cell viewWithTag:43];
            UILabel *lastUpdatedLabel = (UILabel*)[cell viewWithTag:44];
            
            currentBuoyStatusLabel.text = @"No Data received for this Buoy";
            currentDominantSpectraLabel.text = @"";
            currentSecondarySpectraLabel.text = @"";
            lastUpdatedLabel.text = @"";
            
        } else if ([cell.reuseIdentifier isEqualToString:@"waveSpectraCell"]) {
            AsyncImageView *spectraPlotImage = (AsyncImageView*)[cell viewWithTag:51];
            [spectraPlotImage setImageURL:nil];
        }
        
        return cell;
    }
        
    if ([cell.reuseIdentifier isEqualToString:@"buoyStatusCell"]) {
        UILabel *currentBuoyStatusLabel = (UILabel*)[cell viewWithTag:41];
        UILabel *currentDominantSpectraLabel = (UILabel*)[cell viewWithTag:42];
        UILabel *currentSecondarySpectraLabel = (UILabel*)[cell viewWithTag:43];
        UILabel *lastUpdatedLabel = (UILabel*)[cell viewWithTag:44];
        
        currentBuoyStatusLabel.text = [self.latestBuoy getWaveSummaryStatusText];
        currentDominantSpectraLabel.text = [self.latestBuoy getDominantSwellText];
        currentSecondarySpectraLabel.text = [self.latestBuoy getSecondarySwellText];
        
        lastUpdatedLabel.text = [NSString stringWithFormat:@"Buoy reported at %@", self.latestBuoy.timestamp];
        
    } else if ([cell.reuseIdentifier isEqualToString:@"waveSpectraCell"]) {
        AsyncImageView *spectraPlotImage = (AsyncImageView*)[cell viewWithTag:51];
        [spectraPlotImage setImageURL:self.waveSpectraURL];
    }
    
    return cell;
}

@end
