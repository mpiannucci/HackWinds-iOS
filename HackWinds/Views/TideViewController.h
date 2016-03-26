//
//  TideViewController.h
//  HackWinds
//
//  Created by Matthew Iannucci on 7/27/14.
//  Copyright (c) 2014 Matthew Iannucci. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Charts/Charts.h>
#import "Buoy.h"

@interface TideViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ChartViewDelegate>

- (void) setupTideChart;
- (void) reloadData;
- (void) loadTideChartData;

@end
