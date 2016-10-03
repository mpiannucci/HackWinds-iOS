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

static NSString * const WAVE_HEIGHT_ESTIMATE_IMAGE_URL = @"https://dl.dropboxusercontent.com/s/uplzpw44vva91a1/test.png";

@interface BuoyViewController ()

- (void) changeBuoyLocation:(NSString*)newLocation;

@property (strong, nonatomic) NavigationBarTitleWithSubtitleView *navigationBarTitle;
@property (strong, nonatomic) Buoy *latestBuoy;
@property (strong, nonatomic) NSURL *waveSpectraURL;

@end

@implementation BuoyViewController {
    NSString *buoyLocation;
    BOOL lastFetchFailure;
    double screenWidth;
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
    
    // Save the screen width for later
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    
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
    
    [self.tableView reloadData];
}

- (void)buoyUpdateFailed {
    lastFetchFailure = YES;
    
    [self.tableView reloadData];
}

- (void)loadBuoySettings {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.mpiannucci.HackWinds"];
    [defaults synchronize];

    // Grab the last set or default location
    buoyLocation = [defaults objectForKey:@"BuoyLocation"];
    [self.navigationBarTitle setDetailText:[NSString stringWithFormat:@"Location: %@", buoyLocation]];
}

- (void)locationButtonClicked:(id)sender{
    UIAlertController *locationSheetController = [UIAlertController alertControllerWithTitle:@"Choose Buoy Location"
                                                                                    message:@""
                                                                             preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *biAction = [UIAlertAction actionWithTitle:@"Block Island"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         [self changeBuoyLocation:action.title];
                                                     }];
    UIAlertAction *mtkAction = [UIAlertAction actionWithTitle:@"Montauk"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          [self changeBuoyLocation:action.title];
                                                      }];
    UIAlertAction *nantucketAction = [UIAlertAction actionWithTitle:@"Nantucket"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * _Nonnull action) {
                                                                [self changeBuoyLocation:action.title];
                                                            }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    // Show the actions
    [locationSheetController addAction:biAction];
    [locationSheetController addAction:mtkAction];
    [locationSheetController addAction:nantucketAction];
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
    switch (indexPath.section) {
        case 1:
            return screenWidth;
            break;
        case 2:
            return screenWidth * 2 / 3;
            break;
        case 3:
            return screenWidth * 2 / 5;
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
        
        lastUpdatedLabel.text = [NSString stringWithFormat:@"Buoy reported at %@ %@", [self.latestBuoy timeString], [self.latestBuoy dateString]];
        
    } else if ([cell.reuseIdentifier isEqualToString:@"directionalSpectraCell"]) {
        UIImageView *directionalSpectraPlotImageView = (UIImageView*)[cell viewWithTag:51];
        if (self.latestBuoy.directionalWaveSpectraBase64 != nil) {
            UIImage* plotImage = [UIImage imageWithData:self.latestBuoy.directionalWaveSpectraBase64];
            [directionalSpectraPlotImageView setImage:plotImage];
            
        }
    } else if ([cell.reuseIdentifier isEqualToString:@"energyDistributionCell"]) {
        UIImageView *energySpectraPlotImageView = (UIImageView*)[cell viewWithTag:51];
        if (self.latestBuoy.waveEnergySpectraBase64 != nil) {
            UIImage* plotImage = [UIImage imageWithData:self.latestBuoy.waveEnergySpectraBase64];
            [energySpectraPlotImageView setImage:plotImage];
        }
    } else if ([cell.reuseIdentifier isEqualToString:@"waveHeightEstimationCell"]) {
        AsyncImageView *waveHeightEstimateView = (AsyncImageView*)[cell viewWithTag:51];
        [waveHeightEstimateView setImageURL:[NSURL URLWithString:WAVE_HEIGHT_ESTIMATE_IMAGE_URL]];
    }
    
    return cell;
}

@end
