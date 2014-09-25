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

#import "SecondViewController.h"
#import "Forecast.h"

@interface SecondViewController ()

@property (weak, nonatomic) IBOutlet UITableView *forecastTable;

@end

@implementation SecondViewController
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
    return 5;
}

- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    // Get the interface items
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"forecastItem"];
    
    // Get the forecast object
    // Algorithm: i*2==morning, i*2+1==afternoon
    
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


- (NSString *)getDayHeader:(NSInteger)day
{
    return [weekdays objectAtIndex:day];
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
