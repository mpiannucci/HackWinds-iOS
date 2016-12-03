//
//  SettingsViewController.h
//  HackWinds
//
//  Created by Matthew Iannucci on 2/24/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UITableViewController

- (void) loadSettings;

- (IBAction)acceptSettingsClick:(id)sender;
- (IBAction)changeDefaultBuoyLocationClicked:(id)sender;
- (IBAction)contactDevClicked:(id)sender;
- (IBAction)showDisclaimerClicked:(id)sender;
- (IBAction)rateAppClicked:(id)sender;
- (IBAction)showDetailedForecastInfoChanged:(id)sender;

@end
