//
//  BuoyViewController.h
//  HackWinds
//
//  Created by Matthew Iannucci on 10/9/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface BuoyViewController : UIViewController <UITableViewDataSource,
    UITableViewDelegate, CPTPlotDataSource, CPTPlotDelegate>

- (void)fetchBuoyData:(NSNumber*)location;
- (void)setAxisLabels:(CPXYGraph*)graphForAxis;

- (IBAction)locationSegmentValueChanged:(id)sender;

@end
