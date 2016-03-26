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
    [self reloadData];
    
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
    // All the setup work for the chart
    [self.tideChartView setDrawBordersEnabled:NO];
    [self.tideChartView setDescriptionText:@""];
    
    // xAxis
    [self.tideChartView.xAxis setDrawGridLinesEnabled:NO];
    [self.tideChartView.xAxis setDrawAxisLineEnabled:NO];
    [self.tideChartView.xAxis setDrawLabelsEnabled:NO];
    
    // yAxis
    [self.tideChartView.leftAxis setDrawAxisLineEnabled:NO];
    [self.tideChartView.leftAxis setDrawGridLinesEnabled:NO];
    [self.tideChartView.leftAxis setDrawLabelsEnabled:NO];
    [self.tideChartView.leftAxis setDrawZeroLineEnabled:NO];
    [self.tideChartView.rightAxis setDrawAxisLineEnabled:NO];
    [self.tideChartView.rightAxis setDrawGridLinesEnabled:NO];
    [self.tideChartView.rightAxis setDrawLabelsEnabled:NO];
    [self.tideChartView.rightAxis setDrawZeroLineEnabled:NO];
    
    // Legend
    [self.tideChartView.legend setEnabled:NO];
}

- (void) loadTideChartData {
    if (self.tideModel.tides.count < 5) {
        return;
    }
    
    double min = 0;
    double max = 0;
    double firstMaxTimeStep = 0.0;
    int maxCount = 0;
    int minCount = 0;
    int tideCount = 0;
    int index = 0;
    while (tideCount < 4) {
        Tide *thisTide = [self.tideModel.tides objectAtIndex:index];
        index++;
        
        if (thisTide == nil) {
            continue;
        }
        
        if (![thisTide isTidalEvent]) {
            continue;
        }
        
        if ([thisTide isHighTide]) {
            max += [thisTide heightValue];
            
            if (maxCount == 0) {
                NSDate *now = [NSDate date];
                NSTimeInterval interval = [thisTide.timestamp timeIntervalSinceDate:now];
                firstMaxTimeStep = (int)fabs(interval / (60 * 60));
            }
            
            maxCount++;
        } else {
            min += [thisTide heightValue];
            minCount++;
        }
        
        tideCount++;
    }
    
    // Take the average
    min = min / minCount;
    max = max / maxCount;
    double amplitude = (max - min) / 2;
    
    NSMutableArray *dataEntries = [[NSMutableArray alloc] initWithCapacity:24];
    NSMutableArray *xVals = [[NSMutableArray alloc] initWithCapacity:24];
    
    for (int i = 0; i < 24; i++) {
        double yVal = amplitude * cos(((double)i/3) + (double)firstMaxTimeStep) + (amplitude + min);
        ChartDataEntry *chartEntry = [[ChartDataEntry alloc] initWithValue:yVal xIndex:i];
        [dataEntries addObject:chartEntry];
        [xVals addObject:[NSString stringWithFormat:@"%d", i]];
    }
    
    LineChartDataSet *dataSet = [[LineChartDataSet alloc] initWithYVals:dataEntries label:@"Tide Heights"];
    [dataSet setDrawCirclesEnabled:NO];
    [dataSet setColor:HACKWINDS_BLUE_COLOR];
    [dataSet setFillColor:HACKWINDS_BLUE_COLOR];
    [dataSet setFillAlpha:255];
    [dataSet setDrawFilledEnabled:YES];
    LineChartData *chartData = [[LineChartData alloc] initWithXVals:xVals dataSet:dataSet];
    [chartData setDrawValues:NO];
    self.tideChartView.data = chartData;
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
            cell.detailTextLabel.text = [thisTide timeString];
            
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