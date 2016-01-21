//
//  TideViewController.h
//  HackWinds
//
//  Created by Matthew Iannucci on 7/27/14.
//  Copyright (c) 2014 Matthew Iannucci. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Buoy.h"

@interface TideViewController : UITableViewController

- (void)updateTideView;
- (void)updateBuoyView:(Buoy*)buoy;

@end
