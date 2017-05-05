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

- (void) changeBuoyLocation:(NSString*)newLocation;

@property (strong, nonatomic) UIButton *navigationBarTitle;
@property (strong, nonatomic) Buoy *latestBuoy;
@property (strong, nonatomic) NSURL *waveSpectraURL;

@end

@implementation BuoyViewController {
    NSString *buoyLocation;
    BOOL lastFetchFailure;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Set the navbar
    self.navigationBarTitle = [[UIButton alloc] initWithFrame:self.navigationItem.titleView.frame];
    [self.navigationBarTitle.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [self.navigationBarTitle addTarget:self action:@selector(locationButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarTitle setAutoresizesSubviews:YES];
    [self.navigationBarTitle.titleLabel setAdjustsFontSizeToFitWidth:YES];
    self.navigationItem.titleView = self.navigationBarTitle;
    
    // Load the buoy settings
    [self loadBuoySettings];
    
    // Set up the pull to refresh controller
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor whiteColor];
    self.refreshControl.tintColor = HACKWINDS_BLUE_COLOR;
    [self.refreshControl addTarget:self
                            action:@selector(fetchNewBuoyData)
                  forControlEvents:UIControlEventValueChanged];
    
    // Initialize the failure flag to NO
    lastFetchFailure = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self updateUI];
    
    if ([[BuoyModel sharedModel] isFetching]) {
        [self.refreshControl beginRefreshing];
        [self.tableView setContentOffset:CGPointMake(0, -128.0) animated:YES];
    }
    
    // Register the notification center listener for when the buoy data is updated
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUI)
                                                 name:BUOY_DATA_UPDATED_TAG
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(buoyUpdateFailed)
                                                 name:BUOY_UPDATE_FAILED_TAG
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    // Remove the listeners when the view goes out of focus
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BUOY_DATA_UPDATED_TAG
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BUOY_UPDATE_FAILED_TAG
                                                  object:nil];
    
    [super viewDidDisappear:animated];
}
     
- (void)fetchNewBuoyData {
    [[BuoyModel sharedModel] refreshBuoyData];
}

- (void)updateUI {
    Buoy *buoyData = [[BuoyModel sharedModel] getBuoyData];
    
    if (buoyData.swellComponents.count < 1) {
        lastFetchFailure = YES;
        return;
    }
    
    // Save the latest buoy reading and the spectra plot url
    self.latestBuoy = buoyData;
    
    // The fetch succeeded!
    lastFetchFailure = NO;
    
    if ([self.refreshControl isRefreshing]) {
        [self.refreshControl endRefreshing];
    }
    
    [self.tableView reloadData];
}

- (void)buoyUpdateFailed {
    lastFetchFailure = YES;
    
    if (self.refreshControl.isRefreshing) {
        [self.refreshControl endRefreshing];
    }
    
    [self.tableView reloadData];
}

- (void)loadBuoySettings {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.mpiannucci.HackWinds"];
    [defaults synchronize];

    // Grab the last set or default location
    buoyLocation = [defaults objectForKey:@"BuoyLocation"];
    [self.navigationBarTitle setTitle:buoyLocation forState:UIControlStateNormal];
}

- (void)locationButtonClicked:(id)sender{
    UIAlertController *locationSheetController = [UIAlertController alertControllerWithTitle:@"Choose Buoy Location"
                                                                                    message:@""
                                                                             preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSString* location in [[BuoyModel sharedModel] getBuoyLocations]) {
        if ([location isEqualToString:@"Newport"]) {
            continue;
        }
        
        UIAlertAction *locAction = [UIAlertAction actionWithTitle:location
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         [self changeBuoyLocation:action.title];
                                                     }];
        [locationSheetController addAction:locAction];
    }
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [locationSheetController addAction:cancelAction];
    
    // Show the action sheet
    [self presentViewController:locationSheetController animated:YES completion:nil];
}

- (void) changeBuoyLocation:(NSString*)newLocation {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.mpiannucci.HackWinds"];
    
    // If the user selects a location, set the settings key to the new location
    [defaults setObject:newLocation forKey:@"BuoyLocation"];
    [defaults synchronize];
    [self loadBuoySettings];
    
    // Show the refresh!
    [self.refreshControl beginRefreshing];
    [self.tableView setContentOffset:CGPointMake(0, -128.0) animated:YES];
    
    // Tell everyone the data has updated
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]
         postNotificationName:BUOY_LOCATION_CHANGED_TAG
         object:self];
    });
}

#pragma mark - TableView

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    switch (indexPath.section) {
        case 1:
        case 2:
            return screenWidth * (3.0/4.0);
            break;
        default:
            return 176.0;
            break;
    }
}

- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (lastFetchFailure) {
        if ([cell.reuseIdentifier isEqualToString:@"buoyStatusCell"]) {
            UILabel *currentBuoyStatusLabel = (UILabel*)[cell viewWithTag:41];
            UILabel *currentDominantSpectraLabel = (UILabel*)[cell viewWithTag:42];
            UILabel *currentSecondarySpectraLabel = (UILabel*)[cell viewWithTag:43];
            UILabel *lastUpdatedLabel = (UILabel*)[cell viewWithTag:44];
            
            currentBuoyStatusLabel.text = @"No Data received for this Buoy";
            currentDominantSpectraLabel.text = @"";
            currentSecondarySpectraLabel.text = @"";
            lastUpdatedLabel.text = @"";
        }
        
        return cell;
    }
        
    if ([cell.reuseIdentifier isEqualToString:@"buoyStatusCell"]) {
        UILabel *currentBuoyStatusLabel = (UILabel*)[cell viewWithTag:41];
        UILabel *currentDominantSpectraLabel = (UILabel*)[cell viewWithTag:42];
        UILabel *currentSecondarySpectraLabel = (UILabel*)[cell viewWithTag:43];
        UILabel *lastUpdatedLabel = (UILabel*)[cell viewWithTag:44];
        
        currentBuoyStatusLabel.text = [self.latestBuoy getWaveSummaryStatusText];
        currentDominantSpectraLabel.text = [[self.latestBuoy.swellComponents objectAtIndex:0] getDetailedSwellSummmary];
        currentSecondarySpectraLabel.text = [[self.latestBuoy.swellComponents objectAtIndex:1] getDetailedSwellSummmary];
        
        if (self.latestBuoy.timestamp != nil) {
            lastUpdatedLabel.text = [NSString stringWithFormat:@"Buoy reported at %@ %@", [self.latestBuoy timeString], [self.latestBuoy dateString]];
        }
        
    } else if ([cell.reuseIdentifier isEqualToString:@"directionalSpectraCell"]) {
        AsyncImageView *directionalSpectraPlotImageView = (AsyncImageView*)[cell viewWithTag:51];
        if (self.latestBuoy.directionalWaveSpectraPlotURL != nil) {
            [directionalSpectraPlotImageView setImageURL:self.latestBuoy.directionalWaveSpectraPlotURL];
        }
    } else if ([cell.reuseIdentifier isEqualToString:@"energyDistributionCell"]) {
        AsyncImageView *energySpectraPlotImageView = (AsyncImageView*)[cell viewWithTag:51];
        if (self.latestBuoy.waveEnergySpectraPlotURL != nil) {
            [energySpectraPlotImageView setImageURL:self.latestBuoy.waveEnergySpectraPlotURL];
        }
    }
    
    return cell;
}

@end
