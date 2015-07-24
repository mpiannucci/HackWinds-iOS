//
//  IsoCameraViewController.h
//  HackWinds
//
//  Created by Matthew Iannucci on 5/4/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IsoCameraViewController : UIViewController

@property (weak, nonatomic) NSString *LocationName;
@property (weak, nonatomic) NSString *CameraName;

- (void)setCamera:(NSString *)camera forLocation:(NSString *)location;
- (void)loadCamImage;
- (void)updateRefreshLabel;
- (void)updateFullScreenImage;
- (IBAction)autoReloadSwitchChange:(id)sender;
- (IBAction)fullScreenClick:(id)sender;
- (IBAction)exitButtonClick:(id)sender;
- (IBAction)fullScreenExitClick:(id)sender;
- (IBAction)videoPlayButtonClick:(id)sender;
- (void) videoPlayBackDidFinish:(NSNotification*)notification;

@end
