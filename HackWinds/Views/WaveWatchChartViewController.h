//
//  WaveWatchChartViewController.h
//  HackWinds
//
//  Created by Matthew Iannucci on 9/10/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaveWatchChartViewController : UIViewController

- (void) imageLoadSuccess:(id)sender;
- (void) sendChartImageAnimationLoadForIndex:(int)index;

- (IBAction) chartPlayButtonClicked:(id)sender;
- (IBAction) chartPauseButtonClicked:(id)sender;
- (IBAction) closeButtonClicked:(id)sender;

@end
