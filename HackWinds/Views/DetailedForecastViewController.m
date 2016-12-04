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
#import "UIImage+Crop.h"

// Constants
static NSString * const BASE_WW_CHART_URL = @"http://polar.ncep.noaa.gov/waves/WEB/multi_1.latest_run/plots/US_eastcoast.%@.%@%03dh.png";
static NSString * const PAST_HOUR_PREFIX = @"h";
static NSString * const FUTURE_HOUR_PREFIX = @"f";
static const int WAVE_HEIGHT_CHART = 0;
static const int SWELL_PERIOD_CHART = 1;
static const int WIND_CHART = 2;
static const int WW_HOUR_STEP = 3;

@interface DetailedForecastViewController ()

// UI Properties
@property (weak, nonatomic) IBOutlet UITableView *forecastTable;
@property (weak, nonatomic) IBOutlet UIImageView *chartImageView;
@property (weak, nonatomic) IBOutlet UIProgressView *chartLoadProgressIndicator;
@property (weak, nonatomic) IBOutlet UISegmentedControl *chartTypeSegmentControl;
@property (weak, nonatomic) IBOutlet UIButton *chartAnimationPlayButton;
@property (weak, nonatomic) IBOutlet UIButton *chartAnimationPauseButton;


// Model Properties
@property (strong, nonatomic) ForecastModel *forecastModel;

// View specifics
@property (strong, nonatomic) NSMutableArray *animationImages;

@end

@implementation DetailedForecastViewController {
    NSArray *currentConditions;
    BOOL needsReload[3];
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
    
    // Initialize the aniimation image array
    self.animationImages = [[NSMutableArray alloc] init];
    
    // Setup the segment titles cuz of the weird storyboard bug
    [self.chartTypeSegmentControl setTitle:@"Waves" forSegmentAtIndex:0];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Check if detailed information should be shown
    showDetailedForecastInfo = [[[NSUserDefaults alloc] initWithSuiteName:@"group.com.mpiannucci.HackWinds"] boolForKey:@"ShowDetailedForecastInfo"];
    
    // Hide the play button
    [self.chartAnimationPlayButton setHidden:YES];
    
    // Reset the reload flag
    for (int i = 0; i < 3; i++) {
        needsReload[i] = YES;
    }
    
    // Reload the data for the correct day
    [self getModelData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:self];
    [self.chartImageView stopAnimating];
    
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
    [self sendChartImageAnimationWithType:WAVE_HEIGHT_CHART forIndex:0];
}

- (BOOL)check24HourClock {
    NSLocale *locale = [NSLocale currentLocale];
    NSString *dateCheck = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:locale];
    is24HourClock = ([dateCheck rangeOfString:@"a"].location == NSNotFound);
    return is24HourClock;
}

- (IBAction)chartTypeChanged:(id)sender {
    // Clear out the old animation images
    // Reset the image buttons and animation
    [self.chartAnimationPlayButton setHidden:YES];
    [self.chartImageView stopAnimating];
    
    // Reset the progress bar
    [self.chartLoadProgressIndicator setHidden:NO];
    [self.chartLoadProgressIndicator setProgress:0.0f animated:YES];
    
    // Reset the animation images and start lolading the new ones
    self.animationImages = [[NSMutableArray alloc] init];
    [self sendChartImageAnimationWithType:(int)[sender selectedSegmentIndex] forIndex:0];
}

- (void)sendChartImageAnimationWithType:(int)chartType forIndex:(int)index {
    NSString *timePrefix = FUTURE_HOUR_PREFIX;
    if ((self.dayIndex == 0) && (index == 0)) {
        timePrefix = PAST_HOUR_PREFIX;
    }
    
    int hour = WW_HOUR_STEP * ([self.forecastModel getDayForecastStartingIndex:(int)self.dayIndex] + index);
    NSURL *wwChartURL = [NSURL URLWithString:[NSString stringWithFormat:BASE_WW_CHART_URL, [self getChartURLPrefixForType:chartType], timePrefix, hour]];
    [[AsyncImageLoader sharedLoader] loadImageWithURL:wwChartURL target:self success:@selector(imageLoadSuccess:) failure:@selector(imageLoadFailure:)];
}

- (IBAction)playButtonClicked:(id)sender {
    [self.chartImageView startAnimating];
    [self.chartAnimationPlayButton setHidden:YES];
    [self.chartAnimationPauseButton setHidden:NO];
}

- (IBAction)pauseButtonClicked:(id)sender {
    [self.chartImageView stopAnimating];
    [self.chartAnimationPauseButton setHidden:YES];
    [self.chartAnimationPlayButton setHidden:NO];
}

- (void) imageLoadFailure:(id)sender {
    [self.chartImageView setImage:[UIImage imageNamed:@"ErrorLoading"]];
    [self.chartLoadProgressIndicator setHidden:YES];
}

- (void)imageLoadSuccess:(id)sender {
    
    // Crop the image
    UIImage *croppedChart = [sender crop:CGRectMake(60, 0, 400, 300)];
    
    // Add the cropped image to the array for animation
    [self.animationImages addObject:croppedChart];
    
    if (needsReload[self.chartTypeSegmentControl.selectedSegmentIndex]) {
        [self.chartLoadProgressIndicator setProgress:self.animationImages.count/6.0f animated:YES];
    }
    
    if ([self.animationImages count] < 2) {
        // If its the first image set it to the header as a holder
        [self.chartImageView setImage:croppedChart];
    } else if ([self.animationImages count] == currentConditions.count) {
        // We have all of the images so animate!!!
        [self.chartImageView setAnimationImages:self.animationImages];
        [self.chartImageView setAnimationDuration:5];
        
        // Okay so this is really hacky... For some reasons the images are not loaded correctly on the first
        // pass through each of the views. 
        if (needsReload[self.chartTypeSegmentControl.selectedSegmentIndex]) {
            self.animationImages = [[NSMutableArray alloc] init];
            needsReload[self.chartTypeSegmentControl.selectedSegmentIndex] = NO;
        } else {
            // Show the play button, Hide the stop Button
            [self.chartAnimationPauseButton setHidden:YES];
            [self.chartAnimationPlayButton setHidden:NO];
            
            // Hide the progress bar becasue its loaded
            [self.chartLoadProgressIndicator setHidden:YES];
        }
    }
    if (self.animationImages.count < currentConditions.count) {
        // If the animation array isnt full, get the next image on the stack
        [self sendChartImageAnimationWithType:(int)self.chartTypeSegmentControl.selectedSegmentIndex
                                     forIndex:(int)self.animationImages.count];
    }
}

- (NSString*) getChartURLPrefixForType:(int)chartType {
    switch (chartType) {
        case WAVE_HEIGHT_CHART:
            return @"hs";
        case SWELL_PERIOD_CHART:
            return @"tp_sw1";
        case WIND_CHART:
            return @"u10";
        default:
            return @"";
    }
}

#pragma mark - TableView Handling

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (showDetailedForecastInfo) {
        return 90;
    } else {
        return 45;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return so there will always be currentconditions.count rows + the header row
    if (currentConditions == nil) {
        return 0;
    }
    
    if (showDetailedForecastInfo) {
        return currentConditions.count;
    } else {
        return currentConditions.count + 1;
    }
}

- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
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
        if (thisCondition.secondarySwellComponent.waveHeight.intValue < 1000) {
            secondarySwellLabel.text = [thisCondition.secondarySwellComponent getDetailedSwellSummmary];
        } else {
            secondarySwellLabel.text = @"No Secondary Swell Component";
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
    
    return cell;
}

 #pragma mark - Navigation
 
// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
// Get the new view controller using [segue destinationViewController].
// Pass the selected object to the new view controller.
//}

@end
