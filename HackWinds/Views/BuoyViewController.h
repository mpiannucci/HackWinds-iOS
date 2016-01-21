//
//  BuoyViewController.h
//  HackWinds
//
//  Created by Matthew Iannucci on 10/9/14.
//  Copyright (c) 2014 Matthew Iannucci. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface BuoyViewController : UIViewController <UITableViewDataSource,
    UITableViewDelegate, UIActionSheetDelegate>

- (void)loadBuoySettings;
- (void)updateUI;
- (void)locationButtonClicked:(id)sender;
- (IBAction)dataViewModeChanged:(id)sender;

@end
