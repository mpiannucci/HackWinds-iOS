//
//  BuoyViewController.h
//  HackWinds
//
//  Created by Matthew Iannucci on 1/21/16.
//  Copyright © 2016 Rhodysurf Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BuoyViewController : UITableViewController <UIActionSheetDelegate>

- (void)loadBuoySettings;
- (void)locationButtonClicked:(id)sender;
- (void)updateUI;

@end
