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
#define wwLiveURL [NSURL URLWithString:@"http://162.243.101.197:1935/surfcam/live.stream/playlist.m3u8"]

#import <MediaPlayer/MediaPlayer.h>
#import "FirstViewController.h"
#import "AsyncImageView.h"
#import "Condition.h"

@interface FirstViewController ()

@property (weak, nonatomic) IBOutlet AsyncImageView *holderImageButton;
@property (weak, nonatomic) IBOutlet UILabel *dayHeader;
@property (weak, nonatomic) IBOutlet UITableView *mswTodayTable;
@property (strong,nonatomic) MPMoviePlayerController *moviePlayer;

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
    NSLog(@"%lu", (unsigned long)[conditions count]);
    return [conditions count];
}

- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    // Get the interface items
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mswHourItem"];
    UILabel *hourLabel = (UILabel *)[cell viewWithTag:11];
    UILabel *waveLabel = (UILabel *)[cell viewWithTag:12];
    UILabel *windLabel = (UILabel *)[cell viewWithTag:13];
    UILabel *swellLabel = (UILabel *)[cell viewWithTag:14];
    
    // Get the condition object
    Condition *thisCondition = [conditions objectAtIndex:indexPath.row];
    NSLog(@"%@", thisCondition.date);
    
    // Set the hour
    [hourLabel setText:thisCondition.date];
    
    // Set the surf
    [waveLabel setText:[NSString stringWithFormat:@"%@ - %@", thisCondition.minBreak, thisCondition.maxBreak]];
    
    // Set the wind
    [windLabel setText:[NSString stringWithFormat:@"%@ %@", thisCondition.windDir, thisCondition.windSpeed]];
    
    // Set the swell
    [swellLabel setText:[NSString stringWithFormat:@"%@ %@ @ %@s", thisCondition.swellDir, thisCondition.swellHeight, thisCondition.swellPeriod]];
    
    return cell;
}

- (NSString *)getDayHeader:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    return [dateFormatter stringFromDate:date];
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
        Condition *thisCondition = [[Condition alloc] init];
        [thisCondition setDate:date];
        
        // Get the surf
        NSDictionary *swellDict = [thisDict objectForKey:@"swell"];
        [thisCondition setMinBreak:[swellDict objectForKey:@"minBreakingHeight"]];
        [thisCondition setMaxBreak:[swellDict objectForKey:@"maxBreakingHeight"]];
        
        // Get the wind
        NSDictionary *windDict = [thisDict objectForKey:@"wind"];
        [thisCondition setWindSpeed:[windDict objectForKey:@"speed"]];
        [thisCondition setWindDeg:[windDict objectForKey:@"direction"]];
        [thisCondition setWindDir:[windDict objectForKey:@"compassDirection"]];
        
        // Get the swell
        [thisCondition setSwellHeight:[[[swellDict objectForKey:@"components"] objectForKey:@"primary"] objectForKey:@"height"]];
        [thisCondition setSwellPeriod:[[[swellDict objectForKey:@"components"] objectForKey:@"primary"] objectForKey:@"period"]];
        [thisCondition setSwellDir:[[[swellDict objectForKey:@"components"] objectForKey:@"primary"] objectForKey:@"compassDirection"]];
        
        // Append the condition
        [conditions addObject:thisCondition];
        i++;
    }
    // reload the table data
    [_mswTodayTable reloadData];
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

- (IBAction)playButton:(id)sender {
    // Handle play button click
    NSLog(@"Video play button pressed");
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    self.moviePlayer=[[MPMoviePlayerController alloc] initWithContentURL:wwLiveURL];
    [self.moviePlayer.view setFrame:CGRectMake(0, 0, screenWidth, 255)];
    [self.view addSubview:self.moviePlayer.view];
    [self.moviePlayer prepareToPlay];
    [self.moviePlayer play];
    
    // Hide the async holder image
    [self.holderImageButton setHidden:YES];
}

@end
