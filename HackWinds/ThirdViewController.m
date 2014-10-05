//
//  ThirdViewController.m
//  HackWinds
//
//  Created by Matthew Iannucci on 7/27/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//
#define wunderBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define wunderURL [NSURL URLWithString:@"http://api.wunderground.com/api/2e5424aab8c91757/tide/q/RI/Point_Judith.json"]
#define weekdays [NSArray arrayWithObjects:@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", nil]

#import "ThirdViewController.h"
#import "Tide.h"

@interface ThirdViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tideTable;

@end

@implementation ThirdViewController
{
    NSMutableArray *tides;
    NSInteger currentday;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Array to load the data into
    tides = [[NSMutableArray alloc] init];

    // get the day of the week
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    currentday = [comps weekday];

    // Load the Wunderground Data
    dispatch_async(wunderBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:
                        wunderURL];
        [self performSelectorOnMainThread:@selector(fetchedWunderData:)
                               withObject:data waitUntilDone:YES];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return so there will always be 5 rows
    return 1;
}

- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    // Get the interface items
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tideItem"];
    
    // Return the cell view
    return cell;
}

- (void)fetchedWunderData:(NSData *)responseData {
    //parse out the Wunderground json data
    NSError* error;
    NSArray* json = [NSJSONSerialization
                     JSONObjectWithData:responseData
                     options:kNilOptions
                     error:&error];
    // Quick log to check the amount of json objects recieved
    NSLog(@"%lu", (unsigned long)[json count]);

    // Loop through the data and sort it into Tide objects
    for (int i=0; i<[json count]; i++) {
        
    
    }

}

@end
