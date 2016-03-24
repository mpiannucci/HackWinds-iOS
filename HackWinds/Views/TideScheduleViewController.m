//
//  TideScheduleViewController.m
//  HackWinds
//
//  Created by Matthew Iannucci on 3/20/16.
//  Copyright © 2016 Rhodysurf Development. All rights reserved.
//

#import "TideScheduleViewController.h"
#import <HackWindsDataKit/HackWindsDataKit.h>

@interface TideScheduleViewController()

@property (strong, nonatomic) TideModel *tideModel;

@end

@implementation TideScheduleViewController {
    NSInteger currentday;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Get the day of the week
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    currentday = [comps weekday];
    
    // Get the reference to the tide model
    self.tideModel = [TideModel sharedModel];
}

- (IBAction)closeView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tideModel.dayCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tideModel dataCountForIndex:section];
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [WEEKDAYS objectAtIndex:(((currentday-1) + section)%7)];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Tide *thisTide = [self.tideModel tideDataAtIndex:indexPath.row forDay:indexPath.section];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tideItem"];
    if ([thisTide isTidalEvent]) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", thisTide.eventType, thisTide.height];
    } else {
        cell.textLabel.text = thisTide.eventType;
    }
    cell.detailTextLabel.text = [thisTide timeString];
    
    if ([thisTide isHighTide]) {
        cell.imageView.image = [[UIImage imageNamed:@"ic_trending_up_white"]
                             imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.imageView.tintColor = HACKWINDS_BLUE_COLOR;
    } else if ([thisTide isLowTide]) {
        cell.imageView.image = [[UIImage imageNamed:@"ic_trending_down_white"]
                                imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.imageView.tintColor = HACKWINDS_BLUE_COLOR;
    } else if ([thisTide isSunrise]) {
        cell.imageView.image = [[UIImage imageNamed:@"ic_brightness_high_white"]
                                imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.imageView.tintColor = [UIColor orangeColor];
    } else if ([thisTide isSunset]) {
        cell.imageView.image = [[UIImage imageNamed:@"ic_brightness_low_white"]
                                imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.imageView.tintColor = [UIColor orangeColor];
    }
    
    return cell;
}

@end
