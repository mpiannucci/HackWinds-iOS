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

#import "BuoyHistoryViewController.h"
#import <HackWindsDataKit/HackWindsDataKit.h>
#import "Reachability.h"

@interface BuoyHistoryViewController ()

@property (weak, nonatomic) IBOutlet UITableView *buoyTable;

@property (strong, nonatomic) BuoyModel *buoyModel;

@end

@implementation BuoyHistoryViewController
{
    // Initilize some things we want available over the entire view controller
    NSMutableArray *currentBuoyData;
    NSString *buoyLocation;
    NSString *dataMode;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Get the buoy location
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.mpiannucci.HackWinds"];
    [defaults synchronize];
    buoyLocation = [defaults objectForKey:@"BuoyLocation"];
    
    // Set up the custom nav bar with the buoy location
    self.navigationItem.title = buoyLocation;
    
    // Initialize the buoy model
    self.buoyModel = [BuoyModel sharedModel];
    
    // Initialize the current buoy data
    currentBuoyData = [[NSMutableArray alloc] init];
    
    // Initialize the view to summary mode
    dataMode = SUMMARY_DATA_MODE;
    
    // Load the view!
    [self updateUI];
}

- (void)updateUI {
    // Grab the correct wave heights
    currentBuoyData = [self.buoyModel getBuoyData];
    
    // Update the table
    [self.buoyTable reloadData];
}

- (IBAction)dataViewModeChanged:(id)sender {
    // Grab the new data mode
    UISegmentedControl *segmentSender = (UISegmentedControl*) sender;
    dataMode = [segmentSender titleForSegmentAtIndex:segmentSender.selectedSegmentIndex];
    
    // Reload all of the data
    [self updateUI];
}

- (IBAction)closeButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
        [timeLabel setText:[thisBuoy timeString]];
        
        if ([dataMode isEqualToString:SUMMARY_DATA_MODE]) {
            [wvhtLabel setText:[thisBuoy.significantWaveHeight stringValue]];
            [dpdLabel setText:[thisBuoy.dominantPeriod stringValue]];
            [directionLabel setText:thisBuoy.meanDirection];
        } else if ([dataMode isEqualToString:SWELL_DATA_MODE]) {
            [wvhtLabel setText:[thisBuoy.swellWaveHeight stringValue]];
            [dpdLabel setText:[thisBuoy.swellPeriod stringValue]];
            [directionLabel setText:thisBuoy.swellDirection];
        } else if ([dataMode isEqualToString:WIND_DATA_MODE]) {
            [wvhtLabel setText:[thisBuoy.windWaveHeight stringValue]];
            [dpdLabel setText:[thisBuoy.windWavePeriod stringValue]];
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