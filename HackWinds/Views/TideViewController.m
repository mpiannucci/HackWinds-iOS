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
    Buoy* currentBuoy;
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
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.mpiannucci.HackWinds"];
    [defaults synchronize];
    buoyLocation = [defaults objectForKey:@"DefaultBuoyLocation"];
    [self.buoyModel fetchLatestBuoyReadingForLocation:buoyLocation withCompletionHandler:^(Buoy *buoy) {
        currentBuoy = buoy;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Update the tide view in case we missed a notification
    [self.tableView reloadData];
    
    // Register listener for the data model update
    [[NSNotificationCenter defaultCenter] addObserver:self.tableView
                                             selector:@selector(reloadData)
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

#pragma mark - TableView

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
        case 1:
            return 6;
        case 2:
            return 1;
        default:
            return 0;
    }
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Right Now";
        case 1:
            return @"Upcoming";
        case 2:
            return @"Water Temperature";
        default:
            return nil;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell;
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"currentStatusItem"];
        cell.textLabel.text = self.tideModel.currentTideStatus;
        if ([self.tideModel.currentTideStatus isEqualToString:@"Incoming"]) {
            cell.textLabel.textColor = GREEN_COLOR;
        } else if ([self.tideModel.currentTideStatus isEqualToString:@"Outgoing"]) {
            cell.textLabel.textColor = RED_COLOR;
        }
    } else if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"tideDataItem"];
        
        Tide* thisTide = [self.tideModel.tides objectAtIndex:indexPath.row];
        if (thisTide != nil) {
            cell.textLabel.text = thisTide.eventType;
            cell.detailTextLabel.text = thisTide.timestamp;
            
            if ([thisTide isHighTide]) {
                cell.imageView.image = [[UIImage imageNamed:@"ic_trending_up_white"]
                                        imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.imageView.tintColor = HACKWINDS_BLUE_COLOR;
            } else if ([thisTide isLowTide]) {
                cell.imageView.image = [[UIImage imageNamed:@"ic_trending_down_white"]
                                        imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.imageView.tintColor = HACKWINDS_BLUE_COLOR;
            } else if ([thisTide isSunrise]) {
                cell.imageView.image = [[UIImage imageNamed:@"ic_brightness_high_white"]
                                        imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.imageView.tintColor = [UIColor orangeColor];
            } else if ([thisTide isSunset]) {
                cell.imageView.image = [[UIImage imageNamed:@"ic_brightness_low_white"]
                                        imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.imageView.tintColor = [UIColor orangeColor];
            }
        }
    } else if (indexPath.section == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"waterTempItem"];
        cell.textLabel.text = buoyLocation;
        
        if (currentBuoy != nil) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@F", currentBuoy.waterTemperature, @"\u00B0"];
        }
    }
    
    cell.clipsToBounds = YES;
    return cell;
}

@end