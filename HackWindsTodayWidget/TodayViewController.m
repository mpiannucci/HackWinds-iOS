//
//  TodayViewController.m
//  HackWindsTodayWidget
//
//  Created by Matthew Iannucci on 8/5/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//
#define modelFetchBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#import "TodayViewController.h"
#import <HackWindsDataKit/HackWindsDataKit.h>
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>

// Private Methods
-(void) cacheData;
-(void) restoreData;
-(NSDate *) dateWithHour:(NSInteger)hour
                  minute:(NSInteger)minute
                  second:(NSInteger)second;
-(void) findNextUpdateTime;
-(BOOL) check24HourClock;

// UI Properties
@property (weak, nonatomic) IBOutlet UILabel *buoyStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *tideCurrentStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextTideEventLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdatedLabel;

// Cached objects
@property (strong, nonatomic) Buoy *latestBuoy;
@property (strong, nonatomic) Tide *latestTide;
@property (strong, nonatomic) NSDate *latestRefreshTime;
@property (strong, nonatomic) NSDate *nextUpdateTime;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Restore the data from the defaults cache
    [self restoreData];
    
    // Load the UI
    if ((self.latestBuoy != nil) && (self.latestTide !=nil)) {
        [self reloadUI];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    [self updateViewAynsc];
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    completionHandler(NCUpdateResultNewData);
}

- (BOOL)updateData {
    // Check to see if its time for an update.
    if (self.nextUpdateTime != nil) {
        if ([self.nextUpdateTime compare:[NSDate date]] == NSOrderedDescending) {
            // Only update if the next update time is in the past
            return NO;
        }
    }
    
    // Fetch new data
    self.latestBuoy = [BuoyModel getLatestBuoyDataOnlyForLocation:BLOCK_ISLAND_LOCATION];
    self.latestTide = [TideModel getLatestTidalEventOnly];
    
    return (self.latestBuoy != nil) && [self.latestTide isTidalEvent];
}

- (void) updateViewAynsc {
    // Load the date asynchronously
    dispatch_async(modelFetchBgQueue, ^{
        BOOL loadSuccess = [self updateData];
        if (loadSuccess) {
            self.latestRefreshTime = [NSDate date];
            [self findNextUpdateTime];
            [self performSelectorOnMainThread:@selector(reloadUI)
                                             withObject:nil waitUntilDone:YES];
            [self cacheData];
        }
    });
}

- (void)reloadUI {
    if ((self.latestBuoy == nil) || (self.latestTide == nil)) {
        return;
    }
    
    // Load the buoy UI from the buoy point collected
    NSString *buoyStatus = [NSString stringWithFormat:@"%@ ft @ %@s %@", self.latestBuoy.WaveHeight, self.latestBuoy.DominantPeriod, [Buoy getCompassDirection:self.latestBuoy.Direction]];
    [self.buoyStatusLabel setText:buoyStatus];
    
    // Load the tide UI from the latest tide point collected
    NSString *tideCurrentStatus = @"";
    if ([self.latestTide isHighTide]) {
        tideCurrentStatus = @"Incoming";
    } else {
        tideCurrentStatus = @"Outgoing";
    }
    NSString *nextTideEvent = [NSString stringWithFormat:@"%@ - %@", self.latestTide.EventType, self.latestTide.Time];
    [self.tideCurrentStatusLabel setText:tideCurrentStatus];
    [self.nextTideEventLabel setText:nextTideEvent];
    
    // Set the button title to be the time of the last update
    if (self.latestRefreshTime != nil) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        NSString *dateString = [formatter stringFromDate:self.latestRefreshTime];
        [self.lastUpdatedLabel setText:[NSString stringWithFormat:@"last updated at %@", dateString]];
    }
}

-(void) findNextUpdateTime {
    if ((self.latestBuoy == nil) || (self.latestTide == nil)) {
        return;
    }
    
    // Find the colon to find the correct hour and minute
    NSRange buoySeperatorRange = [self.latestBuoy.Time rangeOfString:@":"];
    NSRange tideSeperatorRange = [self.latestTide.Time rangeOfString:@":"];
    
    // Parse the time from the latest objects
    NSInteger buoyHour = [[self.latestBuoy.Time substringToIndex:buoySeperatorRange.location] integerValue];
    NSInteger buoyMinute = [[self.latestBuoy.Time substringFromIndex:buoySeperatorRange.location+1] integerValue];
    NSInteger tideHour = [[self.latestTide.Time substringToIndex:tideSeperatorRange.location] integerValue];
    NSInteger tideMinute = [[self.latestTide.Time substringWithRange:NSMakeRange(tideSeperatorRange.location+1, 2)] integerValue];
    
    NSDate *buoyTime = [self dateWithHour:buoyHour minute:buoyMinute second:0];
    NSDate *tideTime = [self dateWithHour:tideHour minute:tideMinute second:0];
    
    // Find which time comes first and set that to be the next update time
    if ([buoyTime compare:tideTime] == NSOrderedDescending) {
        self.nextUpdateTime = tideTime;
    } else {
        self.nextUpdateTime = buoyTime;
    }
}

-(void) cacheData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:self.latestBuoy] forKey:@"latestBuoy"];
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:self.latestTide] forKey:@"latestTide"];
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:self.latestRefreshTime] forKey:@"latestRefreshTime"];
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:self.nextUpdateTime] forKey:@"nextUpdateTime"];
    [defaults synchronize];
}

-(void) restoreData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.latestBuoy = [NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"latestBuoy"]];
    self.latestTide = [NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"latestTide"]];
    self.latestRefreshTime = [NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"latestRefreshTime"]];
    self.nextUpdateTime = [NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"nextUpdateTime"]];
}

/** Returns a new NSDate object with the time set to the indicated hour,
 * minute, and second.
 * @param hour The hour to use in the new date.
 * @param minute The number of minutes to use in the new date.
 * @param second The number of seconds to use in the new date.
 */
-(NSDate *) dateWithHour:(NSInteger)hour
                  minute:(NSInteger)minute
                  second:(NSInteger)second
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components: NSCalendarUnitYear |
                                    NSCalendarUnitMonth |
                                    NSCalendarUnitDay | NSCalendarUnitHour
                                               fromDate:[NSDate date]];
    
    if ((components.hour > 6) && (hour < 6)) {
        [components setDay:components.day+1];
    }
    
    [components setHour:hour];
    [components setMinute:minute];
    [components setSecond:second];
    
    NSDate *newDate = [calendar dateFromComponents:components];
    return newDate;
}

- (BOOL) check24HourClock {
    // Slightly different than the ofrecast model check.. not caching the value at all
    NSLocale *locale = [NSLocale currentLocale];
    NSString *dateCheck = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:locale];
    return ([dateCheck rangeOfString:@"a"].location == NSNotFound);
}

@end
