//
//  BuoyViewController.h
//  HackWinds
//
//  Created by Matthew Iannucci on 10/9/14.
//  Copyright (c) 2014 Matthew Iannucci. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface BuoyHistoryViewController : UIViewController <UITableViewDataSource,
    UITableViewDelegate, UIActionSheetDelegate>

- (void)updateUI;
- (IBAction)dataViewModeChanged:(id)sender;
- (IBAction)closeButtonClicked:(id)sender;

@end
