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

#define BUOY_FETCH_BG_QUEUE dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#import "BuoyViewController.h"
#import <HackWindsDataKit/HackWindsDataKit.h>
#import "Reachability.h"
#import "NavigationBarTitleWithSubtitleView.h"

@interface BuoyViewController ()

@property (weak, nonatomic) IBOutlet CPTGraphHostingView *graphHolder;
@property (weak, nonatomic) IBOutlet UITableView *buoyTable;
@property (strong, nonatomic) NavigationBarTitleWithSubtitleView *navigationBarTitle;

@property (strong, nonatomic) BuoyModel *buoyModel;

@end

@implementation BuoyViewController
{
    // Initilize some things we want available over the entire view controller
    NSMutableArray *currentBuoyData;
    NSMutableArray *currentWaveHeights;
    CPTScatterPlot *plot;
    CPTGraph *graph;
    NSString *buoy_location;
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
    currentWaveHeights = [[NSMutableArray alloc] init];
    
    // Setup the graph view
    [self setupGraphView];
    
    // Check for the network
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    // Get the buoy data for the defualt location and reload the view
    if (networkStatus != NotReachable) {
        dispatch_async(BUOY_FETCH_BG_QUEUE, ^{
            [self.buoyModel fetchBuoyDataForLocation:buoy_location];
            currentBuoyData = [self.buoyModel getBuoyDataForLocation:buoy_location];
            currentWaveHeights = [self.buoyModel getWaveHeightForLocation:buoy_location];
            [self performSelectorOnMainThread:@selector(reloadView)
                                   withObject:nil waitUntilDone:YES];
        });
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadView {
    // Update the table
    [self.buoyTable reloadData];
    
    // Update the plot data sets
    [plot reloadData];
    
    // Scale the y axis to fit the data
    NSNumber *maxWV = [currentWaveHeights valueForKeyPath:@"@max.doubleValue"];
    double max = round([maxWV doubleValue]+2);
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    [plotSpace setYRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat( 0 ) length:CPTDecimalFromFloat(max)]];
    
    // Set the axis ticks to fit labels without squishing them
    if (max > 8) {
        [[(CPTXYAxisSet *)[graph axisSet] yAxis] setMajorIntervalLength:CPTDecimalFromInt(2)];
    } else {
        [[(CPTXYAxisSet *)[graph axisSet] yAxis] setMajorIntervalLength:CPTDecimalFromInt(1)];
    }
}

- (void)loadBuoySettings {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.nucc.HackWinds"];
    [defaults synchronize];
    
    buoy_location = [defaults objectForKey:@"BuoyLocation"];
    [self.navigationBarTitle setDetailText:[NSString stringWithFormat:@"Location: %@", buoy_location]];
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
    // TODO Change the table based on the data view type
}

#pragma mark - ActionSheet

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.nucc.HackWinds"];
    
    if (buttonIndex != [actionSheet numberOfButtons] - 1) {
        // If the user selects a location, set the settings key to the new location
        [defaults setObject:[actionSheet buttonTitleAtIndex:buttonIndex] forKey:@"BuoyLocation"];
        [defaults synchronize];
        
        // Tell everyone the data has updated
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"BuoyLocationChanged"
             object:self];
        });
        
        // Update the views
        [self loadBuoySettings];
        
        // Get the new buoy data and reload the main view
        dispatch_async(BUOY_FETCH_BG_QUEUE, ^{
            [self.buoyModel fetchBuoyDataForLocation:buoy_location];
            currentBuoyData = [self.buoyModel getBuoyDataForLocation:buoy_location];
            currentWaveHeights = [self.buoyModel getWaveHeightForLocation:buoy_location];
            [self performSelectorOnMainThread:@selector(reloadView)
                                   withObject:nil waitUntilDone:YES];
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
    return [currentBuoyData count]+1;
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
        [timeLabel setText:thisBuoy.Time];
        [wvhtLabel setText:thisBuoy.WaveHeight];
        [dpdLabel setText:thisBuoy.DominantPeriod];
        
        // Set the direction to its letter value on a compass
        [directionLabel setText:[Buoy getCompassDirection:thisBuoy.Direction]];
        
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

#pragma mark - Plotting

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plotnumberOfRecords {
    // The time scales are different time deltas, make sure they both show 9 hours of data
    if ([buoy_location  isEqual: BLOCK_ISLAND_LOCATION])
        return [currentBuoyData count];
    else
        return [currentBuoyData count]/2;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    // Get the buoy object for the index
    Buoy *thisBuoy = [currentBuoyData objectAtIndex:index];
    
    // Depending on the buoy location set the axis scaling
    double x;
    if ([buoy_location  isEqual: BLOCK_ISLAND_LOCATION])
        x = (double) index/2;
    else
        x = (double) index;
    
    // We need to provide an X or Y (this method will be called for each) value for every index
    // This method is actually called twice per point in the plot, one for the X and one for the Y value
    if(fieldEnum == CPTScatterPlotFieldX)
    {
        // Return x value
        return [NSNumber numberWithDouble:x];
    } else {
        // Return y value, for this example we'll be plotting y = mx
        return [NSNumber numberWithDouble:[thisBuoy.WaveHeight doubleValue]];
    }
}

- (void)setupGraphView {
    // Create the graph view and format it
    graph = [[CPTXYGraph alloc] initWithFrame:self.graphHolder.bounds];
    self.graphHolder.hostedGraph = graph;
    [graph setTitle:@"Wave Height (ft)"];
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    [plotSpace setYRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat( 0 ) length:CPTDecimalFromFloat( 2 )]];
    [plotSpace setXRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat( 10 ) length:CPTDecimalFromFloat( -10 )]];
    
    // Set the plot
    plot = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
    plot.dataSource = self;
    [graph addPlot:plot toPlotSpace:graph.defaultPlotSpace];
    NSNumberFormatter *axisFormatter = [[NSNumberFormatter alloc] init];
    [axisFormatter setMinimumIntegerDigits:1];
    [axisFormatter setMaximumFractionDigits:0];
    
    // Set the text style
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    [textStyle setFontSize:12.0f];
    
    // Set the padding
    [[graph plotAreaFrame] setPaddingLeft:20.0f];
    [[graph plotAreaFrame] setPaddingTop:5.0f];
    [[graph plotAreaFrame] setPaddingBottom:50.0f];
    [[graph plotAreaFrame] setPaddingRight:10.0f];
    [[graph plotAreaFrame] setBorderLineStyle:nil];
    
    // Setup the axiss
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)[graph axisSet];
    
    // x axis configs
    CPTXYAxis *xAxis = [axisSet xAxis];
    [xAxis setMajorIntervalLength:CPTDecimalFromInt(2)];
    [xAxis setMinorTickLineStyle:nil];
    [xAxis setLabelingPolicy:CPTAxisLabelingPolicyFixedInterval];
    [xAxis setLabelTextStyle:textStyle];
    [xAxis setLabelFormatter:axisFormatter];
    [xAxis setTitle:@"Hours Ago"];
    xAxis.orthogonalCoordinateDecimal = CPTDecimalFromFloat(0.0);
    
    // y axis configs
    CPTXYAxis *yAxis = [axisSet yAxis];
    [yAxis setMajorIntervalLength:CPTDecimalFromInt(1)];
    [yAxis setMinorTickLineStyle:nil];
    [yAxis setLabelingPolicy:CPTAxisLabelingPolicyFixedInterval];
    [yAxis setLabelTextStyle:textStyle];
    [yAxis setLabelFormatter:axisFormatter];
    yAxis.orthogonalCoordinateDecimal = CPTDecimalFromFloat(10.0);
    
    // animate the graph (only once)
    [CPTAnimation animate:plotSpace
                 property:@"xRange"
                   period:[CPTAnimationPeriod periodWithStartPlotRange:nil
                                                          endPlotRange:plotSpace.xRange
                                                              duration:1.25
                                                             withDelay:0]
           animationCurve:CPTAnimationCurveCubicInOut
                 delegate:nil];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end