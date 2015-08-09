//
//  CurrentViewController.m
//  HackWinds
//
//  Created by Matthew Iannucci on 7/18/14.
//  Copyright (c) 2014 Matthew Iannucci. All rights reserved.
//

#define forecastFetchBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#import <MediaPlayer/MediaPlayer.h>
#import "CurrentViewController.h"
#import "AsyncImageView.h"
#import "Reachability.h"

@interface CurrentViewController ()

// UI properties
@property (weak, nonatomic) IBOutlet AsyncImageView *holderImageButton;
@property (weak, nonatomic) IBOutlet UILabel *dayHeader;
@property (weak, nonatomic) IBOutlet UITableView *mswTodayTable;
@property (strong, nonatomic) MPMoviePlayerController *streamPlayer;

// Model Properties
@property (strong, nonatomic) ForecastModel *forecastModel;

@end

@implementation CurrentViewController {
    NSArray *currentConditions;
    Camera *wwCamera;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    CameraModel *cameraModel = [CameraModel sharedModel];
    wwCamera = [[cameraModel.cameraURLS objectForKey:@"Narragansett"] objectForKey:@"Warm Winds"];
    
    // Load the imageview
    [self.holderImageButton setImageURL:wwCamera.ImageURL];
    
    // Get the date and set the weekday text
    NSDate *now = [[NSDate alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    [self.dayHeader setText:[dateFormatter stringFromDate:now]];
    
    // Initialize the forecast model
    self.forecastModel = [ForecastModel sharedModel];
}

- (void)viewWillAppear:(BOOL)animated {
    // Register the notification center listener when the view appears
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateDataFromModel)
                                                 name:@"ForecastModelDidUpdateDataNotification"
                                               object:nil];
    
    // Update the data in the table using the forecast model
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    if (networkStatus != NotReachable) {
        [self updateDataFromModel];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    // Remove the listener when the view goes out of focus
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"ForecastModelDidUpdateDataNotification"
                                                  object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playButton:(id)sender {
    // Handle play button click
    NSLog(@"Video play button pressed");
    
    // Get the screen size
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    // Create a new MoviePlayer with the Live Stream URL
    self.streamPlayer = [[MPMoviePlayerController alloc] initWithContentURL:wwCamera.VideoURL];
    [self.streamPlayer.view setFrame:CGRectMake(0, 0, screenWidth, 255)];
    [self.view addSubview:self.streamPlayer.view];
    
    // Set a listener for the video playback finishing
    [[NSNotificationCenter defaultCenter] addObserver:self
                                        selector:@selector(streamPlayBackDidFinish:)
                                        name:MPMoviePlayerPlaybackDidFinishNotification
                                        object:self.streamPlayer];
    
    // Load the stream and play it
    [self.streamPlayer prepareToPlay];
    [self.streamPlayer play];
    
    // Hide the async holder image
    [self.holderImageButton setHidden:YES];
}

- (void) streamPlayBackDidFinish:(NSNotification*)notification {
    // Remove the notification for the player
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                        name:MPMoviePlayerPlaybackDidFinishNotification
                                        object:self.streamPlayer];
    // Show the holder image again
    [self.holderImageButton setHidden:NO];
    
    // Remove the player from the superview
    [self.streamPlayer.view removeFromSuperview];
}

- (void) updateDataFromModel {
    // Load the MSW Data
    dispatch_async(forecastFetchBgQueue, ^{
        currentConditions = [self.forecastModel getConditionsForIndex:0];
        [self.mswTodayTable performSelectorOnMainThread:@selector(reloadData)
                                         withObject:nil waitUntilDone:YES];
    });
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return so there will always be 6 rows + the header row
    return (self.forecastModel.conditions.count / 5) + 1;
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
        if (currentConditions.count == 0) {
            return cell;
        }
        Condition *thisCondition = [currentConditions objectAtIndex:indexPath.row-1];
        
        // Set the data to show in the labels
        [hourLabel setText:thisCondition.Date];
        [waveLabel setText:[NSString stringWithFormat:@"%@ - %@", thisCondition.MinBreakHeight, thisCondition.MaxBreakHeight]];
        [windLabel setText:[NSString stringWithFormat:@"%@ %@", thisCondition.WindDirection, thisCondition.WindSpeed]];
        [swellLabel setText:[NSString stringWithFormat:@"%@ %@ @ %@s", thisCondition.SwellDirection, thisCondition.SwellHeight, thisCondition.SwellPeriod]];
        
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


@end
