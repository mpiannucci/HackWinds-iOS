//
//  BuoyViewController.m
//  HackWinds
//
//  Created by Matthew Iannucci on 10/9/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//
// Block Island ID: Station 44097
// Montauk ID: Station 44017
//
#define NDBCBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define BLOCK_ISLAND_LOCATION 41
#define MONTAUK_LOCATION 42
#define DATA_POINTS 20
#define DATA_HEADER_LENGTH 38
#define DATA_LINE_LEN 19
#define HOUR_OFFSET 3
#define MINUTE_OFFSET 4
#define WVHT_OFFSET 8
#define DPD_OFFSET 9
#define DIRECTION_OFFSET 11
#define BIurl [NSURL URLWithString:@"http://www.ndbc.noaa.gov/data/realtime2/44097.txt"]
#define montaukUrl [NSURL URLWithString:@"http://www.ndbc.noaa.gov/data/realtime2/44017.txt"]

#import "BuoyViewController.h"
#import "Buoy.h"

@interface BuoyViewController ()
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *graphHolder;
@property (weak, nonatomic) IBOutlet UITableView *buoyTable;

@end

@implementation BuoyViewController
{
    NSMutableArray *buoyDatas;
    CPTScatterPlot* plot;
    CPTGraph* graph;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Array to load the data into 
    buoyDatas = [[NSMutableArray alloc] init];
    
    // Create the graph view
    graph = [[CPTXYGraph alloc] initWithFrame:_graphHolder.bounds];
    _graphHolder.hostedGraph = graph;
    [graph setTitle:@"Wave Height (ft)"];
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    [plotSpace setYRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat( 0 ) length:CPTDecimalFromFloat( 2 )]];
    [plotSpace setXRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat( 10 ) length:CPTDecimalFromFloat( -10 )]];
    
    plot = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
    plot.dataSource = self;
    [graph addPlot:plot toPlotSpace:graph.defaultPlotSpace];
    NSNumberFormatter *axisFormatter = [[NSNumberFormatter alloc] init];
    [axisFormatter setMinimumIntegerDigits:1];
    [axisFormatter setMaximumFractionDigits:0];
    
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    [textStyle setFontSize:12.0f];
    
    [[graph plotAreaFrame] setPaddingLeft:20.0f];
    [[graph plotAreaFrame] setPaddingTop:5.0f];
    [[graph plotAreaFrame] setPaddingBottom:50.0f];
    [[graph plotAreaFrame] setPaddingRight:10.0f];
    [[graph plotAreaFrame] setBorderLineStyle:nil];
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)[graph axisSet];
    
    CPTXYAxis *xAxis = [axisSet xAxis];
    [xAxis setMajorIntervalLength:CPTDecimalFromInt(2)];
    [xAxis setMinorTickLineStyle:nil];
    [xAxis setLabelingPolicy:CPTAxisLabelingPolicyFixedInterval];
    [xAxis setLabelTextStyle:textStyle];
    [xAxis setLabelFormatter:axisFormatter];
    [xAxis setTitle:@"Hours Ago"];
    xAxis.orthogonalCoordinateDecimal = CPTDecimalFromFloat(0.0);
    
    CPTXYAxis *yAxis = [axisSet yAxis];
    [yAxis setMajorIntervalLength:CPTDecimalFromInt(1)];
    [yAxis setMinorTickLineStyle:nil];
    [yAxis setLabelingPolicy:CPTAxisLabelingPolicyFixedInterval];
    [yAxis setLabelTextStyle:textStyle];
    [yAxis setLabelFormatter:axisFormatter];
    yAxis.orthogonalCoordinateDecimal = CPTDecimalFromFloat(10.0);
    
    // Load the buoy data
    [self performSelectorInBackground:@selector(fetchBuoyData:) withObject:[NSNumber numberWithInt:BLOCK_ISLAND_LOCATION]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return so there will always be 20 rows
    return [buoyDatas count];
}

- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    // Get the interface items
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"buoyItem"];
    UILabel *timeLabel = (UILabel *)[cell viewWithTag:31];
    UILabel *wvhtLabel = (UILabel *)[cell viewWithTag:32];
    UILabel *apdLabel = (UILabel *)[cell viewWithTag:33];
    UILabel *steepnessLabel = (UILabel *)[cell viewWithTag:34];
    
    // Get the object
    Buoy *thisBuoy = [buoyDatas objectAtIndex:indexPath.row];
    
    // Set the data to the label
    [timeLabel setText:thisBuoy.time];
    [wvhtLabel setText:thisBuoy.wvht];
    [apdLabel setText:thisBuoy.dpd];
    [steepnessLabel setText:thisBuoy.direction];
    
    // Return the cell view
    return cell;
}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plotnumberOfRecords {
    return [buoyDatas count]; // Our sample graph contains 9 'points'
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    // Get the buoy object for the index
    Buoy *thisBuoy = [buoyDatas objectAtIndex:index];
    
    // We need to provide an X or Y (this method will be called for each) value for every index
    double x = (double) index/2;
    
    // This method is actually called twice per point in the plot, one for the X and one for the Y value
    if(fieldEnum == CPTScatterPlotFieldX)
    {
        // Return x value, which will, depending on index, be between -4 to 4
        return [NSNumber numberWithDouble:x];
    } else {
        // Return y value, for this example we'll be plotting y = x * x
        return [NSNumber numberWithDouble:[thisBuoy.wvht doubleValue]];
    }
}
                        
- (void)fetchBuoyData:(NSNumber*)location {
    buoyDatas = [[NSMutableArray alloc] init];
    NSMutableArray* wvhts = [[NSMutableArray alloc] init];
    NSString* buoyData;
    NSError *err = nil;
    if ([location isEqualToNumber:[NSNumber numberWithInt:BLOCK_ISLAND_LOCATION]]) {
        buoyData = [NSString stringWithContentsOfURL:BIurl encoding:NSUTF8StringEncoding error:&err];
    } else {
        // Montauk
        buoyData = [NSString stringWithContentsOfURL:montaukUrl encoding:NSUTF8StringEncoding error:&err];
    }
    NSCharacterSet *whitespaces = [NSCharacterSet whitespaceCharacterSet];
    NSPredicate *noEmptyStrings = [NSPredicate predicateWithFormat:@"SELF != ''"];
    
    NSArray *parts = [buoyData componentsSeparatedByCharactersInSet:whitespaces];
    NSArray *filteredArray = [parts filteredArrayUsingPredicate:noEmptyStrings];
    buoyData = [filteredArray componentsJoinedByString:@" "];
    NSArray* cleanData = [buoyData componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // Parse the data into buoy objects
    for(int i=DATA_HEADER_LENGTH; i<(DATA_HEADER_LENGTH+(DATA_LINE_LEN*DATA_POINTS)); i+=DATA_LINE_LEN) {
        Buoy* newBuoy = [[Buoy alloc] init];
        [newBuoy setTime:[NSString stringWithFormat:@"%@:%@", [cleanData objectAtIndex:i+HOUR_OFFSET], [cleanData objectAtIndex:i+MINUTE_OFFSET]]];
        [newBuoy setDpd:[cleanData objectAtIndex:i+DPD_OFFSET]];
        [newBuoy setDirection:[cleanData objectAtIndex:i+DIRECTION_OFFSET]];
        
        // Change the wave height to feet
        NSString* wv = [cleanData objectAtIndex:i+WVHT_OFFSET];
        double h =  [wv doubleValue]*3.28;
        
        // Set the wave height
        [newBuoy setWvht:[NSString stringWithFormat:@"%2.2f", h]];
        
        // Append the buoy to the list of buoys
        [buoyDatas addObject:newBuoy];
        
        // Append the wave height for scaling
        [wvhts addObject:[NSString stringWithFormat:@"%2.2f", h]];
    }
    // Update the table
    [_buoyTable reloadData];
    
    // Update the plot
    [plot reloadData];
    
    // Scale the y axis
    NSNumber *maxWV = [wvhts valueForKeyPath:@"@max.doubleValue"];
    double max = round([maxWV doubleValue]+1);
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    [plotSpace setYRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat( 0 ) length:CPTDecimalFromFloat(max)]];
}

- (IBAction)locationSegmentValueChanged:(id)sender {
    int location = 0;
    if ([sender selectedSegmentIndex] == 0) {
        location = BLOCK_ISLAND_LOCATION;
    } else {
        location = MONTAUK_LOCATION;
    }
    // Load the buoy data
    [self performSelectorInBackground:@selector(fetchBuoyData:) withObject:[NSNumber numberWithInt:location]];
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
