//
//  ForecastViewController.m
//  HackWinds
//
//  Created by Matthew Iannucci on 7/18/14.
//  Copyright (c) 2014 Matthew Iannucci. All rights reserved.
//
#define WEEKDAYS [NSArray arrayWithObjects:@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", nil]

#import "ForecastViewController.h"
#import "DetailedForecastViewController.h"
#import "Reachability.h"

@interface ForecastViewController ()

@property (weak, nonatomic) IBOutlet UITableView *forecastTable;

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
    
    // Get the shared forecast model
    self.forecastModel = [ForecastModel sharedModel];
    
    // get the day of the week
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    currentday = [comps weekday];
    
    // Initialize failure to false
    lastFetchFailure = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Update the UI in case we missed a notification
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
    // Get the interface items
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"forecastItem"];
    UILabel *dayLabel = (UILabel *)[cell viewWithTag:21];
    UILabel *morningLabel = (UILabel*)[cell viewWithTag:22];
    UILabel *afternoonLabel = (UILabel *)[cell viewWithTag:23];
    UILabel *morningHeaderLabel = (UILabel *)[cell viewWithTag:24];
    UILabel *afternoonHeaderLabel = (UILabel *)[cell viewWithTag:25];
    NSUInteger index = indexPath.row;
    
    if (lastFetchFailure) {
        dayLabel.text = @"";
        morningLabel.text = @"";
        afternoonLabel.text = @"";
        morningHeaderLabel.text = @"";
        afternoonHeaderLabel.text = @"";
        
        return cell;
    }
    
    // Get the forecast object
    ForecastDailySummary *summary = [self.forecastModel.dailyForecasts objectAtIndex:index];
    
    // Construct the strings and display them
    [dayLabel setText:[WEEKDAYS objectAtIndex:(((currentday-1) + index)%7)]];
    
    [morningLabel setText:[NSString stringWithFormat:@"%d - %d feet, Wind %@ %d mph",
                           summary.morningMinimumBreakingHeight.intValue, summary.morningMaximumBreakingHeight.intValue, summary.morningWindCompassDirection, summary.morningWindSpeed.intValue]];
    
    [afternoonLabel setText:[NSString stringWithFormat:@"%d - %d feet, Wind %@ %d mph",
                           summary.afternoonMinimumBreakingHeight.intValue, summary.afternoonMaximumBreakingHeight.intValue, summary.afternoonWindCompassDirection, summary.afternoonWindSpeed.intValue]];
    
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
