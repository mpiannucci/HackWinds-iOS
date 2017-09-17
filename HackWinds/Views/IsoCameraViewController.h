//
//  IsoCameraViewController.h
//  HackWinds
//
//  Created by Matthew Iannucci on 5/4/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IsoCameraViewController : UIViewController

@property (weak, nonatomic) NSString *locationName;
@property (weak, nonatomic) NSString *cameraName;

- (void)setCamera:(NSString *)camName forLocation:(NSString *)locName;
- (void)loadCamImage;
- (void)updateRefreshLabel;
- (IBAction)autoReloadSwitchChange:(id)sender;
- (IBAction)exitButtonClick:(id)sender;

@end
