//
//  ForecastViewController.m
//  HackWinds
//
//  Created by Matthew Iannucci on 7/18/14.
//  Copyright (c) 2014 Matthew Iannucci. All rights reserved.
//

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
    BOOL lastFetchFailure;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view
    
    // Set up the custom nav bar with the forecast location
    self.navigationBarTitle = [[NavigationBarTitleWithSubtitleView alloc] init];
    [self.navigationItem setTitleView: self.navigationBarTitle];
    [self.navigationBarTitle setTitleText:@"HackWinds"];
    [self.navigationBarTitle setDetailText:@"Location: Narragansett"];
    
    // Get the shared forecast model
    self.forecastModel = [ForecastModel sharedModel];
    
    // Get the day of the week
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    currentday = [comps weekday];
    
    // Initialize failure to false
    lastFetchFailure = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateUI];
    
    // Register listener for the data model update
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUI)
                                                 name:FORECAST_DATA_UPDATED_TAG
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(forecastUpdateFailed)
                                                 name:FORECAST_DATA_UPDATE_FAILED_TAG
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    // Remove the notifcation lsitener when the view is not in focus
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:FORECAST_DATA_UPDATED_TAG
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:FORECAST_DATA_UPDATE_FAILED_TAG
                                                  object:nil];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateUI {
    lastFetchFailure = NO;
    
    [self.forecastTable reloadData];
}

- (void) forecastUpdateFailed {
    lastFetchFailure = YES;
    
    [self.forecastTable reloadData];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return so there will always be 5 rows, or 0 if the data isnt correct
    return [self.forecastModel getDayCount];
}

- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    // Get the forecast object
    ForecastDailySummary *summary = [self.forecastModel.dailyForecasts objectAtIndex:indexPath.row];
    
    // Get the interface items
    UITableViewCell *cell = nil;
    UILabel *dayLabel = nil;
    UILabel *morningLabel = nil;
    UILabel *afternoonLabel = nil;
    UILabel *morningHeaderLabel = nil;
    UILabel *afternoonHeaderLabel = nil;
    
    if (indexPath.row == 0 && [summary.morningWindCompassDirection isEqualToString:@""]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"afternoonForecastItem"];
        dayLabel = (UILabel *)[cell viewWithTag:21];
        afternoonLabel = (UILabel *)[cell viewWithTag:23];
        afternoonHeaderLabel = (UILabel *)[cell viewWithTag:25];
    } else if (indexPath.row == ([self.forecastModel getDayCount] - 1) && [summary.afternoonWindCompassDirection isEqualToString:@""]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"morningForecastItem"];
        dayLabel = (UILabel *)[cell viewWithTag:21];
        morningLabel = (UILabel*)[cell viewWithTag:22];
        morningHeaderLabel = (UILabel *)[cell viewWithTag:24];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"fullForecastItem"];
        dayLabel = (UILabel *)[cell viewWithTag:21];
        morningLabel = (UILabel*)[cell viewWithTag:22];
        afternoonLabel = (UILabel *)[cell viewWithTag:23];
        morningHeaderLabel = (UILabel *)[cell viewWithTag:24];
        afternoonHeaderLabel = (UILabel *)[cell viewWithTag:25];
    }

    
    if (lastFetchFailure) {
        dayLabel.text = @"";
        if (morningLabel != nil) {
            morningLabel.text = @"";
            morningHeaderLabel.text = @"";
        }
        if (afternoonLabel != nil) {
            afternoonLabel.text = @"";
            afternoonHeaderLabel.text = @"";
        }
        return cell;
    }
    
    // Construct the strings and display them
    [dayLabel setText:[WEEKDAYS objectAtIndex:(((currentday-1) + indexPath.row)%7)]];
    
    if (morningLabel != nil) {
        [morningLabel setText:[NSString stringWithFormat:@"%d - %d feet, Wind %@ %d mph", summary.morningMinimumBreakingHeight.intValue, summary.morningMaximumBreakingHeight.intValue, summary.morningWindCompassDirection, summary.morningWindSpeed.intValue]];
        
        // Set the color of the morning label based on whether it has size or not
        if (summary.morningMinimumBreakingHeight.intValue > 1) {
            if ([summary.morningWindCompassDirection isEqualToString:@"WSW"] ||
                [summary.morningWindCompassDirection isEqualToString:@"W"] ||
                [summary.morningWindCompassDirection isEqualToString:@"WNW"] ||
                [summary.morningWindCompassDirection isEqualToString:@"NW"] ||
                [summary.morningWindCompassDirection isEqualToString:@"NNW"] ||
                [summary.morningWindCompassDirection isEqualToString:@"N"]) {
                morningHeaderLabel.textColor = GREEN_COLOR;
            } else if (summary.morningWindSpeed.intValue < 8) {
                morningHeaderLabel.textColor = GREEN_COLOR;
            } else {
                morningHeaderLabel.textColor = YELLOW_COLOR;
            }
        } else {
            morningHeaderLabel.textColor = RED_COLOR;
        }
    }
    
    if (afternoonLabel != nil) {
    
        [afternoonLabel setText:[NSString stringWithFormat:@"%d - %d feet, Wind %@ %d mph", summary.afternoonMinimumBreakingHeight.intValue, summary.afternoonMaximumBreakingHeight.intValue, summary.afternoonWindCompassDirection, summary.afternoonWindSpeed.intValue]];
    
        // Set the color of the afternoon label based on whether it has size or not
        if (summary.afternoonMinimumBreakingHeight.intValue > 1) {
            if ([summary.afternoonWindCompassDirection isEqualToString:@"WSW"] ||
                [summary.afternoonWindCompassDirection isEqualToString:@"W"] ||
                [summary.afternoonWindCompassDirection isEqualToString:@"WNW"] ||
                [summary.afternoonWindCompassDirection isEqualToString:@"NW"] ||
                [summary.afternoonWindCompassDirection isEqualToString:@"NNW"] ||
                [summary.afternoonWindCompassDirection isEqualToString:@"N"]) {
                afternoonHeaderLabel.textColor = GREEN_COLOR;
            } else if (summary.afternoonWindSpeed.intValue < 8){
                afternoonHeaderLabel.textColor = GREEN_COLOR;
            } else {
                afternoonHeaderLabel.textColor = YELLOW_COLOR;
            }
        } else {
        afternoonHeaderLabel.textColor = RED_COLOR;
        }
    }
    
    // Return the cell view
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ForecastDailySummary *summary = [self.forecastModel.dailyForecasts objectAtIndex:indexPath.row];
    if (indexPath.row == 0 && [summary.morningWindCompassDirection isEqualToString:@""]) {
        return 120.0f;
    } else if (indexPath.row == ([self.forecastModel getDayCount] - 1) && [summary.afternoonWindCompassDirection isEqualToString:@""]) {
        return 120.0f;
    } else {
        return 190.0f;
    }
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
