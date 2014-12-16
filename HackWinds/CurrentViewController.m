//
//  CurrentViewController.m
//  HackWinds
//
//  Created by Matthew Iannucci on 7/18/14.
//  Copyright (c) 2014 Matthew Iannucci. All rights reserved.
//

#define forecastFetchBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define wwStillURL [NSURL URLWithString:@"http://www.warmwinds.com/wp-content/uploads/surf-cam-stills/image00001.jpg"]
#define wwLiveURL [NSURL URLWithString:@"http://162.243.101.197:1935/surfcam/live.stream/playlist.m3u8"]

#import <MediaPlayer/MediaPlayer.h>
#import "CurrentViewController.h"
#import "AsyncImageView.h"
#import "ForecastModel.h"
#import "Condition.h"
#import "Colors.h"

@interface CurrentViewController ()

// UI properties
@property (weak, nonatomic) IBOutlet AsyncImageView *holderImageButton;
@property (weak, nonatomic) IBOutlet UILabel *dayHeader;
@property (weak, nonatomic) IBOutlet UITableView *mswTodayTable;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;

// Model Properties
@property (strong, nonatomic) ForecastModel *forecastModel;

@end

@implementation CurrentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Load the imageview
    [_holderImageButton setImageURL:wwStillURL];
    
    // Get the date and set the weekday text
    NSDate *now = [[NSDate alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    [_dayHeader setText:[dateFormatter stringFromDate:now]];
    
    // Initialize the forecast model
    _forecastModel = [ForecastModel sharedModel];
    
    // Load the MSW Data
    dispatch_async(forecastFetchBgQueue, ^{
        [_forecastModel getCurrentConditions];
        [_mswTodayTable performSelectorOnMainThread:@selector(reloadData)
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
    // Return so there will always be 6 rows
    return [[_forecastModel conditions] count]+1;
}

- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    // Get the interface items
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mswHourItem"];
    UILabel *hourLabel = (UILabel *)[cell viewWithTag:11];
    UILabel *waveLabel = (UILabel *)[cell viewWithTag:12];
    UILabel *windLabel = (UILabel *)[cell viewWithTag:13];
    UILabel *swellLabel = (UILabel *)[cell viewWithTag:14];
    
    if ([indexPath row] < 1) {
        // Set the heder text cuz its the first row
        [hourLabel setText:@"Time"];
        [waveLabel setText:@"Surf"];
        [windLabel setText:@"Wind"];
        [swellLabel setText:@"Swell"];
        
        // Set the header label to be hackwinds color blue
        [hourLabel setTextColor:HACKWINDS_BLUE_COLOR];
        [waveLabel setTextColor:HACKWINDS_BLUE_COLOR];
        [windLabel setTextColor:HACKWINDS_BLUE_COLOR];
        [swellLabel setTextColor:HACKWINDS_BLUE_COLOR];
        
        // Set the text to be bold
        [hourLabel setFont:[UIFont boldSystemFontOfSize:17.0]];
        [waveLabel setFont:[UIFont boldSystemFontOfSize:17.0]];
        [windLabel setFont:[UIFont boldSystemFontOfSize:17.0]];
        [swellLabel setFont:[UIFont boldSystemFontOfSize:17.0]];
        
    } else {
        // Get the condition object
        Condition *thisCondition = [[_forecastModel conditions] objectAtIndex:indexPath.row-1];
    
        // Set the data to show in the labels
        [hourLabel setText:thisCondition.date];
        [waveLabel setText:[NSString stringWithFormat:@"%@ - %@", thisCondition.minBreak, thisCondition.maxBreak]];
        [windLabel setText:[NSString stringWithFormat:@"%@ %@", thisCondition.windDir, thisCondition.windSpeed]];
        [swellLabel setText:[NSString stringWithFormat:@"%@ %@ @ %@s", thisCondition.swellDir, thisCondition.swellHeight, thisCondition.swellPeriod]];
        
        // Make sure that the text is black
        [hourLabel setTextColor:[UIColor blackColor]];
        [waveLabel setTextColor:[UIColor blackColor]];
        [windLabel setTextColor:[UIColor blackColor]];
        [swellLabel setTextColor:[UIColor blackColor]];
        
        // Make sure the text isnt bold
        [hourLabel setFont:[UIFont systemFontOfSize:17.0]];
        [waveLabel setFont:[UIFont systemFontOfSize:17.0]];
        [windLabel setFont:[UIFont systemFontOfSize:17.0]];
        [swellLabel setFont:[UIFont systemFontOfSize:17.0]];
    }
    
    return cell;
}

- (IBAction)playButton:(id)sender {
    // Handle play button click
    NSLog(@"Video play button pressed");
    
    // Get the screen size
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    // Create a new MoviePlayer with the Live Stream URL
    self.moviePlayer=[[MPMoviePlayerController alloc] initWithContentURL:wwLiveURL];
    [self.moviePlayer.view setFrame:CGRectMake(0, 0, screenWidth, 255)];
    [self.view addSubview:self.moviePlayer.view];
    
    // Create an observer to handle the callback from the movie player finishing
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(moviePlayBackDidFinish:)
//                                                 name:MPMoviePlayerLoadStateDidChangeNotification
//                                               object:_moviePlayer];
    
    // Load the stream and play it
    [self.moviePlayer prepareToPlay];
    [self.moviePlayer play];
    
    // Hide the async holder image
    [self.holderImageButton setHidden:YES];
}

@end
