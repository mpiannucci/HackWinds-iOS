//
//  FirstViewController.m
//  HackWinds
//
//  Created by Matthew Iannucci on 7/18/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//

#define mswBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define mswURL [NSURL URLWithString:@"http://magicseaweed.com/api/nFSL2f845QOAf1Tuv7Pf5Pd9PXa5sVTS/forecast/?spot_id=1103&fields=localTimestamp,swell.*,wind.*"]
#define wwStillURL [NSURL URLWithString:@"http://www.warmwinds.com/wp-content/uploads/surf-cam-stills/image00001.jpg"]

#import "FirstViewController.h"
#import "AsyncImageView.h"
#import "Condition.h"

@interface FirstViewController ()

@property (weak, nonatomic) IBOutlet AsyncImageView *holderImageButton;
@property (weak, nonatomic) IBOutlet UILabel *dayHeader;

@end

@implementation FirstViewController
{
    NSMutableArray *conditions;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Load the imageview
    [_holderImageButton setImageURL:wwStillURL];
    
    // Load the date
    NSDate *now = [[NSDate alloc] init];
    NSString *day = [self getDayHeader:now];
    [_dayHeader setText:day];
    
    // array to load data into
    conditions = [[NSMutableArray alloc] init];
    
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
    // Return so there will always be 6 rows
    return 6;
}

- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    // Get the interface items
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mswHourItem"];
    UILabel *hourLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *waveLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *windLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *swellLabel = (UILabel *)[cell viewWithTag:100];
    
    // Set the hour
    
    // Set the surf
    
    // Set the wind
    
    // Set the swell
    
    
    return cell;
}

- (NSString *)getDayHeader:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    return [dateFormatter stringFromDate:date];
}

- (NSString *)formatDate:(NSUInteger *)epoch
{
    // Return the formatted date string
    NSDate *forcTime = [NSDate dateWithTimeIntervalSince1970:*epoch];
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
    if (((AMrange.location != NSNotFound) && (Zerorange.location != NSNotFound)) || ((AMrange.location != NSNotFound) && (Threerange.location != NSNotFound)))
    {
        return false;
    }
    return true;
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
        Condition *thisCondition = [Condition init];
        
        // Get the hour
        
        
        // Get the surf
        
        // Get the wind
        
        // Get the swell
        
        // Append the condition
        [conditions addObject:thisCondition];
        
    }
}

@end
