//
//  SettingsTableViewController.h
//  HackWinds
//
//  Created by Matthew Iannucci on 1/17/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsTableViewController : UITableViewController

- (IBAction)locationButtonClick:(id)sender;
- (void)updateForecastLocation:(NSString*)newLocation;

@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@end
