//
//  CurrentViewController.m
//  HackWinds
//
//  Created by Matthew Iannucci on 7/18/14.
//  Copyright (c) 2014 Matthew Iannucci. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import "CurrentViewController.h"
#import "AsyncImageView.h"
#import "Reachability.h"
#import <HackWindsDataKit/HackWindsDataKit.h>

static const int CAMERA_IMAGE_COUNT = 11;

@interface CurrentViewController ()

// UI properties
@property (weak, nonatomic) IBOutlet UIScrollView *camScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *camPaginator;
@property (weak, nonatomic) IBOutlet UILabel *dayHeader;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *alternateCamerasBarButton;

// Model Properties
@property (strong, nonatomic) ForecastModel *forecastModel;
@property (strong, nonatomic) TideModel *tideModel;

@end

@implementation CurrentViewController {
    NSArray *currentConditions;
    AsyncImageView *currentCameraPages[CAMERA_IMAGE_COUNT];
    GTLRCamera_ModelCameraMessagesCameraMessage *wwCamera;
    BOOL lastFetchFailure;
    BOOL is24HourClock;
    BOOL showDetailedForecastInfo;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    // Set the navbar
    UIButton* titleButton = [[UIButton alloc] initWithFrame:self.navigationItem.titleView.frame];
    [titleButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [titleButton setTitle:@"Rhode Island" forState:UIControlStateNormal];
    [titleButton addTarget:self action:@selector(showModelInformationPopup) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = titleButton;
    
    // Setup up tap shortcut for the live view
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showLiveCamera:)];
    tapRecognizer.numberOfTapsRequired = 2;
    [self.camScrollView addGestureRecognizer:tapRecognizer];
    
    // Set up the imageview scrolling
    self.camScrollView.delegate = self;
    self.camPaginator.numberOfPages = CAMERA_IMAGE_COUNT;
    
    // Check for 24 hour time
    [self check24HourClock];
    
    // Initialize the forecast model
    self.forecastModel = [ForecastModel sharedModel];
    self.tideModel = [TideModel sharedModel];
    
    // Initialize the failures to false
    lastFetchFailure = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Register the notification center listener when the view appears
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUI)
                                                 name:FORECAST_DATA_UPDATED_TAG
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUI)
                                                 name:TIDE_DATA_UPDATED_TAG object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(forecastUpdateFailed)
                                                 name:FORECAST_DATA_UPDATE_FAILED_TAG
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setupCamera)
                                                 name:CAMERA_DATA_UPDATED_TAG
                                               object:nil];
    
    // Only show the default forecast if enabled
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.mpiannucci.HackWinds"];
    [defaults synchronize];
    showDetailedForecastInfo = [defaults boolForKey:@"ShowDetailedForecastInfo"];
    
    // Update the views UI
    [self setupCamera];
    [self updateUI];
    
    if ([defaults integerForKey:@"RunCount"] == 7) {
        if([SKStoreReviewController class]){
            [SKStoreReviewController requestReview] ;
        }
    }
}

- (void)viewDidLayoutSubviews {
    self.camScrollView.contentSize = CGSizeMake(self.camScrollView.frame.size.width * CAMERA_IMAGE_COUNT, self.camScrollView.frame.size.height);
}

- (void)viewWillDisappear:(BOOL)animated {
    // Remove the listener when the view goes out of focus
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateUI {
    // Get the date and set the weekday text
    NSDate *now = [[NSDate alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    [self.dayHeader setText:[dateFormatter stringFromDate:now]];
    
    currentConditions = [self.forecastModel getForecastsForDay:0];
    
    if (currentConditions == nil) {
        lastFetchFailure = YES;
    } else {
        lastFetchFailure = NO;
    }
    
    [self.tableView reloadData];
}

- (void) forecastUpdateFailed {
    lastFetchFailure = YES;
    
    [self.tableView reloadData];
}

- (BOOL)check24HourClock {
    NSLocale *locale = [NSLocale currentLocale];
    NSString *dateCheck = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:locale];
    is24HourClock = ([dateCheck rangeOfString:@"a"].location == NSNotFound);
    return is24HourClock;
}

- (void) showModelInformationPopup {
    UIAlertController* forecastInfoAlert = [UIAlertController alertControllerWithTitle:@"Rhode Island Surf Forecast"
                                                                               message:[NSString stringWithFormat:@"%@\n\nWind Model: %@\n\nUpdated %@", self.forecastModel.waveModelName, self.forecastModel.windModelName, self.forecastModel.waveModelRun]
                                                                        preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    [forecastInfoAlert addAction:defaultAction];
    
    [self presentViewController:forecastInfoAlert animated:YES completion:nil];
}


#pragma mark - Camera setup and scrolling

- (void) setupCamera {
    CameraModel *cameraModel = [CameraModel sharedModel];
    if (cameraModel.cameras.cameraLocations.count > 0) {
        [self.alternateCamerasBarButton setEnabled:YES];
        [self.alternateCamerasBarButton setTintColor:[UIColor whiteColor]];
    } else {
        [self.alternateCamerasBarButton setEnabled:NO];
        [self.alternateCamerasBarButton setTintColor:[UIColor clearColor]];
    }

    wwCamera = cameraModel.defaultCamera;
    if (wwCamera != nil) {
        [self loadCameraPages];
    }
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

- (void) clearCameraPages {
    for (int index = 0; index < CAMERA_IMAGE_COUNT; index++) {
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
    // Because image 5 doesn't load for some reason hack around it
    if (index > 3) {
        index++;
    }
    
    NSString *baseURL = wwCamera.imageUrl;
    return [NSURL URLWithString:[baseURL stringByReplacingOccurrencesOfString:@"01.jpg"
                                                                   withString:[NSString stringWithFormat:@"%02d.jpg", index+1]]];
}

- (void) showLiveCamera:(UITapGestureRecognizer *)sender {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.mpiannucci.HackWinds"];
    [defaults synchronize];
    
    if (![defaults boolForKey:@"ShowPremiumContent"]) {
        return;
    }
    
    SFSafariViewController* svc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:wwCamera.webUrl]];
    svc.delegate = self;
    [self presentViewController:svc animated:YES completion:nil];
}

#pragma mark - UIScrollViewDelegate

-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
    [self loadCameraPages];
}

#pragma mark - TableView

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (showDetailedForecastInfo && indexPath.section == 0) {
        return 90;
    } else {
        return 45;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (self.tideModel.dayCount > 0) {
        return 2;
    } else {
        return 1;
    }
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 1:
            return @"Tides";
        default:
            return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return so there will always be currentconditions.count rows + the header row
    switch (section) {
        case 0:
            if (currentConditions == nil) {
                return 0;
            }
    
            if (showDetailedForecastInfo) {
                return currentConditions.count;
            } else {
                return currentConditions.count + 1;
            }
        case 1:
            if (self.tideModel.dayCount > 0) {
                return [self.tideModel dataCountForIndex:0];
            } else {
                return 0;
            }
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case 0:
            if (showDetailedForecastInfo) {
                // Get the interface items
                cell = [tableView dequeueReusableCellWithIdentifier:@"detailedForecastItem"];
                UILabel *hourLabel = (UILabel *)[cell viewWithTag:91];
                UILabel *conditionsLabel = (UILabel *)[cell viewWithTag:92];
                UILabel *primarySwellLabel = (UILabel *)[cell viewWithTag:93];
                UILabel *secondarySwellLabel = (UILabel *)[cell viewWithTag:94];
        
                // Get the condition object
                Forecast *thisCondition = [currentConditions objectAtIndex:indexPath.row];
        
                // Set the data to show in the labels
                if (is24HourClock) {
                    hourLabel.text = [thisCondition timeToTwentyFourHourClock];
                } else {
                    hourLabel.text = [thisCondition timeStringNoZero];
                }
                conditionsLabel.text = [NSString stringWithFormat:@"%d - %d ft, Wind %@ %d mph", thisCondition.minimumBreakingHeight.intValue, thisCondition.maximumBreakingHeight.intValue, thisCondition.windCompassDirection, thisCondition.windSpeed.intValue];
                primarySwellLabel.text = [thisCondition.primarySwellComponent getDetailedSwellSummmary];
                if ([thisCondition.secondarySwellComponent.compassDirection isEqualToString:@"NULL"]) {
                    secondarySwellLabel.text = @"No Secondary Swell Component";
                } else {
                    secondarySwellLabel.text = [thisCondition.secondarySwellComponent getDetailedSwellSummmary];
                }
            } else {
                // Get the interface items
                cell = [tableView dequeueReusableCellWithIdentifier:@"simpleForecastItem"];
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
                    if (currentConditions.count == 0) {
                        return cell;
                    }
            
                    Forecast *thisCondition = [currentConditions objectAtIndex:indexPath.row-1];
            
                    // Set the data to show in the labels
                    if (is24HourClock) {
                        hourLabel.text = [thisCondition timeToTwentyFourHourClock];
                    } else {
                        hourLabel.text = [thisCondition timeStringNoZero];
                    }
                    waveLabel.text = [NSString stringWithFormat:@"%d - %d", thisCondition.minimumBreakingHeight.intValue, thisCondition.maximumBreakingHeight.intValue];
                    windLabel.text = [NSString stringWithFormat:@"%@ %d", thisCondition.windCompassDirection, thisCondition.windSpeed.intValue];
                    swellLabel.text = [thisCondition.primarySwellComponent getSwellSummmary];
            
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
            }
            break;
        case 1:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"tideItem"];
                Tide *thisTide = [[TideModel sharedModel] tideDataAtIndex:indexPath.row forDay:0];
                if ([thisTide isTidalEvent]) {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: %@", thisTide.eventType, thisTide.height];
                } else {
                    cell.detailTextLabel.text = thisTide.eventType;
                }
                cell.textLabel.text = [thisTide timeString];
            
                if ([thisTide isHighTide]) {
                    cell.imageView.image = [[UIImage imageNamed:@"ic_trending_up_white"]
                                         imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    cell.imageView.tintColor = HACKWINDS_BLUE_COLOR;
                } else if ([thisTide isLowTide]) {
                    cell.imageView.image = [[UIImage imageNamed:@"ic_trending_down_white"]
                                         imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    cell.imageView.tintColor = HACKWINDS_BLUE_COLOR;
                } else if ([thisTide isSunrise]) {
                    cell.imageView.image = [[UIImage imageNamed:@"ic_brightness_high_white"]
                                         imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    cell.imageView.tintColor = [UIColor orangeColor];
                } else if ([thisTide isSunset]) {
                    cell.imageView.image = [[UIImage imageNamed:@"ic_brightness_low_white"]
                                         imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    cell.imageView.tintColor = [UIColor orangeColor];
                }
            }
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma mark - Rotation

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    // Code here will execute before the rotation begins.
    // Equivalent to placing it in the deprecated method -[willRotateToInterfaceOrientation:duration:]
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        // Place code here to perform animations during the rotation.
        // You can pass nil or leave this block empty if not necessary.
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        // Code here will execute after the rotation has finished.
        // Equivalent to placing it in the deprecated method -[didRotateFromInterfaceOrientation:]
        [self clearCameraPages];
        [self loadCameraPages];
    }];
}

#pragma mark - Safari View Controller delegate

- (void) safariViewControllerDidFinish:(SFSafariViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
