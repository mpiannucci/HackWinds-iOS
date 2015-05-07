//
//  IsoCameraViewController.h
//  HackWinds
//
//  Created by Matthew Iannucci on 5/4/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IsoCameraViewController : UIViewController

@property (weak, nonatomic) NSString *Location;
@property (weak, nonatomic) NSString *Camera;

- (void)setCamera:(NSString *)camera forLocation:(NSString *)location;
- (void)loadCamImage;
- (IBAction)reloadButtonClick:(id)sender;
- (IBAction)autoReloadSwitchChange:(id)sender;
- (IBAction)fullScreenClick:(id)sender;

@end
