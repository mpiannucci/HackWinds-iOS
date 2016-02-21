//
//  CurrentViewController.m
//  HackWinds
//
//  Created by Matthew Iannucci on 7/18/14.
//  Copyright (c) 2014 Matthew Iannucci. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "CurrentViewController.h"
#import "AsyncImageView.h"
#import "Reachability.h"
#import <HackWindsDataKit/HackWindsDataKit.h>

static const int CAMERA_IMAGE_COUNT = 8;

@interface CurrentViewController ()

// UI properties
@property (weak, nonatomic) IBOutlet UIScrollView *camScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *camPaginator;
@property (weak, nonatomic) IBOutlet UILabel *dayHeader;
@property (weak, nonatomic) IBOutlet UITableView *mswTodayTable;

// Model Properties
@property (strong, nonatomic) ForecastModel *forecastModel;

@end

@implementation CurrentViewController {
    NSArray *currentConditions;
    AsyncImageView *currentCameraPages[CAMERA_IMAGE_COUNT];
    Camera *wwCamera;
    BOOL lastFetchFailure;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    // Set up the imageview scrolling
    self.camScrollView.delegate = self;
    
    // Get the date and set the weekday text
    NSDate *now = [[NSDate alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    [self.dayHeader setText:[dateFormatter stringFromDate:now]];
    
    // Initialize the forecast model
    self.forecastModel = [ForecastModel sharedModel];
    
    // Initialize the failures to false
    lastFetchFailure = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Update the UI in case we missed a notification
    [self updateUI];
    
    // Register the notification center listener when the view appears
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUI)
                                                 name:FORECAST_DATA_UPDATED_TAG
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(forecastUpdateFailed)
                                                 name:FORECAST_DATA_UPDATE_FAILED_TAG
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setupCamera)
                                                 name:CAMERA_DATA_UPDATED_TAG
                                               object:nil];
}

- (void)viewDidLayoutSubviews {
    self.camScrollView.contentSize = CGSizeMake(self.camScrollView.frame.size.width * CAMERA_IMAGE_COUNT, self.camScrollView.frame.size.height);
}

- (void)viewWillDisappear:(BOOL)animated {
    // Remove the listener when the view goes out of focus
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:FORECAST_DATA_UPDATED_TAG
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:FORECAST_DATA_UPDATE_FAILED_TAG
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:CAMERA_DATA_UPDATED_TAG
                                                  object:nil];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateUI {
    currentConditions = [self.forecastModel getForecastsForDay:0];
    
    if (currentConditions == nil) {
        lastFetchFailure = YES;
    } else {
        lastFetchFailure = NO;
    }
    
    [self.mswTodayTable reloadData];
}

- (void) forecastUpdateFailed {
    lastFetchFailure = YES;
    
    [self.mswTodayTable reloadData];
}

#pragma mark - Camera setup and scrolling

- (void) setupCamera {
    CameraModel *cameraModel = [CameraModel sharedModel];
    wwCamera = [[cameraModel.cameraURLS objectForKey:@"Narragansett"] objectForKey:@"Warm Winds"];
    [self loadCameraPages];
}

- (void) loadCameraPages {
    // Make sure the cameras have been loaded
    if (wwCamera == nil) {
        return;
    }
    
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
        CGRect frame = self.camScrollView.bounds;
        frame.origin.x = frame.size.width * index;
        frame.origin.y = 0.0;
        
        pageView = [[AsyncImageView alloc] init];
        pageView.frame = frame;
        if (frame.size.width > 321) {
            pageView.contentMode = UIViewContentModeScaleAspectFit;
        } else {
            pageView.contentMode = UIViewContentModeScaleToFill;
        }
        pageView.imageURL = [self getCameraURLForIndex:index];
        
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

- (NSURL*) getCameraURLForIndex:(int)index {
    NSString *baseURL = [wwCamera.imageURL absoluteString];
    return [NSURL URLWithString:[baseURL stringByReplacingOccurrencesOfString:@"1.jpg"
                                                                   withString:[NSString stringWithFormat:@"%d.jpg", index+1]]];
}

#pragma mark - UIScrollViewDelegate

-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
    [self loadCameraPages];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return so there will always be 6 rows + the header row
    if (currentConditions == nil) {
        return 1;
    }
    
    return currentConditions.count + 1;
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
        hourLabel.text = @"Time";
        waveLabel.text = @"Surf";
        windLabel.text = @"Wind";
        swellLabel.text = @"Swell";
        
        // Set the header label to be hackwinds color blue
        hourLabel.textColor = HACKWINDS_BLUE_COLOR;
        waveLabel.textColor = HACKWINDS_BLUE_COLOR;
        windLabel.textColor = HACKWINDS_BLUE_COLOR;
        swellLabel.textColor = HACKWINDS_BLUE_COLOR;
        
        // Set the text to be bold
        hourLabel.font = [UIFont boldSystemFontOfSize:17.0];
        waveLabel.font = [UIFont boldSystemFontOfSize:17.0];
        windLabel.font = [UIFont boldSystemFontOfSize:17.0];
        swellLabel.font = [UIFont boldSystemFontOfSize:17.0];
        
    } else {
        // Get the condition object
        if (lastFetchFailure) {
            hourLabel.text = @"";
            waveLabel.text = @"";
            windLabel.text = @"";
            swellLabel.text = @"";
            
            return cell;
        }
        
        if (currentConditions.count == 0) {
            return cell;
        }
        
        Forecast *thisCondition = [currentConditions objectAtIndex:indexPath.row-1];
        
        // Set the data to show in the labels
        hourLabel.text = thisCondition.timeString;
        waveLabel.text = [NSString stringWithFormat:@"%d - %d", thisCondition.minimumBreakingHeight.intValue, thisCondition.maximumBreakingHeight.intValue];
        windLabel.text = [NSString stringWithFormat:@"%@ %d", thisCondition.windCompassDirection, thisCondition.windSpeed.intValue];
        swellLabel.text = [NSString stringWithFormat:@"%@ %2.2f @ %2.1fs", thisCondition.primarySwellComponent.compassDirection, thisCondition.primarySwellComponent.waveHeight.doubleValue, thisCondition.primarySwellComponent.period.doubleValue];
        
        // Make sure that the text is black
        hourLabel.textColor = [UIColor blackColor];
        waveLabel.textColor = [UIColor blackColor];
        windLabel.textColor = [UIColor blackColor];
        swellLabel.textColor = [UIColor blackColor];
        
        // Set the text to be bold
        hourLabel.font = [UIFont systemFontOfSize:17.0];
        waveLabel.font = [UIFont systemFontOfSize:17.0];
        windLabel.font = [UIFont systemFontOfSize:17.0];
        swellLabel.font = [UIFont systemFontOfSize:17.0];
    }
    return cell;
}


@end
