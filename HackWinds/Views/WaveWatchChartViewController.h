//
//  WaveWatchChartViewController.h
//  HackWinds
//
//  Created by Matthew Iannucci on 9/10/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaveWatchChartViewController : UIViewController <UITextFieldDelegate>

- (void) imageLoadSuccess:(id)sender;
- (void) sendChartImageAnimationLoadForType:(int)chartType forIndex:(int)index;
- (NSString*) getChartURLPrefixForType:(int)chartType;

- (IBAction) chartPlayButtonClicked:(id)sender;
- (IBAction) chartPauseButtonClicked:(id)sender;
- (IBAction) closeButtonClicked:(id)sender;
- (IBAction) chartTypeValueChanged:(id)sender;
- (IBAction)manualControlSwitchChanged:(id)sender;
- (IBAction)nextChartImageButtonClicked:(id)sender;
- (IBAction)previousChartImageButtonClicked:(id)sender;
- (IBAction)displayedHourEdited:(id)sender;
- (IBAction)displayedHourStartedEditing:(id)sender;
- (IBAction)animationSpeedSliderValueChanged:(id)sender;

@end
