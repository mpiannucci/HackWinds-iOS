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
#import "ForecastModel.h"
#import "Forecast.h"
#import "Colors.h"

@interface ForecastViewController ()

@property (weak, nonatomic) IBOutlet UITableView *forecastTable;

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
    
    // Get the shared forecast model
    _forecastModel = [ForecastModel sharedModel];
    
    // get the day of the week
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    currentday = [comps weekday];
    
    // Load the MSW Data
    dispatch_async(FORECAST_FETCH_BG_QUEUE, ^{
        [_forecastModel getForecasts];
        [_forecastTable performSelectorOnMainThread:@selector(reloadData)
                               withObject:nil waitUntilDone:YES];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return so there will always be 5 rows
    return [[_forecastModel forecasts] count]/2;
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
    Forecast *morningForecast = [[_forecastModel forecasts] objectAtIndex:index*2];
    Forecast *afternoonForecast = [[_forecastModel forecasts] objectAtIndex:(index*2)+1];
    
    // Construct the strings and display them
    [dayLabel setText:[WEEKDAYS objectAtIndex:(((currentday-1) + index)%7)]];
    
    [morningLabel setText:[NSString stringWithFormat:@"%@ - %@ feet, Wind %@ %@ mph",
                           morningForecast.minBreak, morningForecast.maxBreak, morningForecast.windDir, morningForecast.windSpeed]];
    
    [afternoonLabel setText:[NSString stringWithFormat:@"%@ - %@ feet, Wind %@ %@ mph",
                           afternoonForecast.minBreak, afternoonForecast.maxBreak, afternoonForecast.windDir, afternoonForecast.windSpeed]];
    
    // Set the color of the morning label based on whether it has size or not
    if ([morningForecast.minBreak doubleValue] > 1.9) {
        if ([morningForecast.windDir isEqualToString:@"WSW"] ||
            [morningForecast.windDir isEqualToString:@"W"] ||
            [morningForecast.windDir isEqualToString:@"WNW"] ||
            [morningForecast.windDir isEqualToString:@"NW"] ||
            [morningForecast.windDir isEqualToString:@"NNW"] ||
            [morningForecast.windDir isEqualToString:@"N"]) {
            [morningHeaderLabel setTextColor:GREEN_COLOR];
        } else if ([morningForecast.windSpeed doubleValue] < 8.0){
            [morningHeaderLabel setTextColor:GREEN_COLOR];
        } else {
            [morningHeaderLabel setTextColor:YELLOW_COLOR];
        }
    } else {
        [morningHeaderLabel setTextColor:RED_COLOR];
    }
    
    // Set the color of the afternoon label based on whether it has size or not
    if ([afternoonForecast.minBreak doubleValue] > 1.9) {
        if ([afternoonForecast.windDir isEqualToString:@"WSW"] ||
            [afternoonForecast.windDir isEqualToString:@"W"] ||
            [afternoonForecast.windDir isEqualToString:@"WNW"] ||
            [afternoonForecast.windDir isEqualToString:@"NW"] ||
            [afternoonForecast.windDir isEqualToString:@"NNW"] ||
            [afternoonForecast.windDir isEqualToString:@"N"]) {
            [afternoonHeaderLabel setTextColor:GREEN_COLOR];
        } else if ([afternoonForecast.windSpeed doubleValue] < 8.0){
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

@end
