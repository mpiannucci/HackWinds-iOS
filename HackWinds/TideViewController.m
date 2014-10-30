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

#import "TideViewController.h"
#import "Tide.h"

@interface TideViewController ()
@property (weak, nonatomic) IBOutlet UILabel *dayHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *tideLabel1;
@property (weak, nonatomic) IBOutlet UILabel *tideLabel2;
@property (weak, nonatomic) IBOutlet UILabel *tideLabel3;
@property (weak, nonatomic) IBOutlet UILabel *tideLabel4;
@property (weak, nonatomic) IBOutlet UILabel *sunriseTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *sunsetTimeLabel;

@end

@implementation TideViewController
{
    NSMutableArray *tides;
    NSArray *labels;
    NSInteger currentday;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Array to load the data into
    tides = [[NSMutableArray alloc] init];
    
    // An array to hold the tide labels
    labels = [[NSArray alloc] initWithObjects:_tideLabel1, _tideLabel2, _tideLabel3, _tideLabel4, nil];

    // get the day of the week and set it as the header
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    currentday = [comps weekday];
    //[_dayHeaderLabel setText:[weekdays objectAtIndex:currentday-1]];

    
    // Load the Wunderground Data
    dispatch_async(wunderBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:
                        wunderURL];
        [self performSelectorOnMainThread:@selector(fetchedTideData:)
                               withObject:data waitUntilDone:YES];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadView {
    // First, if it is the first item, check what it is,
    // then set the status accordingly
    int firstIndex = 0;
    if (([[[tides objectAtIndex:0] eventType] isEqualToString:SUNRISE_TAG]) ||
        ([[[tides objectAtIndex:0] eventType] isEqualToString:SUNSET_TAG])) {
        // If its sunrise or sunset we dont care for now, skip it.
        firstIndex++;
    }
    NSString* firstEvent = [[tides objectAtIndex:firstIndex] eventType];
    if ([firstEvent isEqualToString:HIGH_TIDE_TAG]) {
        [_statusLabel setText:@"Incoming"];
        [_statusLabel setTextColor:[UIColor colorWithRed:0.00 green:0.77 blue:0.00 alpha:1.0]];
    } else if ([firstEvent isEqualToString:LOW_TIDE_TAG]) {
        [_statusLabel setText:@"Outgoing"];
        [_statusLabel setTextColor:[UIColor colorWithRed:0.84 green:0.00 blue:0.00 alpha:1.0]];
    }
    
    int tideCount = 0;
    for (int i = 0; i < [tides count]; i++) {
        // Then check what is is again, and set correct text box
        Tide* thisTide = [tides objectAtIndex:i];
        if ([[thisTide eventType] isEqualToString:SUNRISE_TAG]) {
            [_sunriseTimeLabel setText:thisTide.time];
        } else if ([[thisTide eventType] isEqualToString:SUNSET_TAG]) {
            [_sunsetTimeLabel setText:thisTide.time];
        } else if ([[thisTide eventType] isEqualToString:HIGH_TIDE_TAG]) {
            NSString* message = [NSString stringWithFormat:@"High Tide: %@ at %@", thisTide.height, thisTide.time];
            [(UILabel *)[labels objectAtIndex:tideCount] setText:message];
            tideCount++;
        } else if ([[thisTide eventType] isEqualToString:LOW_TIDE_TAG]) {
            NSString* message = [NSString stringWithFormat:@"Low Tide: %@ at %@", thisTide.height, thisTide.time];
            [(UILabel *)[labels objectAtIndex:tideCount] setText:message];
            tideCount++;
        }
    }
}

- (void)fetchedTideData:(NSData *)responseData {
    //parse out the Wunderground json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                     JSONObjectWithData:responseData
                     options:kNilOptions
                     error:&error];
    // Quick log to check the amount of json objects recieved
    NSArray* tideSummary = [[json objectForKey:@"tide"] objectForKey:@"tideSummary"];
    
    // Loop through the data and sort it into Tide objects
    int count = 0;
    int i = 0;
    while (count < 6) {
        
        // Get the data type and timestamp
        NSDictionary* thisTide = [tideSummary objectAtIndex:i];
        NSString* dataType = [[thisTide objectForKey:@"data"] objectForKey:@"type"];
        NSString* height = [[thisTide objectForKey:@"data"] objectForKey:@"height"];
        NSString* hour = [[thisTide objectForKey:@"date"] objectForKey:@"hour"];
        NSString* minute = [[thisTide objectForKey:@"date"] objectForKey:@"min"];
        
        // Create the tide string
        NSString* time = [NSString stringWithFormat:@"%@:%@", hour, minute];
        
        // Check for the type and set it to the object
        if ([dataType isEqualToString:SUNRISE_TAG] ||
            [dataType isEqualToString:SUNSET_TAG] ||
            [dataType isEqualToString:HIGH_TIDE_TAG] ||
            [dataType isEqualToString:LOW_TIDE_TAG]) {
            
            // Create the new tide object
            Tide* tide = [[Tide alloc] init];
            [tide setEventType:dataType];
            [tide setTime:time];
            [tide setHeight:height];
        
            // Add the tide to the array
            [tides addObject:tide];
            
            // Increment the count of the tide objects
            count++;
        }
        i++;
    }
    [self reloadView];
}

@end
