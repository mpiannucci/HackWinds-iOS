//
//  TodayViewController.h
//  HackWindsTodayWidget
//
//  Created by Matthew Iannucci on 8/5/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TodayViewController : UIViewController

- (BOOL) updateData;
- (void) updateViewAynsc;
- (void) reloadUI;
- (IBAction)refreshButtonClick:(id)sender;

@end
