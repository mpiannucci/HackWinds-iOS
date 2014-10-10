//
//  SecondViewController.m
//  HackWinds
//
//  Created by Matthew Iannucci on 7/18/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//
#define mswBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define mswURL [NSURL URLWithString:@"http://magicseaweed.com/api/nFSL2f845QOAf1Tuv7Pf5Pd9PXa5sVTS/forecast/?spot_id=1103&fields=localTimestamp,swell.*,wind.*"]
#define weekdays [NSArray arrayWithObjects:@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", nil]

#import "ForecastViewController.h"
#import "Forecast.h"

@interface ForecastViewController ()

@property (weak, nonatomic) IBOutlet UITableView *forecastTable;

@end

@implementation ForecastViewController
{
    NSMutableArray *forecasts;
    NSInteger currentday;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view

    // array to load data into
    forecasts = [[NSMutableArray alloc] init];
    
    // get the day of the week
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    currentday = [comps weekday];
    
    // Load the MSW Data
    dispatch_async(mswBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:
                        mswURL];
        [self performSelectorOnMainThread:@selector(fetchedMSWData:)
                               withObject:data waitUntilDone:YES];
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
    NSLog(@"%lu", (unsigned long)[forecasts count]);
    return [forecasts count]/2;
}

- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    // Get the interface items
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"forecastItem"];
    UILabel *dayLabel = (UILabel *)[cell viewWithTag:21];
    UILabel *morningLabel = (UILabel*)[cell viewWithTag:22];
    UILabel *afternoonLabel = (UILabel *)[cell viewWithTag:23];
    //UILabel *morningHeaderLabel = (UILabel *)[cell viewWithTag:24];
    //ILabel *afternoonHeaderLabel = (UILabel *)[cell viewWithTag:25];
    NSUInteger index = indexPath.row;
    
    // Get the forecast object
    // Algorithm: i*2==morning, i*2+1==afternoon
    Forecast *morningForecast = [forecasts objectAtIndex:index*2];
    Forecast *afternoonForecast = [forecasts objectAtIndex:(index*2)+1];
    
    // Construct the strings and display them
    [dayLabel setText:[weekdays objectAtIndex:((currentday + index)%7)]];
    
    [morningLabel setText:[NSString stringWithFormat:@"%@ - %@ feet, Wind %@ %@ mph",
                           morningForecast.minBreak, morningForecast.maxBreak, morningForecast.windDir, morningForecast.windSpeed]];
    
    [afternoonLabel setText:[NSString stringWithFormat:@"%@ - %@ feet, Wind %@ %@ mph",
                           afternoonForecast.minBreak, afternoonForecast.maxBreak, afternoonForecast.windDir, afternoonForecast.windSpeed]];
    
    // TODO: Set the color of the label based on whether its good or not
    
    // Return the cell view
    return cell;
}

- (void)fetchedMSWData:(NSData *)responseData {
    //parse out the MSW json data
    NSError* error;
    NSArray* json = [NSJSONSerialization
                     JSONObjectWithData:responseData
                     options:kNilOptions
                     error:&error];
    // Quick log to check the amount of json objects recieved
    NSLog(@"%lu", (unsigned long)[json count]);
    
    // Loop through the objects, create new condition objects, and append to the array
    int i = 0;
    int j = 0;
    while (i<10) {
        NSDictionary *thisDict = [json objectAtIndex:j];
        j++;
        
        // Get the hour
        NSNumber *rawDate = [thisDict objectForKey:@"localTimestamp"];
        NSString *date = [self formatDate:[rawDate unsignedIntegerValue]];
        Boolean check = [self checkDate:date];
        if (!check)
        {
            continue;
        }
        Forecast *thisForecast = [[Forecast alloc] init];
        [thisForecast setDate:date];
        
        // Get the surf
        NSDictionary *swellDict = [thisDict objectForKey:@"swell"];
        [thisForecast setMinBreak:[swellDict objectForKey:@"minBreakingHeight"]];
        [thisForecast setMaxBreak:[swellDict objectForKey:@"maxBreakingHeight"]];
        
        // Get the wind
        NSDictionary *windDict = [thisDict objectForKey:@"wind"];
        [thisForecast setWindSpeed:[windDict objectForKey:@"speed"]];
        [thisForecast setWindDir:[windDict objectForKey:@"compassDirection"]];
        
        // Append the condition
        [forecasts addObject:thisForecast];
        i++;
    }
    // reload the table data
    [_forecastTable reloadData];
}

- (NSString *)formatDate:(NSUInteger)epoch
{
    // Return the formatted date string
    NSDate *forcTime = [NSDate dateWithTimeIntervalSince1970:epoch];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"K a"];
    [format setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSString *formatted = [format stringFromDate:forcTime];
    if ([formatted hasPrefix:@"0"]) {
        [format setDateFormat:@"HH a"];
        [format setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        formatted = [format stringFromDate:forcTime];
    }
    return formatted;
}

- (Boolean)checkDate:(NSString *)dateString
{
    // Check if the date is for a valid time
    NSRange AMrange = [dateString rangeOfString:@"AM"];
    NSRange PMrange = [dateString rangeOfString:@"PM"];
    NSRange Zerorange = [dateString rangeOfString:@"0"];
    NSRange Threerange = [dateString rangeOfString:@"3"];
    NSRange Sixrange = [dateString rangeOfString:@"6"];
    NSRange Ninerange = [dateString rangeOfString:@"9"];
    NSRange Twelverange = [dateString rangeOfString:@"12"];
    if (((AMrange.location != NSNotFound) && (Zerorange.location != NSNotFound)) ||
        ((AMrange.location != NSNotFound) && (Threerange.location != NSNotFound)) ||
        ((AMrange.location != NSNotFound) && (Sixrange.location != NSNotFound)) ||
        ((PMrange.location != NSNotFound) && (Twelverange.location != NSNotFound)) ||
        ((PMrange.location != NSNotFound) && (Sixrange.location != NSNotFound)) ||
        ((PMrange.location != NSNotFound) && (Ninerange.location != NSNotFound)))
    {
        return false;
    }
    return true;
}

@end
