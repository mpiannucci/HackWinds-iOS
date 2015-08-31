//
//  ForecastViewController.m
//  HackWinds
//
//  Created by Matthew Iannucci on 7/18/14.
//  Copyright (c) 2014 Matthew Iannucci. All rights reserved.
//
#define FORECAST_FETCH_BG_QUEUE dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define WEEKDAYS [NSArray arrayWithObjects:@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", nil]

#import "ForecastViewController.h"
#import "DetailedForecastViewController.h"
#import "Reachability.h"
#import "NavigationBarTitleWithSubtitleView.h"

@interface ForecastViewController ()

@property (weak, nonatomic) IBOutlet UITableView *forecastTable;
@property (strong, nonatomic) NavigationBarTitleWithSubtitleView *navigationBarTitle;

@property (strong, nonatomic) ForecastModel *forecastModel;

@end

@implementation ForecastViewController
{
    NSInteger currentday;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view
    
    // Set up the custom nav bar with the forecast location
    self.navigationBarTitle = [[NavigationBarTitleWithSubtitleView alloc] init];
    [self.navigationItem setTitleView: self.navigationBarTitle];
    [self.navigationBarTitle setTitleText:@"HackWinds"];
    [self.navigationBarTitle.detailButton addTarget:self action:@selector(locationButtonClicked:)  forControlEvents:UIControlEventTouchDown];
    
    // Get the shared forecast model
    self.forecastModel = [ForecastModel sharedModel];
    
    // get the day of the week
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    currentday = [comps weekday];
}

- (void)viewWillAppear:(BOOL)animated {
    // Register listener for the data model update
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateDataFromModel)
                                                 name:@"ForecastModelDidUpdateDataNotification"
                                               object:nil];
    // Update the data table using the loaded data
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    if (networkStatus != NotReachable) {
        [self updateDataFromModel];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    // Remove the notifcation lsitener when the view is not in focus
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"ForecastModelDidUpdateDataNotification"
                                                  object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateDataFromModel {
    // Load the MSW Data
    dispatch_async(FORECAST_FETCH_BG_QUEUE, ^{
        [self performSelectorOnMainThread:@selector(getForecastSettings) withObject:nil waitUntilDone:YES];
        [self.forecastTable performSelectorOnMainThread:@selector(reloadData)
                                         withObject:nil waitUntilDone:YES];
    });
}

- (void) locationButtonClicked:(id)sender {
    UIActionSheet *locationActionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Forecast Location"
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:FORECAST_LOCATIONS];
    // Show the action sheet
    [locationActionSheet setTintColor:HACKWINDS_BLUE_COLOR];
    [locationActionSheet showInView:self.view];
}

- (void) getForecastSettings {
    // Get the forecast location from the settings
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.nucc.HackWinds"];
    [defaults synchronize];
    
    // Grab the last set or default location
    NSString *forecastLocation = [defaults objectForKey:@"ForecastLocation"];
    [self.navigationBarTitle setDetailText:[NSString stringWithFormat:@"Location: %@", forecastLocation]];
}

#pragma mark - ActionSheet

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.nucc.HackWinds"];
    
    if (buttonIndex != [actionSheet numberOfButtons] - 1) {
        // If the user selects a location, set the settings key to the new location
        [defaults setObject:[actionSheet buttonTitleAtIndex:buttonIndex] forKey:@"ForecastLocation"];
        [defaults synchronize];
        
        // Tell everyone the data has updated
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"ForecastLocationChanged"
             object:self];
        });
        
    } else {
        NSLog(@"Forecast Location change cancelled, keep location at %@", [defaults objectForKey:@"ForecastLocation"]);
    }
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return so there will always be 5 rows, or 0 if the data isnt correct
    return self.forecastModel.forecasts.count / 2;
}

- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    // Get the interface items
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"forecastItem"];
    UILabel *dayLabel = (UILabel *)[cell viewWithTag:21];
    UILabel *morningLabel = (UILabel*)[cell viewWithTag:22];
    UILabel *afternoonLabel = (UILabel *)[cell viewWithTag:23];
    UILabel *morningHeaderLabel = (UILabel *)[cell viewWithTag:24];
    UILabel *afternoonHeaderLabel = (UILabel *)[cell viewWithTag:25];
    NSUInteger index = indexPath.row;
    
    // Get the forecast object
    // Algorithm: i*2==morning, i*2+1==afternoon
    Forecast *morningForecast = [[self.forecastModel forecasts] objectAtIndex:index*2];
    Forecast *afternoonForecast = [[self.forecastModel forecasts] objectAtIndex:(index*2)+1];
    
    // Construct the strings and display them
    [dayLabel setText:[WEEKDAYS objectAtIndex:(((currentday-1) + index)%7)]];
    
    [morningLabel setText:[NSString stringWithFormat:@"%@ - %@ feet, Wind %@ %@ mph",
                           morningForecast.MinBreakHeight, morningForecast.MaxBreakHeight, morningForecast.WindDir, morningForecast.WindSpeed]];
    
    [afternoonLabel setText:[NSString stringWithFormat:@"%@ - %@ feet, Wind %@ %@ mph",
                           afternoonForecast.MinBreakHeight, afternoonForecast.MaxBreakHeight, afternoonForecast.WindDir, afternoonForecast.WindSpeed]];
    
    // Set the color of the morning label based on whether it has size or not
    if ([morningForecast.MinBreakHeight doubleValue] > 1.9) {
        if ([morningForecast.WindDir isEqualToString:@"WSW"] ||
            [morningForecast.WindDir isEqualToString:@"W"] ||
            [morningForecast.WindDir isEqualToString:@"WNW"] ||
            [morningForecast.WindDir isEqualToString:@"NW"] ||
            [morningForecast.WindDir isEqualToString:@"NNW"] ||
            [morningForecast.WindDir isEqualToString:@"N"]) {
            [morningHeaderLabel setTextColor:GREEN_COLOR];
        } else if ([morningForecast.WindSpeed doubleValue] < 8.0){
            [morningHeaderLabel setTextColor:GREEN_COLOR];
        } else {
            [morningHeaderLabel setTextColor:YELLOW_COLOR];
        }
    } else {
        [morningHeaderLabel setTextColor:RED_COLOR];
    }
    
    // Set the color of the afternoon label based on whether it has size or not
    if ([afternoonForecast.MinBreakHeight doubleValue] > 1.9) {
        if ([afternoonForecast.WindDir isEqualToString:@"WSW"] ||
            [afternoonForecast.WindDir isEqualToString:@"W"] ||
            [afternoonForecast.WindDir isEqualToString:@"WNW"] ||
            [afternoonForecast.WindDir isEqualToString:@"NW"] ||
            [afternoonForecast.WindDir isEqualToString:@"NNW"] ||
            [afternoonForecast.WindDir isEqualToString:@"N"]) {
            [afternoonHeaderLabel setTextColor:GREEN_COLOR];
        } else if ([afternoonForecast.WindSpeed doubleValue] < 8.0){
            [afternoonHeaderLabel setTextColor:GREEN_COLOR];
        } else {
            [afternoonHeaderLabel setTextColor:YELLOW_COLOR];
        }
    } else {
        [afternoonHeaderLabel setTextColor:RED_COLOR];
    }
    
    // Return the cell view
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Deselect the row
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"detailForecastSegue"]) {
        // Get the row of the table that was selected
        NSIndexPath *indexPath = [self.forecastTable indexPathForSelectedRow];
        DetailedForecastViewController *detailView = segue.destinationViewController;
        
        // Set the day that the data should be loaded for
        [detailView setDayIndex:indexPath.row];
        
        // Set the navigation header to the name of the day
        NSString *dayTitle = [WEEKDAYS objectAtIndex:(((currentday-1) + indexPath.row)%7)];
        detailView.navigationItem.title = dayTitle;
    }
}

@end
