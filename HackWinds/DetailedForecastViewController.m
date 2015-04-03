//
//  DetailedForecastViewController.m
//  HackWinds
//
//  Created by Matthew Iannucci on 3/30/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//
#define forecastFetchBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define SWELL_CHART 0
#define WIND_CHART 1
#define PERIOD_CHART 2

#import "DetailedForecastViewController.h"
#import "ForecastModel.h"
#import "Condition.h"
#import "Colors.h"
#import "AsyncImageView.h"

@interface DetailedForecastViewController ()

// UI Properties
@property (weak, nonatomic) IBOutlet UITableView *mswTable;
@property (weak, nonatomic) IBOutlet UIImageView *chartImageView;
@property (weak, nonatomic) IBOutlet UIProgressView *chartLoadProgressIndicator;
@property (weak, nonatomic) IBOutlet UISegmentedControl *chartTypeSegmentControl;
@property (weak, nonatomic) IBOutlet UIButton *chartAnimationPlayButton;
@property (weak, nonatomic) IBOutlet UIButton *chartAnimationPauseButton;


// Model Properties
@property (strong, nonatomic) ForecastModel *forecastModel;

// View specifics
@property (strong, nonatomic) NSMutableArray *animationImages;

@end

@implementation DetailedForecastViewController {
    NSArray *currentConditions;
    Boolean needsReload[3];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up the navigation controller
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"Back";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    
    // Get the forecast model instance
    self.forecastModel = [ForecastModel sharedModel];
    
    // Initializew the aniimation image array
    self.animationImages = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    // Hide the play button
    [self.chartAnimationPlayButton setHidden:YES];
    
    // Reset the reload flag
    for (int i = 0; i < 3; i++) {
        needsReload[i] = YES;
    }
    
    // Reload the data for the correct day
    [self getModelData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:self];
    [self.chartImageView stopAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getModelData {
    // Load the MSW Data
    dispatch_async(forecastFetchBgQueue, ^{
        currentConditions = [self.forecastModel getConditionsForIndex:(int)self.dayIndex];
        [self.mswTable performSelectorOnMainThread:@selector(reloadData)
                                    withObject:nil waitUntilDone:YES];
        [self sendChartImageAnimationWithType:SWELL_CHART forIndex:0];
    });
}

- (IBAction)chartTypeChanged:(id)sender {
    // Clear out the old animation images
    // Reset the image buttons and animation
    [self.chartAnimationPlayButton setHidden:YES];
    [self.chartImageView stopAnimating];
    
    // Reset the progress bar
    [self.chartLoadProgressIndicator setHidden:NO];
    [self.chartLoadProgressIndicator setProgress:0.0f animated:YES];
    
    // Reset the animation images and start lolading the new ones
    self.animationImages = [[NSMutableArray alloc] init];
    [self sendChartImageAnimationWithType:(int)[sender selectedSegmentIndex] forIndex:0];
}

- (void)sendChartImageAnimationWithType:(int)type forIndex:(int)index {
    switch (type) {
        case SWELL_CHART:
            // Swell
            [[AsyncImageLoader sharedLoader] loadImageWithURL:[NSURL URLWithString:[[currentConditions objectAtIndex:index] SwellChartURL]]
                                                                       target:self action:@selector(imageLoadSuccess:)];
            break;
        case WIND_CHART:
            // Wind
            [[AsyncImageLoader sharedLoader] loadImageWithURL:[NSURL URLWithString:[[currentConditions objectAtIndex:index] WindChartURL]]
                                                                       target:self action:@selector(imageLoadSuccess:)];
            break;
        case PERIOD_CHART:
            // Period
            [[AsyncImageLoader sharedLoader] loadImageWithURL:[NSURL URLWithString:[[currentConditions objectAtIndex:index] PeriodChartURL]]
                                                                       target:self action:@selector(imageLoadSuccess:)];
            break;
        default:
            // Do Nothing
            break;
    }
}

- (IBAction)playButtonClicked:(id)sender {
    [self.chartImageView startAnimating];
    [self.chartAnimationPlayButton setHidden:YES];
    [self.chartAnimationPauseButton setHidden:NO];
}

- (IBAction)pauseButtonClicked:(id)sender {
    [self.chartImageView stopAnimating];
    [self.chartAnimationPauseButton setHidden:YES];
    [self.chartAnimationPlayButton setHidden:NO];
}

- (void)imageLoadSuccess:(id)sender {
    // Add the image to the array for animation
    [self.animationImages addObject:sender];
    
    if (needsReload[self.chartTypeSegmentControl.selectedSegmentIndex]) {
        [self.chartLoadProgressIndicator setProgress:self.animationImages.count/6.0f animated:YES];
    }
    
    if ([self.animationImages count] < 2) {
        // If its the first image set it to the header as a holder
        [self.chartImageView setImage:sender];
    } else if ([self.animationImages count] == 6) {
        // We have all of the images so animate!!!
        [self.chartImageView setAnimationImages:self.animationImages];
        [self.chartImageView setAnimationDuration:5];
        
        // Okay so this is really hacky... For some reasons the images are not loaded correctly on the first
        // pass through each of the views. 
        if (needsReload[self.chartTypeSegmentControl.selectedSegmentIndex]) {
            self.animationImages = [[NSMutableArray alloc] init];
            needsReload[self.chartTypeSegmentControl.selectedSegmentIndex] = NO;
        } else {
            // Show the play button, Hide the stop Button
            [self.chartAnimationPauseButton setHidden:YES];
            [self.chartAnimationPlayButton setHidden:NO];
            
            // Hide the progress bar becasue its loaded
            [self.chartLoadProgressIndicator setHidden:YES];
        }
    }
    if (self.animationImages.count < 6) {
        // If the animation array isnt full, get the next image on the stack
        [self sendChartImageAnimationWithType:(int)self.chartTypeSegmentControl.selectedSegmentIndex
                                     forIndex:(int)self.animationImages.count];
    }
}

#pragma mark - TableView Handling

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return so there will always be 6 rows
    return [[self.forecastModel conditions] count]/5+1;
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

 #pragma mark - Navigation
 
// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
// Get the new view controller using [segue destinationViewController].
// Pass the selected object to the new view controller.
//}

@end
