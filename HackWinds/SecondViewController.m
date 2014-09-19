//
//  SecondViewController.m
//  HackWinds
//
//  Created by Matthew Iannucci on 7/18/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//
#define mswBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define mswURL [NSURL URLWithString:@"http://magicseaweed.com/api/nFSL2f845QOAf1Tuv7Pf5Pd9PXa5sVTS/forecast/?spot_id=1103&fields=localTimestamp,swell.*,wind.*"]

#import "SecondViewController.h"
#import "Forecast.h"

@interface SecondViewController ()

@property (weak, nonatomic) IBOutlet UITableView *forecastTable;

@end

@implementation SecondViewController
{
    NSMutableArray *forecasts;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view

    // array to load data into
    forecasts = [[NSMutableArray alloc] init];
    
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
    return 5;
}

- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    // Get the interface items
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"forecastItem"];
    
    
    
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
    // Quick log to chekc the amount of json objects recieved
    NSLog(@"%lu", (unsigned long)[json count]);
    
    // Loop through the objects, create new condition objects, and append to the array
    int i = 0;
    int j = 0;
    while (i<6) {
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
    NSRange Zerorange = [dateString rangeOfString:@"0"];
    NSRange Threerange = [dateString rangeOfString:@"3"];
    if (((AMrange.location != NSNotFound) && (Zerorange.location != NSNotFound)) ||
        ((AMrange.location != NSNotFound) && (Threerange.location != NSNotFound)))
    {
        return false;
    }
    return true;
}

@end
