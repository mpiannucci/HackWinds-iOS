//
//  DetailedForecastViewController.m
//  HackWinds
//
//  Created by Matthew Iannucci on 3/30/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//
#import "DetailedForecastViewController.h"
#import <HackWindsDataKit/HackWindsDataKit.h>
#import "AsyncImageView.h"

@interface DetailedForecastViewController ()

// UI Properties
@property (weak, nonatomic) IBOutlet UITableView *forecastTable;

// Model Properties
@property (strong, nonatomic) ForecastModel *forecastModel;

// View specifics
@property (strong, nonatomic) NSMutableArray *animationImages;

@end

@implementation DetailedForecastViewController {
    NSArray *currentConditions;
    BOOL is24HourClock;
    BOOL showDetailedForecastInfo;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up the navigation controller
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"Back";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    
    [self check24HourClock];
    
    // Get the forecast model instance
    self.forecastModel = [ForecastModel sharedModel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Check if detailed information should be shown
    showDetailedForecastInfo = [[[NSUserDefaults alloc] initWithSuiteName:@"group.com.mpiannucci.HackWinds"] boolForKey:@"ShowDetailedForecastInfo"];
    
    // Reload the data for the correct day
    [self getModelData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:self];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getModelData {
    // Load the forecast Data
    currentConditions = [self.forecastModel getForecastsForDay:(int)self.dayIndex];
    [self.forecastTable performSelectorOnMainThread:@selector(reloadData)
                                    withObject:nil waitUntilDone:YES];
}

- (BOOL)check24HourClock {
    NSLocale *locale = [NSLocale currentLocale];
    NSString *dateCheck = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:locale];
    is24HourClock = ([dateCheck rangeOfString:@"a"].location == NSNotFound);
    return is24HourClock;
}

#pragma mark - TableView Handling

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (showDetailedForecastInfo && indexPath.section == 0) {
        return 90;
    } else {
        return 45;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Forecast";
        case 1:
            return @"Tides";
        default:
            return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return so there will always be currentconditions.count rows + the header row
    
    switch (section) {
        case 0:
            if (currentConditions == nil) {
                return 0;
            }
            
            if (showDetailedForecastInfo) {
                return currentConditions.count;
            } else {
                return currentConditions.count + 1;
            }
        case 1:
            return [[TideModel sharedModel] dataCountForIndex:self.dayIndex];
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case 0:
            if (showDetailedForecastInfo) {
                // Get the interface items
                cell = [tableView dequeueReusableCellWithIdentifier:@"detailedForecastItem"];
                UILabel *hourLabel = (UILabel *)[cell viewWithTag:91];
                UILabel *conditionsLabel = (UILabel *)[cell viewWithTag:92];
                UILabel *primarySwellLabel = (UILabel *)[cell viewWithTag:93];
                UILabel *secondarySwellLabel = (UILabel *)[cell viewWithTag:94];
    
                // Get the condition object
                Forecast *thisCondition = [currentConditions objectAtIndex:indexPath.row];
        
                // Set the data to show in the labels
                if (is24HourClock) {
                    hourLabel.text = [thisCondition timeToTwentyFourHourClock];
                } else {
                    hourLabel.text = [thisCondition timeStringNoZero];
                }
                conditionsLabel.text = [NSString stringWithFormat:@"%d - %d ft, Wind %@ %d mph", thisCondition.minimumBreakingHeight.intValue, thisCondition.maximumBreakingHeight.intValue, thisCondition.windCompassDirection, thisCondition.windSpeed.intValue];
                primarySwellLabel.text = [thisCondition.primarySwellComponent getDetailedSwellSummmary];
                if ([thisCondition.secondarySwellComponent.compassDirection isEqualToString:@"NULL"]) {
                    secondarySwellLabel.text = @"No Secondary Swell Component";
                } else {
                    secondarySwellLabel.text = [thisCondition.secondarySwellComponent getDetailedSwellSummmary];
                }
            } else {
                // Get the interface items
                cell = [tableView dequeueReusableCellWithIdentifier:@"simpleForecastItem"];
                UILabel *hourLabel = (UILabel *)[cell viewWithTag:11];
                UILabel *waveLabel = (UILabel *)[cell viewWithTag:12];
                UILabel *windLabel = (UILabel *)[cell viewWithTag:13];
                UILabel *swellLabel = (UILabel *)[cell viewWithTag:14];
        
                if ([indexPath row] < 1) {
                    // Set the heder text cuz its the first row
                    hourLabel.text = @"Time";
                    waveLabel.text = @"Surf";
                    windLabel.text = @"Wind";
                    swellLabel.text = @"Swell";
            
                    // Set the header label to be hackwinds color blue
                    hourLabel.textColor = HACKWINDS_BLUE_COLOR;
                    waveLabel.textColor = HACKWINDS_BLUE_COLOR;
                    windLabel.textColor = HACKWINDS_BLUE_COLOR;
                    swellLabel.textColor = HACKWINDS_BLUE_COLOR;
            
                    // Set the text to be bold
                    hourLabel.font = [UIFont boldSystemFontOfSize:17.0];
                    waveLabel.font = [UIFont boldSystemFontOfSize:17.0];
                    windLabel.font = [UIFont boldSystemFontOfSize:17.0];
                    swellLabel.font = [UIFont boldSystemFontOfSize:17.0];
            
                } else {
                    if (currentConditions.count == 0) {
                        return cell;
                    }
            
                    Forecast *thisCondition = [currentConditions objectAtIndex:indexPath.row-1];
            
                    // Set the data to show in the labels
                    if (is24HourClock) {
                        hourLabel.text = [thisCondition timeToTwentyFourHourClock];
                    } else {
                        hourLabel.text = [thisCondition timeStringNoZero];
                    }
                    waveLabel.text = [NSString stringWithFormat:@"%d - %d", thisCondition.minimumBreakingHeight.intValue, thisCondition.maximumBreakingHeight.intValue];
                    windLabel.text = [NSString stringWithFormat:@"%@ %d", thisCondition.windCompassDirection, thisCondition.windSpeed.intValue];
                    swellLabel.text = [thisCondition.primarySwellComponent getSwellSummmary];
            
                    // Make sure that the text is black
                    hourLabel.textColor = [UIColor blackColor];
                    waveLabel.textColor = [UIColor blackColor];
                    windLabel.textColor = [UIColor blackColor];
                    swellLabel.textColor = [UIColor blackColor];
            
                    // Set the text to be bold
                    hourLabel.font = [UIFont systemFontOfSize:17.0];
                    waveLabel.font = [UIFont systemFontOfSize:17.0];
                    windLabel.font = [UIFont systemFontOfSize:17.0];
                    swellLabel.font = [UIFont systemFontOfSize:17.0];
                }
            }
            break;
        case 1:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"tideItem"];
                Tide *thisTide = [[TideModel sharedModel] tideDataAtIndex:indexPath.row forDay:self.dayIndex];
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
            break;
        default:
            break;
    }
    
    return cell;
}

 #pragma mark - Navigation
 
// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
// Get the new view controller using [segue destinationViewController].
// Pass the selected object to the new view controller.
//}

@end
