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
#import <Charts/Charts.h>

@interface TideViewController ()


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet LineChartView *tideChartView;
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
    
    // Setup the chart view
    [self setupTideChart];
    
    // Grab the models
    self.tideModel = [TideModel sharedModel];
    self.buoyModel = [BuoyModel sharedModel];
    
    // Load the buoy data for the defualt location so we can get the water temp
    buoyLocation = NEWPORT_LOCATION;
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
    [[NSNotificationCenter defaultCenter] addObserver:self
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

- (void) reloadData {
    [self.tableView reloadData];
    [self loadTideChartData];
}

#pragma mark - Chart View

- (void) setupTideChart {
    // TODO: All the setup work for the chart
}

- (void) loadTideChartData {
    // TODO: Get the sine fit for the points and shwo the data
}

#pragma mark - Table View

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 6;
        case 1:
            return 1;
        default:
            return 0;
    }
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Upcoming";
        case 1:
            return @"Water Temperature";
        default:
            return nil;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell;
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"tideDataItem"];
        
        Tide* thisTide = [self.tideModel.tides objectAtIndex:indexPath.row];
        if (thisTide != nil) {
            if ([thisTide isTidalEvent]) {
                cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", thisTide.eventType, thisTide.height];
            } else {
                cell.textLabel.text = thisTide.eventType;
            }
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
    } else if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"waterTempItem"];
        cell.textLabel.text = buoyLocation;
        
        if (currentBuoy != nil) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@F", currentBuoy.waterTemperature, @"\u00B0"];
            cell.imageView.image = [[UIImage imageNamed:@"ic_whatshot_white"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            int tempRaw = [currentBuoy.waterTemperature intValue];
            if (tempRaw < 43) {
                cell.imageView.tintColor = [UIColor purpleColor];
            } else if (tempRaw < 50) {
                cell.imageView.tintColor = [UIColor blueColor];
            } else if (tempRaw < 60) {
                cell.imageView.tintColor = YELLOW_COLOR;
            } else if (tempRaw < 70) {
                cell.tintColor = [UIColor orangeColor];
            } else {
                cell.tintColor = RED_COLOR;
            }
        }
    }
    
    cell.clipsToBounds = YES;
    return cell;
}

@end