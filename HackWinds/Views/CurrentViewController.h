//
//  CurrentViewController.h
//  HackWinds
//
//  Created by Matthew Iannucci on 7/18/14.
//  Copyright (c) 2014 Matthew Iannucci. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HackWindsDataKit/HackWindsDataKit.h>

@interface CurrentViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIScrollViewDelegate>

- (void) updateUI;
- (void) forecastUpdateFailed;
- (void) setupCamera;
- (void) loadCameraPages;
- (void) loadCameraPageForIndex:(int)index;
- (NSURL*) getCameraURLForIndex:(int)index;
- (void) removePageForIndex:(int)index;
- (void) locationButtonClicked:(id)sender;
- (void) getForecastSettings;

@end
