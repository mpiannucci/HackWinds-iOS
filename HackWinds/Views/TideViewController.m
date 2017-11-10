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

@interface TideViewController ()

@property (strong, nonatomic) LineChartView *tideChartView;
@property (strong, nonatomic) NavigationBarTitleWithSubtitleView *navigationBarTitle;

@property (strong, nonatomic) TideModel *tideModel;
@property (strong, nonatomic) BuoyModel *buoyModel;

@end

@implementation TideViewController {
    NSString *buoyLocation;
    GTLRStation_ApiApiMessagesDataMessage* currentBuoy;
    int failedOnce;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set up the custom nav bar with the forecast location
    [self.navigationItem setTitle:@"Point Judith"];
    
    // Setup the chart view
    [self setupTideChart];
    
    // Grab the models
    self.tideModel = [TideModel sharedModel];
    self.buoyModel = [BuoyModel sharedModel];
    
    // Initialize the failure counter
    failedOnce = NO;
    
    [self loadBuoyData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self reloadData];
    
    // Register listener for the tide data model update
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadData)
                                                 name:TIDE_DATA_UPDATED_TAG
                                               object:nil];
    
    // Register listener for the buoy data model failure
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadDefaultLocationBuoyData)
                                                 name:BUOY_UPDATE_FAILED_TAG
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    // Remove the notifcation listeners when the view is not in focus
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:TIDE_DATA_UPDATED_TAG
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadData)
                                                 name:BUOY_UPDATE_FAILED_TAG
                                               object:nil];
    
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadBuoyData {
    // Load the buoy data for the defualt location so we can get the water temp
    buoyLocation = NEWPORT_LOCATION;
    [self.buoyModel fetchLatestBuoyDataForLocation:buoyLocation withCompletionHandler:^(GTLRStation_ApiApiMessagesDataMessage *buoy) {
        currentBuoy = buoy;
        if (currentBuoy == nil) {
            [self loadDefaultLocationBuoyData];
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

- (void) loadDefaultLocationBuoyData {
    if (failedOnce) {
        return;
    }
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.mpiannucci.HackWinds"];
    [defaults synchronize];
    
    buoyLocation = [defaults objectForKey:@"DefaultBuoyLocation"];
    [self.buoyModel fetchLatestBuoyDataForLocation:buoyLocation withCompletionHandler:^(GTLRStation_ApiApiMessagesDataMessage *buoy) {
        currentBuoy = buoy;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
    
    failedOnce = YES;
}

- (void) reloadData {
    [self.tableView reloadData];
}

#pragma mark - Chart View

- (void) setupTideChart {
    // All the setup work for the chart
    self.tideChartView.delegate = self;
    [self.tideChartView setDrawBordersEnabled:NO];
    [self.tideChartView setDescriptionText:@""];
    [self.tideChartView setPinchZoomEnabled:NO];
    [self.tideChartView setDoubleTapToZoomEnabled:NO];
    [self.tideChartView setDrawMarkers:NO];
    [self.tideChartView setMultipleTouchEnabled:NO];
    [self.tideChartView setUserInteractionEnabled:NO];
    
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
    
    if (self.tideChartView != nil) {
        [self.tideChartView clear];
        [self.tideChartView.xAxis removeAllLimitLines];
    }
    
    double min = 0;
    double max = 0;
    int firstIndex = 0;
    BOOL highFirst = NO;
    int prevIndex = 0;
    int tideCount = 0;
    int index = 0;
    
    // Set the second to 0
    NSTimeInterval time = floor([[NSDate date] timeIntervalSinceReferenceDate] / 3600.0) * 3600.0;
    NSDate *now = [NSDate dateWithTimeIntervalSinceReferenceDate:time];
    
    NSMutableArray *dataEntries = [[NSMutableArray alloc] initWithCapacity:10];
    
    ChartDataEntry *firstEntry = [[ChartDataEntry alloc] initWithX:0.0 y:-1];
    [dataEntries addObject:firstEntry];
    
    while (tideCount < 5) {
        Tide *thisTide = [self.tideModel.tides objectAtIndex:index];
        index++;
        
        if (thisTide == nil) {
            continue;
        }
        
        if (![thisTide isTidalEvent]) {
            continue;
        }
        
        int xIndex = 0;
        if (tideCount == 0) {
            NSTimeInterval interval = [thisTide.timestamp timeIntervalSinceDate:now];
            firstIndex = (int)fabs(interval / (60 * 60));
            xIndex = firstIndex;
            
            if ([thisTide isHighTide]) {
                highFirst = YES;
            } else {
                highFirst = NO;
            }
        } else {
            xIndex = prevIndex + 6;
        }
        
        double value = [thisTide heightValue];
        if (value < 0) {
            value = 0.01;
        }
        
        if (tideCount < 2) {
            if ([thisTide isHighTide]) {
                max = value;
            } else {
                min = value;
            }
        }
        
        if (xIndex != 0) {
            ChartDataEntry *thisEntry = [[ChartDataEntry alloc] initWithX:xIndex y:value];
            [dataEntries addObject:thisEntry];
        } else {
            firstEntry.y = value;
        }
        
        if (xIndex < 24 || tideCount < 4) {
            ChartLimitLine *tideLimit = [[ChartLimitLine alloc] initWithLimit:xIndex];
            tideLimit.label = [thisTide timeString];
            if (xIndex > 16) {
                tideLimit.lineColor = HACKWINDS_BLUE_COLOR;
                tideLimit.labelPosition = ChartLimitLabelPositionLeftTop;
            } else {
                tideLimit.lineColor = [UIColor whiteColor];
                tideLimit.valueTextColor = [UIColor whiteColor];
                tideLimit.labelPosition = ChartLimitLabelPositionRightBottom;
            }
            [self.tideChartView.xAxis addLimitLine:tideLimit];
        }
        
        prevIndex = xIndex;
        tideCount++;
    }
    
    double amplitude = max - min;
    
    if (firstIndex != 0) {
        if (firstIndex == 6) {
            ChartLimitLine *tideLimit = [[ChartLimitLine alloc] initWithLimit:0];
            tideLimit.lineColor = [UIColor whiteColor];
            tideLimit.valueTextColor = [UIColor whiteColor];
            tideLimit.labelPosition = ChartLimitLabelPositionRightBottom;
            if (highFirst) {
                firstEntry.x = 0;
                firstEntry.y = min;
                tideLimit.label = @"Low Tide";
            } else {
                firstEntry.x = 0;
                firstEntry.y = max;
                tideLimit.label = @"High Tide";
            }
            [self.tideChartView.xAxis addLimitLine:tideLimit];
        } else {
            if (highFirst) {
                double approxMax = max - (amplitude * ((double)(firstIndex + 1) / 6.0));
                if (approxMax < 0) {
                    approxMax = 0.01;
                }
                firstEntry.y = approxMax;
            } else {
                double approxMin = (amplitude * (((double)firstIndex + 1) / 6.0)) + min;
                if (approxMin < 0) {
                    approxMin = 0.01;
                }
                firstEntry.y = approxMin;
            }
        }
    } else {
        firstEntry.x = 0;
    }
    
    NSMutableArray *xVals = [[NSMutableArray alloc] initWithCapacity:prevIndex];
    for (int i = 0; i < prevIndex; i++) {
        [xVals addObject:[NSNumber numberWithInt:i]];
    }
    
    LineChartDataSet *dataSet = [[LineChartDataSet alloc] initWithValues:dataEntries label:@"Tide Heights"];
    [dataSet setDrawCirclesEnabled:NO];
    [dataSet setCircleColor:[UIColor orangeColor]];
    [dataSet setColor:HACKWINDS_BLUE_COLOR];
    [dataSet setFillColor:HACKWINDS_BLUE_COLOR];
    [dataSet setFillAlpha:255];
    [dataSet setDrawFilledEnabled:YES];
    [dataSet setLineWidth:2.0];
    [dataSet setDrawCubicEnabled:YES];
    
    LineChartData *chartData = [[LineChartData alloc] initWithDataSet:dataSet];
    [chartData setDrawValues:NO];
    
    // Draw a limit line at now
    ChartLimitLine *nowLine = [[ChartLimitLine alloc] initWithLimit:0];
    nowLine.label = @"Now";
    nowLine.lineColor = [UIColor blueColor];
    [nowLine setLineWidth:4.0];
    [self.tideChartView.xAxis addLimitLine:nowLine];
    [self.tideChartView.leftAxis setAxisMaxValue:max + 1.0];
    [self.tideChartView.rightAxis setAxisMaxValue:max + 1.0];
    [self.tideChartView.leftAxis setAxisMinValue:min - 1.0];
    [self.tideChartView.rightAxis setAxisMinValue:min - 1.0];
    
    self.tideChartView.data = chartData;
}

- (void) chartValueSelected:(ChartViewBase *)chartView entry:(ChartDataEntry *)entry dataSetIndex:(NSInteger)dataSetIndex highlight:(ChartHighlight *)highlight {
    
}

- (void) chartValueNothingSelected:(ChartViewBase *)chartView {
    
}

#pragma mark - Table View

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
        case 1:
            return [self.tideModel dataCountForIndex:0];
        case 2:
            return 1;
        default:
            return 0;
    }
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Upcoming Tides";
        case 1:
            return @"Upcoming Events";
        case 2:
            return @"Water Temperature";
        default:
            return nil;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 188.0;
    } else {
        return 90.0;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell;
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"tidePlotItem"];

        self.tideChartView = (LineChartView*)[cell viewWithTag:78];
        [self setupTideChart];
        [self loadTideChartData];
        
    } else if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"tideDataItem"];
        
        Tide* thisEvent = [self.tideModel.tides objectAtIndex:indexPath.row];
        if (thisEvent != nil) {
            cell.textLabel.text = thisEvent.eventType;
            cell.detailTextLabel.text = [thisEvent timeString];
            
            if ([thisEvent isHighTide]) {
                cell.imageView.image = [[UIImage imageNamed:@"ic_trending_up_white"]
                                        imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.imageView.tintColor = HACKWINDS_BLUE_COLOR;
            } else if ([thisEvent isLowTide]) {
                cell.imageView.image = [[UIImage imageNamed:@"ic_trending_down_white"]
                                        imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.imageView.tintColor = HACKWINDS_BLUE_COLOR;
            } else if ([thisEvent isSunrise]) {
                cell.imageView.image = [[UIImage imageNamed:@"ic_brightness_high_white"]
                                        imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.imageView.tintColor = [UIColor orangeColor];
            } else if ([thisEvent isSunset]) {
                cell.imageView.image = [[UIImage imageNamed:@"ic_brightness_low_white"]
                                        imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.imageView.tintColor = [UIColor orangeColor];
            }
        }
    } else if (indexPath.section == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"tideDataItem"];
        cell.textLabel.text = buoyLocation;
        
        if (currentBuoy != nil) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f %@F", currentBuoy.waterTemperature.doubleValue, @"\u00B0"];
            cell.imageView.image = [[UIImage imageNamed:@"ic_whatshot_white"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            int tempRaw = [currentBuoy.waterTemperature intValue];
            if (tempRaw < 43) {
                cell.imageView.tintColor = [UIColor purpleColor];
            } else if (tempRaw < 50) {
                cell.imageView.tintColor = [UIColor blueColor];
            } else if (tempRaw < 60) {
                cell.imageView.tintColor = GREEN_COLOR;
            } else if (tempRaw < 70) {
                cell.imageView.tintColor = [UIColor orangeColor];
            } else {
                cell.imageView.tintColor = RED_COLOR;
            }
        } else {
            cell.detailTextLabel.text = @"";
            cell.imageView.image = [[UIImage imageNamed:@"ic_whatshot_white"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            cell.imageView.tintColor = [UIColor grayColor];
        }
    }
    
    cell.clipsToBounds = YES;
    return cell;
}



@end
