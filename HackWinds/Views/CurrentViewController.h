//
//  CurrentViewController.h
//  HackWinds
//
//  Created by Matthew Iannucci on 7/18/14.
//  Copyright (c) 2014 Matthew Iannucci. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HackWindsDataKit/HackWindsDataKit.h>

@interface CurrentViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>

- (IBAction)playButton:(id)sender;
- (void) streamPlayBackDidFinish:(NSNotification*)notification;
- (void) updateDataFromModel;
- (void) locationButtonClicked:(id)sender;
- (void) getForecastSettings;

@end
