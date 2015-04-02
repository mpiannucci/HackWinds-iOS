//
//  DetailedForecastViewController.m
//  HackWinds
//
//  Created by Matthew Iannucci on 3/30/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//
#define forecastFetchBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#import "DetailedForecastViewController.h"
#import "ForecastModel.h"
#import "Condition.h"
#import "Colors.h"
#import "AsyncImageView.h"

@interface DetailedForecastViewController ()

// UI Properties
@property (weak, nonatomic) IBOutlet UITableView *mswTable;
@property (weak, nonatomic) IBOutlet UIImageView *chartImageView;

// Model Properties
@property (strong, nonatomic) ForecastModel *forecastModel;

@end

@implementation DetailedForecastViewController {
    NSArray *currentConditions;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up the navigation controller
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"Back";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    
    // Get the forecast model instance
    _forecastModel = [ForecastModel sharedModel];
    
}

- (void) viewWillAppear:(BOOL)animated {
    
    // Reload the data for the correct day
    [self getModelData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) getModelData {
    // Load the MSW Data
    dispatch_async(forecastFetchBgQueue, ^{
        currentConditions = [_forecastModel getConditionsForIndex:(int)_dayIndex];
        [_mswTable performSelectorOnMainThread:@selector(reloadData)
                                    withObject:nil waitUntilDone:YES];
        [[AsyncImageLoader sharedLoader] loadImageWithURL:[NSURL URLWithString:[[currentConditions objectAtIndex:0] SwellChartURL]] target:self action:@selector(imageLoadSuccess:)];
    });
}

- (IBAction)chartTypeChanged:(id)sender {
    
}

- (void)imageLoadSuccess:(id)sender {
    _chartImageView.image = sender;
}

#pragma mark - TableView Handling

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return so there will always be 6 rows
    return [[_forecastModel conditions] count]/5+1;
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
