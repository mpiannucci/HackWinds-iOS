//
//  TideViewController.m
//  HackWinds
//
//  Created by Matthew Iannucci on 7/27/14.
//  Copyright (c) 2014 Matthew Iannucci. All rights reserved.
//
#define TIDE_FETCH_BG_QUEUE dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#import "TideViewController.h"
#import "TideModel.h"
#import "Tide.h"
#import "Colors.h"

@interface TideViewController ()

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *tideLabel1;
@property (weak, nonatomic) IBOutlet UILabel *tideLabel2;
@property (weak, nonatomic) IBOutlet UILabel *tideLabel3;
@property (weak, nonatomic) IBOutlet UILabel *tideLabel4;
@property (weak, nonatomic) IBOutlet UILabel *sunriseTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *sunsetTimeLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;

@property (strong, nonatomic) TideModel *tideModel;
@property (strong, nonatomic) NSArray *labels;

@end

@implementation TideViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Get the tide model
    _tideModel = [TideModel sharedModel];
    
    // An array to hold the tide labels
    _labels = [[NSArray alloc] initWithObjects:_tideLabel1, _tideLabel2, _tideLabel3, _tideLabel4, nil];
    
    // Get the buoy data and reload the views
    dispatch_async(TIDE_FETCH_BG_QUEUE, ^{
        NSMutableArray *tideData = [_tideModel getTideData];
        [self performSelectorOnMainThread:@selector(reloadView:)
                               withObject:tideData waitUntilDone:YES];
    });
}

- (void)viewDidLayoutSubviews {
    // For some reason the scaling sucks on less than an iphone 5, so fix it
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    if (screenHeight > 500) {
        _mainScrollView.contentSize = CGSizeMake(320, 425);
    } else {
        _mainScrollView.contentSize = CGSizeMake(320, 500);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadView:(NSMutableArray* ) tideData {
    // First, if it is the first item, check what it is,
    // then set the status accordingly
    int firstIndex = 0;
    if (([[[tideData objectAtIndex:0] eventType] isEqualToString:SUNRISE_TAG]) ||
        ([[[tideData objectAtIndex:0] eventType] isEqualToString:SUNSET_TAG])) {
        // If its sunrise or sunset we dont care for now, skip it.
        firstIndex++;
    }
    NSString* firstEvent = [[tideData objectAtIndex:firstIndex] eventType];
    if ([firstEvent isEqualToString:HIGH_TIDE_TAG]) {
        // Show that the tide is incoming, using green because typically surf increases with incoming tides
        [_statusLabel setText:@"Incoming"];
        [_statusLabel setTextColor:GREEN_COLOR];
        
    } else if ([firstEvent isEqualToString:LOW_TIDE_TAG]) {
        // Show that the tide is outgoing, use red because the surf typically decreases with an outgoing tide
        [_statusLabel setText:@"Outgoing"];
        [_statusLabel setTextColor:RED_COLOR];
    }
    
    int tideCount = 0;
    for (int i = 0; i < [tideData count]; i++) {
        // Then check what is is again, and set correct text box
        Tide* thisTide = [tideData objectAtIndex:i];
        if ([[thisTide eventType] isEqualToString:SUNRISE_TAG]) {
            [_sunriseTimeLabel setText:thisTide.time];
        } else if ([[thisTide eventType] isEqualToString:SUNSET_TAG]) {
            [_sunsetTimeLabel setText:thisTide.time];
        } else if ([[thisTide eventType] isEqualToString:HIGH_TIDE_TAG]) {
            NSString* message = [NSString stringWithFormat:@"High Tide: %@ at %@", thisTide.height, thisTide.time];
            [(UILabel *)[_labels objectAtIndex:tideCount] setText:message];
            // Only increment the tide count for a tide event and not a sunrise or sunset
            tideCount++;
        } else if ([[thisTide eventType] isEqualToString:LOW_TIDE_TAG]) {
            NSString* message = [NSString stringWithFormat:@"Low Tide: %@ at %@", thisTide.height, thisTide.time];
            [(UILabel *)[_labels objectAtIndex:tideCount] setText:message];
            // Only increment the tide count for a tide event and not a sunrise or sunset
            tideCount++;
        }
    }
}

@end
