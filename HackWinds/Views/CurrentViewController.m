//
//  CurrentViewController.m
//  HackWinds
//
//  Created by Matthew Iannucci on 7/18/14.
//  Copyright (c) 2014 Matthew Iannucci. All rights reserved.
//
#define forecastFetchBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define CAMERA_IMAGE_COUNT 12

#import <MediaPlayer/MediaPlayer.h>
#import "CurrentViewController.h"
#import "AsyncImageView.h"
#import "Reachability.h"
#import "NavigationBarTitleWithSubtitleView.h"

@interface CurrentViewController ()

// UI properties
@property (weak, nonatomic) IBOutlet UIScrollView *camScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *camPaginator;
@property (weak, nonatomic) IBOutlet AsyncImageView *holderImageButton;
@property (weak, nonatomic) IBOutlet UILabel *dayHeader;
@property (weak, nonatomic) IBOutlet UITableView *mswTodayTable;
@property (strong, nonatomic) NavigationBarTitleWithSubtitleView *navigationBarTitle;

// Model Properties
@property (strong, nonatomic) ForecastModel *forecastModel;

@end

@implementation CurrentViewController {
    NSArray *currentConditions;
    AsyncImageView *currentCameraPages[CAMERA_IMAGE_COUNT];
    Camera *wwCamera;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    // Set up the custom nav bar with the forecast location
    self.navigationBarTitle = [[NavigationBarTitleWithSubtitleView alloc] init];
    [self.navigationItem setTitleView: self.navigationBarTitle];
    [self.navigationBarTitle setTitleText:@"HackWinds"];
    [self.navigationBarTitle.detailButton addTarget:self action:@selector(locationButtonClicked:)  forControlEvents:UIControlEventTouchDown];
    
    // Set up the camera model
    CameraModel *cameraModel = [CameraModel sharedModel];
    wwCamera = [[cameraModel.cameraURLS objectForKey:@"Narragansett"] objectForKey:@"Warm Winds"];
    
    // Set up the imageview scrolling
    self.camScrollView.contentSize = CGSizeMake(self.camScrollView.frame.size.width * CAMERA_IMAGE_COUNT, self.camScrollView.frame.size.height);
    self.camScrollView.delegate = self;
    
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
    [super viewWillAppear:animated];
    
    // Register the notification center listener when the view appears
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateDataFromModel)
                                                 name:FORECAST_DATA_UPDATED_TAG
                                               object:nil];
    
    // Update the data in the table using the forecast model
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    if (networkStatus != NotReachable) {
        [self updateDataFromModel];
    }
}

- (void)viewDidLayoutSubviews {
    [self loadCameraPages];
}

- (void)viewWillDisappear:(BOOL)animated {
    // Remove the listener when the view goes out of focus
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:FORECAST_DATA_UPDATED_TAG
                                                  object:nil];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateDataFromModel {
    // Load the MSW Data
    dispatch_async(forecastFetchBgQueue, ^{
        BOOL success = [self.forecastModel fetchForecastData];
        
        if (success) {
            currentConditions = [self.forecastModel getConditionsForIndex:0];
            [self performSelectorOnMainThread:@selector(getForecastSettings) withObject:nil waitUntilDone:YES];
            [self.mswTodayTable performSelectorOnMainThread:@selector(reloadData)
                                         withObject:nil waitUntilDone:YES];
        }
    });
}

- (void) loadCameraPages {
    // Set the page number
    double pageWidth = self.camScrollView.frame.size.width;
    int pageNumber = (int) floor((self.camScrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0));
    self.camPaginator.currentPage = pageNumber;
    
    // Get the pages that we need to add to the queue
    int firstPage = pageNumber - 1;
    int lastPage = pageNumber + 1;
    
    // Remove existing pages before the first page
    for (int index = 0; index < firstPage; index++) {
        [self removePageForIndex:index];
    }
    
    // Load all of the pages
    for (int index = firstPage; index <= lastPage; index++) {
        [self loadCameraPageForIndex:index];
    }
    
    // Remove anything after the last page
    for (int index = lastPage + 1; index < CAMERA_IMAGE_COUNT; index++) {
        [self removePageForIndex:index];
    }
}

- (void) loadCameraPageForIndex:(int)index {
    if ((index < 0) || (index >= CAMERA_IMAGE_COUNT)) {
        return;
    }
    
    AsyncImageView *pageView = currentCameraPages[index];
    if (pageView != nil) {
        pageView = currentCameraPages[index];
    } else {
        CGRect frame = self.camScrollView.frame;
        frame.origin.x = frame.size.width * index;
        frame.origin.y = 0.0;
        
        pageView = [[AsyncImageView alloc] init];
        pageView.frame = frame;
        pageView.contentMode = UIViewContentModeScaleToFill;
        pageView.imageURL = wwCamera.ImageURL;
        
        [self.camScrollView addSubview:pageView];
        currentCameraPages[index] = pageView;
    }
    
}

- (void) removePageForIndex:(int)index {
    if ((index < 0) || (index >= CAMERA_IMAGE_COUNT)) {
        return;
    }
    
    AsyncImageView *pageView = currentCameraPages[index];
    if (pageView != nil) {
        [pageView removeFromSuperview];
        currentCameraPages[index] = nil;
    }
}

- (void) locationButtonClicked:(id)sender {
    UIActionSheet *locationActionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Forecast Location"
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:FORECAST_LOCATIONS];
    // Show the action sheet
    [locationActionSheet setTintColor:HACKWINDS_BLUE_COLOR];
    [locationActionSheet showInView:self.view];
}

- (void) getForecastSettings {
    // Get the forecast location from the settings
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.nucc.HackWinds"];
    [defaults synchronize];
    
    // Grab the last set or default location
    NSString *forecastLocation = [defaults objectForKey:@"ForecastLocation"];
    [self.navigationBarTitle setDetailText:[NSString stringWithFormat:@"Location: %@", forecastLocation]];
}

#pragma mark - UIScrollViewDelegate

-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
    [self loadCameraPages];
}

#pragma mark - ActionSheet

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.nucc.HackWinds"];
    
    if (buttonIndex != [actionSheet numberOfButtons] - 1) {
        // If the user selects a location, set the settings key to the new location
        [defaults setObject:[actionSheet buttonTitleAtIndex:buttonIndex] forKey:@"ForecastLocation"];
        [defaults synchronize];
        
        // Tell everyone the data has updated
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]
             postNotificationName:FORECAST_LOCATION_CHANGED_TAG
             object:self];
        });
        
    } else {
        NSLog(@"Forecast Location change cancelled, keep location at %@", [defaults objectForKey:@"ForecastLocation"]);
    }
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return so there will always be 6 rows + the header row
    return ([[self.forecastModel getConditions] count] / 5) + 1;
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
