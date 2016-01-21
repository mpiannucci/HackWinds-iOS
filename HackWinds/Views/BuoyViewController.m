//
//  BuoyViewController.m
//  HackWinds
//
//  Created by Matthew Iannucci on 10/9/14.
//  Copyright (c) 2014 Matthew Iannucci. All rights reserved.
//
// Block Island ID: Station 44097
// Montauk ID: Station 44017
//

#import "BuoyViewController.h"
#import <HackWindsDataKit/HackWindsDataKit.h>
#import "Reachability.h"
#import "NavigationBarTitleWithSubtitleView.h"

@interface BuoyViewController ()

@property (weak, nonatomic) IBOutlet UITableView *buoyTable;
@property (strong, nonatomic) NavigationBarTitleWithSubtitleView *navigationBarTitle;

@property (strong, nonatomic) BuoyModel *buoyModel;

@end

@implementation BuoyViewController
{
    // Initilize some things we want available over the entire view controller
    NSMutableArray *currentBuoyData;
    NSString *buoyLocation;
    NSString *dataMode;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set up the custom nav bar with the buoy location
    self.navigationBarTitle = [[NavigationBarTitleWithSubtitleView alloc] init];
    [self.navigationItem setTitleView: self.navigationBarTitle];
    [self.navigationBarTitle setTitleText:@"HackWinds"];
    [self.navigationBarTitle.detailButton addTarget:self action:@selector(locationButtonClicked:)  forControlEvents:UIControlEventTouchDown];
    
    // Load the buoy settings
    [self loadBuoySettings];
    
    // Initialize the buoy model
    self.buoyModel = [BuoyModel sharedModel];
    
    // Initialize the current buoy data
    currentBuoyData = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Reload the UI in case we missed a notification
    [self updateUI];
    
    // Register the notification center listener when the view appears
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUI)
                                                 name:BUOY_DATA_UPDATED_TAG
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    // Remove the listener when the view goes out of focus
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BUOY_DATA_UPDATED_TAG
                                                  object:nil];
    
    [super viewDidDisappear:animated];
}

- (void)updateUI {
    // Grab the correct wave heights
    currentBuoyData = [self.buoyModel getBuoyData];
    
    // Update the table
    [self.buoyTable reloadData];
}

- (void)loadBuoySettings {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.nucc.HackWinds"];
    [defaults synchronize];
    
    // Grab the last set or default location
    buoyLocation = [defaults objectForKey:@"BuoyLocation"];
    [self.navigationBarTitle setDetailText:[NSString stringWithFormat:@"Location: %@", buoyLocation]];
    
    // Initialize in summary mode
    dataMode = SUMMARY_DATA_MODE;
}

- (void)locationButtonClicked:(id)sender{
    UIActionSheet *locationActionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Buoy Location"
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:BUOY_LOCATIONS];
    // Show the action sheet
    [locationActionSheet setTintColor:HACKWINDS_BLUE_COLOR];
    [locationActionSheet showInView:self.view];
}

- (IBAction)dataViewModeChanged:(id)sender {
    // Grab the new data mode
    UISegmentedControl *segmentSender = (UISegmentedControl*) sender;
    dataMode = [segmentSender titleForSegmentAtIndex:segmentSender.selectedSegmentIndex];
    
    // Reload all of the data
    [self updateUI];
}

#pragma mark - ActionSheet

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.nucc.HackWinds"];
    
    if (buttonIndex != [actionSheet numberOfButtons] - 1) {
        // If the user selects a location, set the settings key to the new location
        [defaults setObject:[actionSheet buttonTitleAtIndex:buttonIndex] forKey:@"BuoyLocation"];
        [defaults synchronize];
        [self loadBuoySettings];
        
        // Tell everyone the data has updated
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]
             postNotificationName:BUOY_LOCATION_CHANGED_TAG
             object:self];
        });
        
    } else {
        NSLog(@"Buoy Location change cancelled, keep location at %@", [defaults objectForKey:@"BuoyLocation"]);
    }
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return so there will always be 20 rows, plus an extra dor the column headers
    return currentBuoyData.count + 1;
}

- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    // Get the interface items
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"buoyItem"];
    UILabel *timeLabel = (UILabel *)[cell viewWithTag:31];
    UILabel *wvhtLabel = (UILabel *)[cell viewWithTag:32];
    UILabel *dpdLabel = (UILabel *)[cell viewWithTag:33];
    UILabel *directionLabel = (UILabel *)[cell viewWithTag:34];
    
    // Set the data to the label
    if ([indexPath row] < 1) {
        // Set the headers for the first row
        [timeLabel setText:@"Time"];
        [wvhtLabel setText:@"Waves"];
        [dpdLabel setText:@"Period"];
        [directionLabel setText:@"Direction"];
        
        // Set the color to be different so you can tell it's the header
        [timeLabel setTextColor:HACKWINDS_BLUE_COLOR];
        [wvhtLabel setTextColor:HACKWINDS_BLUE_COLOR];
        [dpdLabel setTextColor:HACKWINDS_BLUE_COLOR];
        [directionLabel setTextColor:HACKWINDS_BLUE_COLOR];
        
        // Make the font bold cuz its the header
        [timeLabel setFont:[UIFont boldSystemFontOfSize:17.0]];
        [wvhtLabel setFont:[UIFont boldSystemFontOfSize:17.0]];
        [dpdLabel setFont:[UIFont boldSystemFontOfSize:17.0]];
        [directionLabel setFont:[UIFont boldSystemFontOfSize:17.0]];
        
    } else {
        // Get the object
        Buoy *thisBuoy = [currentBuoyData objectAtIndex:indexPath.row-1];
        
        // Set the labels to the data
        [timeLabel setText:thisBuoy.timestamp];
        
        if ([dataMode isEqualToString:SUMMARY_DATA_MODE]) {
            [wvhtLabel setText:thisBuoy.significantWaveHeight];
            [dpdLabel setText:thisBuoy.dominantPeriod];
            [directionLabel setText:[Buoy getCompassDirection:thisBuoy.meanDirection]];
        } else if ([dataMode isEqualToString:SWELL_DATA_MODE]) {
            [wvhtLabel setText:thisBuoy.swellWaveHeight];
            [dpdLabel setText:thisBuoy.swellPeriod];
            [directionLabel setText:thisBuoy.swellDirection];
        } else if ([dataMode isEqualToString:WIND_DATA_MODE]) {
            [wvhtLabel setText:thisBuoy.windWaveHeight];
            [dpdLabel setText:thisBuoy.windWavePeriod];
            [directionLabel setText:thisBuoy.windWaveDirection];
        }
        
        // Make sure the text is black
        [timeLabel setTextColor:[UIColor blackColor]];
        [wvhtLabel setTextColor:[UIColor blackColor]];
        [dpdLabel setTextColor:[UIColor blackColor]];
        [directionLabel setTextColor:[UIColor blackColor]];
        
        // Make sure the font is not bold
        [timeLabel setFont:[UIFont systemFontOfSize:17.0]];
        [wvhtLabel setFont:[UIFont systemFontOfSize:17.0]];
        [dpdLabel setFont:[UIFont systemFontOfSize:17.0]];
        [directionLabel setFont:[UIFont systemFontOfSize:17.0]];
        
    }
    
    // Return the cell view
    return cell;
}

#pragma mark - Navigation
 
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
 }

@end